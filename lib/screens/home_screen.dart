import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:smartbus/controllers/theme_mode_controller.dart';

import '../controllers/route_controller.dart';
import '../utils/animations.dart';
import '../utils/templates/loaded_widgets_template.dart';
import '../utils/wrappers/shimmer_wrapper.dart';

final routeCardAnimation = AnimationInfo(
  trigger: AnimationTrigger.onPageLoad,
  effects: [
    FadeEffect(
      curve: Curves.easeInOut,
      delay: Duration.zero,
      duration: const Duration(milliseconds: 600),
      begin: 0.0,
      end: 1.0,
    ),
    MoveEffect(
      curve: Curves.easeInOut,
      delay: Duration.zero,
      duration: const Duration(milliseconds: 600),
      begin: const Offset(0.0, 30.0),
      end: const Offset(0.0, 0.0),
    ),
  ],
);

final searchBarAnimation = AnimationInfo(
  trigger: AnimationTrigger.onPageLoad,
  effects: [
    FadeEffect(
      curve: Curves.easeInOut,
      delay: const Duration(milliseconds: 100),
      duration: const Duration(milliseconds: 500),
      begin: 0.0,
      end: 1.0,
    ),
    MoveEffect(
      curve: Curves.easeInOut,
      delay: const Duration(milliseconds: 100),
      duration: const Duration(milliseconds: 500),
      begin: const Offset(0.0, -10.0),
      end: const Offset(0.0, 0.0),
    ),
  ],
);

final filterAnimation = AnimationInfo(
  trigger: AnimationTrigger.onPageLoad,
  effects: [
    FadeEffect(
      curve: Curves.easeInOut,
      delay: const Duration(milliseconds: 200),
      duration: const Duration(milliseconds: 500),
      begin: 0.0,
      end: 1.0,
    ),
  ],
);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final routeController = Get.put(RouteController());
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearchBar(context),
            _buildFilters(context),
            _buildSectionTitle(context),
            Expanded(child: _buildRouteList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "SmartBus",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          // CircleAvatar(
          //   backgroundColor: Theme.of(context).cardColor,
          //   child: Icon(Icons.person, color: Theme.of(context).iconTheme.color),
          // ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed('/route-search'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            // border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Color(0xFF94A3B8)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "search_prompt".tr,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF94A3B8)),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animateOnPageLoad(searchBarAnimation).animateOnPress();
  }

  Widget _buildFilters(BuildContext context) {
    final routeController = Get.find<RouteController>();
    final filters = [
      {"label": "filter_recent".tr, "sortBy": "createdAt", "sortOrder": "desc"},
      {"label": "filter_price_low".tr, "sortBy": "price", "sortOrder": "asc"},
      {"label": "filter_price_high".tr, "sortBy": "price", "sortOrder": "desc"},
      {"label": "filter_duration".tr, "sortBy": "duration", "sortOrder": "asc"},
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];

          return Obx(() {
            final isActive =
                routeController.currentSortBy.value == filter['sortBy'] &&
                routeController.currentSortOrder.value == filter['sortOrder'];
            return GestureDetector(
              onTap: () {
                // routeController.currentSortBy.value = filter['sortBy']!;
                // routeController.currentSortOrder.value = filter['sortOrder']!;
                routeController.fetchRoutes(
                  sortBy: filter['sortBy'],
                  sortOrder: filter['sortOrder'],
                );
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isActive
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: isActive
                      ? null
                      : Border.all(
                          color: Theme.of(
                            context,
                          ).dividerColor.withValues(alpha: 0.15),
                        ),
                ),
                alignment: Alignment.center,
                child: Text(
                  filter['label']!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive
                        ? Colors.white
                        : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ).animateOnPress();
          });
        },
      ),
    ).animateOnPageLoad(filterAnimation);
  }

  Widget _buildSectionTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
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

  Widget _buildRouteList(BuildContext context) {
    final routeController = Get.find<RouteController>();
    return Obx(() {
      Widget shimmerLoading() {
        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: 4,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor),
                  color: Theme.of(context).cardColor,
                ),
                child: ShimmerWrapper(
                  isEnabled: true,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 80,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            Container(
                              width: 60,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Row(
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(
                                  height: 24,
                                  child: VerticalDivider(color: Colors.grey),
                                ),
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 12.0,
                                    ),
                                    child: Container(
                                      width: 150,
                                      height: 14,
                                      color: Colors.grey[300],
                                    ),
                                  ),
                                  // const SizedBox(height: 12),
                                  Container(
                                    width: 120,
                                    height: 14,
                                    color: Colors.grey[300],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // const SizedBox(height: 20),
                      Row(
                        children: [
                          Container(
                            width: 80,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 80,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }

      return LoadedWidget(
        apiCallStatus: routeController.routesStatus.value,
        errorData: routeController.routesError.value,
        loadingChild: shimmerLoading(),
        onReload: () => routeController.fetchRoutes(page: 1),
        errorChild: null,
        child:
            // shimmerLoading(),
            routeController.routes.isEmpty
            ? const Center(child: Text("No routes available"))
            : RefreshIndicator(
                onRefresh: () => routeController.fetchRoutes(page: 1),
                child: ListView.builder(
                  controller: routeController.scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount:
                      routeController.routes.length +
                      (routeController.isLoadingMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == routeController.routes.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final route = routeController.routes[index];
                    return RouteCard(
                      routeId: route.id?.toString() ?? '',
                      routeName: route.routeNumber ?? 'Route',
                      price: "${route.price?.toStringAsFixed(2) ?? '0.00'} ETB",
                      start: route.startStopName ?? 'Start',
                      end: route.endStopName ?? 'End',
                      duration: "${route.duration ?? '0'} mins",
                      stops: "${route.totalStops ?? '0'} stops",
                    ).animateOnPageLoad(routeCardAnimation).animateOnPress();
                  },
                ),
              ),
      );
    });
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: Color(0xFF0B66B2),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Routes"),
        BottomNavigationBarItem(icon: Icon(Icons.wallet), label: "Wallet"),
        BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: "Ticket"),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: "Alerts",
        ),
      ],
    );
  }
}

class RouteCard extends StatelessWidget {
  final String routeId, routeName, price, start, end, duration, stops;

  const RouteCard({
    super.key,
    required this.routeId,
    required this.routeName,
    required this.price,
    required this.start,
    required this.end,
    required this.duration,
    required this.stops,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        '/route-detail',
        arguments: {
          'routeId': routeId,
          'route': routeName,
          'price': price,
          'start': start,
          'end': end,
        },
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
          color: Theme.of(context).cardColor,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeModeController.isLightTheme.value
                          ? Color(0xFFFFD166)
                          : Colors.amber,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      routeName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                Text(
                  price,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Column(
                  children: [
                    Icon(Icons.circle, size: 10, color: Colors.grey),
                    SizedBox(
                      height: 24,
                      child: VerticalDivider(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    Icon(
                      Icons.circle,
                      size: 10,
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        start,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        end,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(height: 20, color: Theme.of(context).dividerColor),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Text(
                  duration,
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                ),
                const SizedBox(width: 16),
                Icon(Icons.location_on, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Text(
                  stops,
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
