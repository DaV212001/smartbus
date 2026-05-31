import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../models/ticket.dart';

class AiTravelAdviceService {
  AiTravelAdviceService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://text.pollinations.ai',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 20),
            ),
          );

  final Dio _dio;

  Future<String?> generateTravelAdvice({
    required String persona,
    required List<Ticket> tickets,
    required String fallbackAdvice,
  }) async {
    Logger().d('called');
    if (tickets.isEmpty) return null;
    Logger().d('ai');
    try {
      Logger().d('ai2');
      var uri = Uri(
        pathSegments: [_buildPrompt(persona, tickets, fallbackAdvice)],
        queryParameters: const {'model': 'openai'},
      );
      Logger().d(uri);
      final response = await _dio.getUri(uri);

      Logger().d(response);
      final advice = _extractText(response.data);
      if (advice == null) return null;

      final cleaned = advice.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (cleaned.isEmpty) return null;

      return cleaned.length > 180 ? '${cleaned.substring(0, 177)}...' : cleaned;
    } on DioException {
      return null;
    } catch (e, s) {
      Logger().e(e, stackTrace: s);
      return null;
    }
  }

  String _buildPrompt(
    String persona,
    List<Ticket> tickets,
    String fallbackAdvice,
  ) {
    final recentTickets = tickets
        .take(8)
        .map((ticket) {
          final routeNumber = ticket.route?.routeNumber ?? ticket.routeId;
          final start =
              ticket.boardingStop?.name ?? ticket.route?.startStopName;
          final end = ticket.dropoffStop?.name ?? ticket.route?.endStopName;
          final routeText = start != null && end != null
              ? '$routeNumber from $start to $end'
              : routeNumber;
          return '$routeText at ${ticket.purchasedAt.toIso8601String()} for ${ticket.fareAmount.toStringAsFixed(2)} ETB';
        })
        .join('; ');

    return [
      'You are SmartBus, a public bus travel assistant in Ethiopia.',
      'Write one helpful, specific travel insight for the passenger.',
      'Keep it under 28 words, friendly, and practical.',
      'Do not mention that you are an AI.',
      'Persona: $persona.',
      'Recent ticket history: $recentTickets.',
      'If uncertain, adapt this baseline advice: $fallbackAdvice',
    ].join(' ');
  }

  String? _extractText(dynamic data) {
    if (data == null) return null;
    if (data is String) return data;
    if (data is Map<String, dynamic>) {
      final choices = data['choices'];
      if (choices is List && choices.isNotEmpty) {
        final first = choices.first;
        if (first is Map<String, dynamic>) {
          final message = first['message'];
          if (message is Map<String, dynamic>) {
            return message['content']?.toString();
          }
          return first['text']?.toString();
        }
      }
      return data['text']?.toString() ?? data['content']?.toString();
    }
    return data.toString();
  }
}
