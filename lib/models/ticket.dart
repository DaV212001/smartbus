import 'route.dart';
import 'stop_tcs.dart';

class Ticket {
  final String id;
  final String passengerId;
  final String routeId;
  final String boardingStopId;
  final String dropoffStopId;
  final double fareAmount; // In Birr
  final String status;
  final String? qrPayload;
  final String? qrSignature;
  final DateTime purchasedAt;
  final DateTime? expiresAt;
  final DateTime? usedAt;
  final DateTime? refundedAt;
  final Route? route;
  final Stop? boardingStop;
  final Stop? dropoffStop;

  Ticket({
    required this.id,
    required this.passengerId,
    required this.routeId,
    required this.boardingStopId,
    required this.dropoffStopId,
    required this.fareAmount,
    required this.status,
    this.qrPayload,
    this.qrSignature,
    required this.purchasedAt,
    this.expiresAt,
    this.usedAt,
    this.refundedAt,
    this.route,
    this.boardingStop,
    this.dropoffStop,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'],
      passengerId: json['passengerId'],
      routeId: json['routeId'],
      boardingStopId: json['boardingStopId'],
      dropoffStopId: json['dropoffStopId'],
      fareAmount: (json['fareAmount'] is num ? json['fareAmount'].toDouble() : 0.0) / 100,
      status: json['status'],
      qrPayload: json['qrPayload'],
      qrSignature: json['qrSignature'],
      purchasedAt: DateTime.parse(json['purchasedAt'] ?? json['createdAt']),
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      usedAt: json['usedAt'] != null ? DateTime.parse(json['usedAt']) : null,
      refundedAt: json['refundedAt'] != null ? DateTime.parse(json['refundedAt']) : null,
      route: json['route'] != null ? Route.fromJson(json['route']) : null,
      boardingStop: json['boardingStop'] != null
          ? Stop.fromJson(json['boardingStop'], isDeparture: true, isDestination: false)
          : null,
      dropoffStop: json['dropoffStop'] != null
          ? Stop.fromJson(json['dropoffStop'], isDeparture: false, isDestination: true)
          : null,
    );
  }
}
