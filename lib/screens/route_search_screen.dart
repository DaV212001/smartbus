import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/route_controller.dart';
import '../utils/api_call_status.dart';
import 'home_screen.dart';

class RouteSearchScreen extends StatefulWidget {
  const RouteSearchScreen({super.key});

  @override
  State<RouteSearchScreen> createState() => _RouteSearchScreenState();
}

class _RouteSearchScreenState extends State<RouteSearchScreen> {
  final routeController = Get.find<RouteController>();
  final departureTextController = TextEditingController();
  final destinationTextController = TextEditingController();

  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    departureTextController.dispose();
    destinationTextController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      routeController.searchRoutesAdvanced(
        departure: departureTextController.text.trim(),
        destination: destinationTextController.text.trim(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
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
          "find_route".tr,
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
                    _searchSection(context),
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
  Widget _searchSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "where_to".tr,
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
                    hint: "departure_stop".tr,
                    context: context,
                    controller: departureTextController,
                    onChanged: (value) => _onSearchChanged(),
                  ),
                  const SizedBox(height: 12),
                  _SearchField(
                    icon: Icons.location_on,
                    hint: "destination_stop".tr,
                    context: context,
                    controller: destinationTextController,
                    onChanged: (value) => _onSearchChanged(),
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
    final List<Map<String, String>> filters = [
      {"label": "filter_lowest_price".tr, "key": "price", "order": "asc"},
      {"label": "filter_fastest".tr, "key": "duration", "order": "asc"},
      {"label": "filter_route_num".tr, "key": "routeNumber", "order": "asc"},
    ];

    return SizedBox(
      height: 40,
      child: Obx(() {
        final activeSortBy = routeController.currentSortBy.value;

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          itemBuilder: (context, i) {
            final filter = filters[i];
            final String key = filter["key"]!;
            final String order = filter["order"]!;
            final bool isActive = activeSortBy == key;

            return GestureDetector(
              onTap: () {
                routeController.currentSortBy.value = key;
                routeController.currentSortOrder.value = order;
                routeController.applyClientSortToSearchResults();
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isActive
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  border: isActive
                      ? null
                      : Border.all(color: Theme.of(context).dividerColor),
                ),
                alignment: Alignment.center,
                child: Text(
                  filter["label"]!,
                  style: TextStyle(
                    color: isActive
                        ? Colors.white
                        : Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // ================= SECTION =================
  Widget _sectionHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "available_routes".tr,
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
    final theme = Theme.of(context);
    return Obx(() {
      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 40.0),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.searchStatus.value == ApiCallStatus.empty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 48,
                  color: theme.disabledColor,
                ),
                const SizedBox(height: 12),
                Text(
                  'no_routes_found'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.7,
                    ),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final list =
          controller.searchResults.isEmpty && !controller.isLoading.value
          ? controller.routes
          : controller.searchResults;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: list.map((route) {
            return RouteCard(
              routeId: route.id?.toString() ?? '',
              routeName: route.routeNumber ?? 'Route',
              price: "${route.price?.toStringAsFixed(2) ?? '0.00'} ETB",
              start: route.startStopName ?? 'Start',
              end: route.endStopName ?? 'End',
              duration: "${route.duration ?? '0'} mins",
              stops: "${route.totalStops ?? '0'} stops",
            );
          }).toList(),
        ),
      );
    });
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
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
        ),
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
