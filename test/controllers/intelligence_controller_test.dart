// ignore_for_file: must_call_super

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:smartbus/controllers/intelligence_controller.dart';
import 'package:smartbus/controllers/ticket_controller.dart';
import 'package:smartbus/models/ticket.dart';
import 'package:smartbus/services/ai_travel_advice_service.dart';

class FakeTicketController extends TicketController {
  // Keep network-backed TicketController.onInit out of this unit test.
  @override
  void onInit() {}
}

class FakeAiTravelAdviceService extends AiTravelAdviceService {
  FakeAiTravelAdviceService(this.response);

  final String? response;
  String? requestedPersona;

  @override
  Future<String?> generateTravelAdvice({
    required String persona,
    required List<Ticket> tickets,
    required String fallbackAdvice,
  }) async {
    requestedPersona = persona;
    return response;
  }
}

void main() {
  setUp(() {
    Get.testMode = true;
    Get.put<TicketController>(FakeTicketController());
  });

  tearDown(Get.reset);

  test('analyzeHistory replaces local fallback with AI model advice', () async {
    final aiService = FakeAiTravelAdviceService(
      'Route R1 is your regular ride. Top up before the morning rush.',
    );
    final controller = IntelligenceController(aiTravelAdviceService: aiService);
    Get.put<IntelligenceController>(controller);
    Get.find<TicketController>().ticketHistory.addAll([
      _ticket(routeId: 'r1', hour: 8),
      _ticket(routeId: 'r1', hour: 9),
      _ticket(routeId: 'r1', hour: 8),
      _ticket(routeId: 'r1', hour: 9),
    ]);

    await controller.analyzeHistory();

    expect(controller.userPersona.value, UserPersona.commuter);
    expect(aiService.requestedPersona, 'commuter');
    expect(
      controller.travelAdvice.value,
      'Route R1 is your regular ride. Top up before the morning rush.',
    );
    expect(controller.isGeneratingAdvice.value, false);
  });

  test('analyzeHistory keeps fallback advice when AI API fails', () async {
    final controller = IntelligenceController(
      aiTravelAdviceService: FakeAiTravelAdviceService(null),
    );
    Get.put<IntelligenceController>(controller);
    Get.find<TicketController>().ticketHistory.addAll([
      _ticket(routeId: 'r1', hour: 22),
      _ticket(routeId: 'r2', hour: 23),
      _ticket(routeId: 'r3', hour: 1),
    ]);

    await controller.analyzeHistory();

    expect(controller.userPersona.value, UserPersona.nightOwl);
    expect(controller.travelAdvice.value, contains('Traveling late'));
    expect(controller.isGeneratingAdvice.value, false);
  });
}

Ticket _ticket({required String routeId, required int hour}) {
  return Ticket(
    id: '$routeId-$hour',
    passengerId: 'passenger-1',
    routeId: routeId,
    boardingStopId: 'boarding',
    dropoffStopId: 'dropoff',
    fareAmount: 15,
    status: 'USED',
    purchasedAt: DateTime(2026, 5, 20, hour),
  );
}
