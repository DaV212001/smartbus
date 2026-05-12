import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/route_controller.dart';
import '../widgets/cards/route_card_standard.dart';

class RouteSearchScreen extends StatelessWidget {
  const RouteSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final routeController = Get.find<RouteController>();
    final searchController = TextEditingController();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Find Route",
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _searchSection(context, routeController, searchController),
                    _sectionHeader(context),
                    _routeList(context, routeController),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= SEARCH =================
  Widget _searchSection(
    BuildContext context,
    RouteController controller,
    TextEditingController textController,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        border: Border(
          // bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Where to?",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              // Connector line
              Positioned(
                left: 23,
                top: 30,
                bottom: 30,
                child: Container(
                  width: 2,
                  color: Theme.of(context).dividerColor,
                ),
              ),
              Column(
                children: [
                  _SearchField(
                    icon: Icons.circle,
                    hint: "Departure Stop",
                    context: context,
                  ),
                  const SizedBox(height: 12),
                  _SearchField(
                    icon: Icons.location_on,
                    hint: "Destination Stop",
                    context: context,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _filters(context),
        ],
      ),
    );
  }

  Widget _filters(BuildContext context) {
    final filters = ["Lowest Price", "Fastest", "Route #"];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, i) {
          final active = i == 0;
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: active
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: active
                  ? null
                  : Border.all(color: Theme.of(context).dividerColor),
            ),
            alignment: Alignment.center,
            child: Text(
              filters[i],
              style: TextStyle(
                color: active
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 13,
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= SECTION =================
  Widget _sectionHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Available Routes",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
      ),
    );
  }

  // ================= ROUTES =================
  Widget _routeList(BuildContext context, RouteController controller) {
    return Obx(() {
      final list =
          controller.searchResults.isEmpty && !controller.isLoading.value
          ? controller.routes
          : controller.searchResults;

      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: list.map((route) {
            return RouteCardStandard(
              routeId: route.id?.toString() ?? '',
              routeName: route.routeNumber ?? 'Route',
              fare: "${route.price?.toStringAsFixed(2) ?? '0.00'} ETB",
              startStop: route.startStopName ?? 'Start',
              endStop: route.endStopName ?? 'End',
              duration: "${route.duration ?? '0'}m",
              stopsCount: "${route.totalStops ?? '0'} stops",
              frequency: "Every 15 min",
            );
          }).toList(),
        ),
      );
    });
  }

  // ================= NAV =================
  Widget _bottomNav() {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: Color(0xFF0066CC),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.map), label: "Routes"),
        BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: "My Ticket"),
        BottomNavigationBarItem(icon: Icon(Icons.wallet), label: "Wallet"),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: "Alerts",
        ),
      ],
    );
  }
}

// ================= SEARCH FIELD =================
class _SearchField extends StatelessWidget {
  final IconData icon;
  final String hint;
  final BuildContext context;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const _SearchField({
    required this.icon,
    required this.hint,
    required this.context,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          prefixIcon: Icon(
            icon,
            size: 18,
            color: Theme.of(context).primaryColor,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
