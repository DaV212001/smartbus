// import 'package:get/get.dart';
// import 'package:logger/logger.dart';
// import 'package:smartbus/controllers/ticket_controller.dart';
//
// import '../models/ticket.dart';
// import '../services/ai_travel_advice_service.dart';
//
// enum UserPersona { commuter, explorer, occasional, nightOwl }
//
// class IntelligenceController extends GetxController {
//   IntelligenceController({AiTravelAdviceService? aiTravelAdviceService})
//     : _aiTravelAdviceService = aiTravelAdviceService ?? AiTravelAdviceService();
//
//   final AiTravelAdviceService _aiTravelAdviceService;
//   final userPersona = UserPersona.occasional.obs;
//   final travelAdvice = "".obs;
//   final isGeneratingAdvice = false.obs;
//
//   /// Whether to show a welcome insight for brand new users with no history.
//   /// Set to false to hide the AI card entirely until the first ticket is purchased.
//   static const bool showWelcomeForNewUsers = false;
//
//   @override
//   void onInit() {
//     super.onInit();
//     // Re-analyze whenever ticket history changes
//     final ticketController = Get.find<TicketController>();
//     ever(ticketController.ticketHistory, (_) => analyzeHistory());
//
//     // Initial analysis if history already exists
//     if (ticketController.ticketHistory.isNotEmpty || showWelcomeForNewUsers) {
//       analyzeHistory();
//     }
//   }
//
//   Future<void> analyzeHistory() async {
//     Logger().d('called');
//     final tickets = Get.find<TicketController>().ticketHistory;
//
//     if (tickets.isEmpty) {
//       userPersona.value = UserPersona.occasional;
//       if (showWelcomeForNewUsers) {
//         travelAdvice.value = _buildOccasionalAdvice();
//       } else {
//         travelAdvice.value = "";
//       }
//       return;
//     }
//
//     // 1. Check for Night Owl (Trips between 8 PM and 4 AM)
//     final nightTrips = tickets.where((t) {
//       // Use purchasedAt or createdAt depending on model
//       final hour = t.purchasedAt.hour;
//       return hour >= 20 || hour <= 4;
//     }).length;
//
//     if (nightTrips >= 3 ||
//         (tickets.length >= 2 && nightTrips / tickets.length > 0.5)) {
//       userPersona.value = UserPersona.nightOwl;
//       await _generateAiAdvice(
//         tickets: tickets,
//         fallbackAdvice: _buildNightOwlAdvice(),
//       );
//       return;
//     }
//
//     // 2. Check for Explorer (Many unique routes)
//     final uniqueRoutes = tickets.map((t) => t.routeId).toSet().length;
//     if (uniqueRoutes >= 5 ||
//         (tickets.length >= 5 && uniqueRoutes / tickets.length > 0.7)) {
//       userPersona.value = UserPersona.explorer;
//       await _generateAiAdvice(
//         tickets: tickets,
//         fallbackAdvice: _buildExplorerAdvice(),
//       );
//       return;
//     }
//
//     // 3. Check for Commuter (Frequent trips on same route/time patterns)
//     // Simplified: more than 10 tickets total or 5+ on same route
//     final routeCounts = <String, int>{};
//     for (var t in tickets) {
//       routeCounts[t.routeId] = (routeCounts[t.routeId] ?? 0) + 1;
//     }
//     final maxRouteFreq = routeCounts.values.isEmpty
//         ? 0
//         : routeCounts.values.reduce((a, b) => a > b ? a : b);
//
//     if (tickets.length >= 8 || maxRouteFreq >= 4) {
//       userPersona.value = UserPersona.commuter;
//       await _generateAiAdvice(
//         tickets: tickets,
//         fallbackAdvice: _buildCommuterAdvice(tickets),
//       );
//       return;
//     }
//
//     // Default: Occasional
//     userPersona.value = UserPersona.occasional;
//     await _generateAiAdvice(
//       tickets: tickets,
//       fallbackAdvice: _buildOccasionalAdvice(),
//     );
//   }
//
//   Future<void> _generateAiAdvice({
//     required List<Ticket> tickets,
//     required String fallbackAdvice,
//   }) async {
//     Logger().d('called');
//     travelAdvice.value = fallbackAdvice;
//     isGeneratingAdvice.value = true;
//
//     final aiAdvice = await _aiTravelAdviceService.generateTravelAdvice(
//       persona: userPersona.value.name,
//       tickets: tickets,
//       fallbackAdvice: fallbackAdvice,
//     );
//     Logger().d(aiAdvice);
//
//     if (aiAdvice != null) {
//       travelAdvice.value = aiAdvice;
//     }
//
//     isGeneratingAdvice.value = false;
//   }
//
//   String _buildCommuterAdvice(List<Ticket> tickets) {
//     // Find most frequent route
//     final routeCounts = <String, int>{};
//     for (var t in tickets) {
//       routeCounts[t.routeId] = (routeCounts[t.routeId] ?? 0) + 1;
//     }
//
//     String? topRoute;
//     int maxCount = 0;
//     routeCounts.forEach((id, count) {
//       if (count > maxCount) {
//         maxCount = count;
//         topRoute = id;
//       }
//     });
//
//     if (topRoute != null) {
//       // Find route name from most recent ticket of that route
//       final recent = tickets.firstWhere((t) => t.routeId == topRoute);
//       final routeNum = recent.route?.routeNumber ?? "your regular";
//       return "You frequently use Route $routeNum. Consider topping up your wallet with 200 ETB for a week of hassle-free commuting.";
//     }
//
//     return "Welcome back! Don't forget to check for route updates before your morning commute.";
//   }
//
//   String _buildExplorerAdvice() {
//     return "You're quite the explorer! Check out the new routes added this week in the 'Routes' tab.";
//   }
//
//   String _buildNightOwlAdvice() {
//     return "Traveling late? Most routes have reduced frequency after 9 PM. Make sure your wallet has enough balance to avoid delays.";
//   }
//
//   String _buildOccasionalAdvice() {
//     if (Get.find<TicketController>().ticketHistory.isEmpty) {
//       return "Welcome to SmartBus! Buy your first ticket to see personalized travel insights here.";
//     }
//
//     return "Ready for your next trip? Use the search bar to find the fastest route to your destination.";
//   }
// }
