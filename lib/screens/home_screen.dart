import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/route_controller.dart';

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
          CircleAvatar(
            backgroundColor: Theme.of(context).cardColor,
            child: Icon(Icons.person, color: Theme.of(context).iconTheme.color),
          ),
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
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
            // border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Row(
            children: const [
              Icon(Icons.search, color: Color(0xFF94A3B8)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Search route, stop, or destination",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    final filters = ["All Routes", "Price", "Recent", "Saved"];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final isActive = index == 0;
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8),
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
              filters[index],
              style: TextStyle(
                color: isActive
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
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

  Widget _buildRouteList(BuildContext context) {
    final routeController = Get.find<RouteController>();
    return Obx(() {
      if (routeController.isLoading.value && routeController.routes.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (routeController.routes.isEmpty) {
        return const Center(child: Text("No routes available"));
      }

      return RefreshIndicator(
        onRefresh: routeController.fetchRoutes,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: routeController.routes.length,
          itemBuilder: (context, index) {
            final route = routeController.routes[index];
            return RouteCard(
              routeId: route.id?.toString() ?? '',
              route: route.routeNumber ?? 'Route',
              price: "${route.price?.toStringAsFixed(2) ?? '0.00'} ETB",
              start: route.startStopName ?? 'Start',
              end: route.endStopName ?? 'End',
              duration: "${route.duration ?? '0'} mins",
              stops: "${route.totalStops ?? '0'} stops",
            );
          },
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
  final String routeId, route, price, start, end, duration, stops;

  const RouteCard({
    super.key,
    required this.routeId,
    required this.route,
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
          'route': route,
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFD166),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    route,
                    style: TextStyle(fontWeight: FontWeight.bold),
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
