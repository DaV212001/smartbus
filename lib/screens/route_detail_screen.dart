import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbus/models/stop_tcs.dart';
import 'package:smartbus/screens/ticket_detail_screen.dart';

import '../controllers/route_controller.dart';
import '../controllers/ticket_controller.dart';
import '../models/route.dart' as model;

class RouteDetailScreen extends StatefulWidget {
  const RouteDetailScreen({super.key});

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  final routeController = Get.find<RouteController>();
  final ticketController = Get.put(TicketController());

  final selectedFromStop = ''.obs;
  final selectedToStop = ''.obs;
  final selectedFromStopId = ''.obs;
  final selectedToStopId = ''.obs;

  Worker? _worker;

  @override
  void initState() {
    super.initState();
    final Map<String, dynamic> args = Get.arguments ?? {};
    final String? routeId = args['routeId'];
    if (routeId != null) {
      Future.microtask(() => routeController.fetchRouteById(routeId));
    }

    // Initialize stop selections when route details are loaded
    _worker = ever(routeController.selectedRouteDetails, (route) {
      if (route != null) {
        final stops = route.stops ?? [];
        if (selectedFromStop.isEmpty && stops.isNotEmpty) {
          final firstStop = stops.first;
          selectedFromStop.value = firstStop.name;
          selectedFromStopId.value = firstStop.id?.toString() ?? '';
        }
        if (selectedToStop.isEmpty && stops.isNotEmpty) {
          final lastStop = stops.last;
          selectedToStop.value = lastStop.name;
          selectedToStopId.value = lastStop.id?.toString() ?? '';
        }
      }
    });
  }

  @override
  void dispose() {
    _worker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final String routeName = args['route'] ?? 'route_details'.tr;
    final String destination = args['end'] ?? 'destination'.tr;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          routeName,
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.share_outlined,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Theme.of(context).dividerColor, height: 1),
        ),
      ),
      body: Obx(() {
        if (routeController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final route = routeController.selectedRouteDetails.value;
        if (route == null) {
          return Center(child: Text("route_details_not_found".tr));
        }

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(
                bottom: 160,
              ), // Space for bottom UI
              child: Column(
                children: [
                  // 1. Active Trip Card
                  Obx(() {
                    final activeTicket = ticketController.activeTicket.value;
                    final currentRouteId =
                        route.id?.toString() ??
                        args['routeId']?.toString() ??
                        '';
                    final ticketRouteId = activeTicket?.routeId;

                    if (activeTicket != null &&
                        ticketRouteId == currentRouteId) {
                      return ActiveTripCard();
                    }
                    return const SizedBox.shrink();
                  }),

                  // 2. Route Stats Bar
                  RouteStatsBar(route: route),

                  // 3. Stop Selectors (From/To)
                  Obx(
                    () => StopSelectors(
                      selectedFrom: selectedFromStop.value,
                      selectedTo: selectedToStop.value,
                      onFromTap: () => _showStopPicker(
                        context,
                        "Select Starting Stop",
                        (name, id) {
                          selectedFromStop.value = name;
                          selectedFromStopId.value = id;
                        },
                        route.stops ?? [],
                      ),
                      onToTap: () => _showStopPicker(
                        context,
                        "Select Destination Stop",
                        (name, id) {
                          selectedToStop.value = name;
                          selectedToStopId.value = id;
                        },
                        route.stops ?? [],
                      ),
                    ),
                  ),

                  // 4. Timeline
                  RouteTimeline(stops: route.stops ?? []),
                ],
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        final route = routeController.selectedRouteDetails.value;
        return ActionBar(
          routeId: route?.id?.toString() ?? args['routeId']?.toString() ?? '',
          boardingStopId: selectedFromStopId.value,
          dropoffStopId: selectedToStopId.value,
          fare: route?.price?.toStringAsFixed(2) ?? '0.00',
        );
      }),
    );
  }

  void _showStopPicker(
    BuildContext context,
    String title,
    Function(String, String) onSelect,
    List<dynamic> stops,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: stops.length,
                itemBuilder: (context, index) {
                  final stop = stops[index];
                  final stopName = stop is Map ? stop['name'] : stop.name;
                  final stopId = stop is Map
                      ? stop['id']?.toString()
                      : stop.id?.toString();
                  return ListTile(
                    title: Text(stopName ?? 'N/A'),
                    onTap: () {
                      onSelect(stopName ?? 'N/A', stopId ?? '');
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActiveTripCard extends StatelessWidget {
  ActiveTripCard({super.key});
  final ticketController = Get.isRegistered<TicketController>()
      ? Get.find<TicketController>()
      : Get.put(TicketController());
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "current_trip".tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "live".tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Get.to(
                () => TicketDetailScreen(),
                arguments: {'id': ticketController.activeTicket.value?.id},
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.qr_code, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        "view_active_ticket".tr,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  Icon(Icons.chevron_right, color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.front_hand, color: Colors.red, size: 18),
            label: Text(
              "request_weraj".tr,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RouteStatsBar extends StatelessWidget {
  final model.Route route;
  const RouteStatsBar({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    final distance = '${((route.distance ?? 0) / 1000).toStringAsFixed(0)}km';
    final stopsCount = (route.stops?.length ?? 0).toString();
    final estTime = '${route.duration ?? 0}min';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStat(context, "distance_label".tr, distance),
          _buildStat(context, "stops_label".tr, stopsCount),
          _buildStat(context, "est_time_label".tr, estTime),
        ],
      ),
    );
  }

  Widget _buildStat(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }
}

class StopSelectors extends StatelessWidget {
  final String selectedFrom;
  final String selectedTo;
  final VoidCallback onFromTap;
  final VoidCallback onToTap;

  const StopSelectors({
    super.key,
    required this.selectedFrom,
    required this.selectedTo,
    required this.onFromTap,
    required this.onToTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildRow(context, "from_label".tr, selectedFrom, onFromTap),
          const SizedBox(height: 12),
          _buildRow(context, "to_label".tr, selectedTo, onToTap),
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    String label,
    String value,
    VoidCallback onTap,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const Icon(
                    Icons.expand_more,
                    size: 18,
                    color: Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class RouteTimeline extends StatelessWidget {
  final List<Stop> stops;
  const RouteTimeline({super.key, required this.stops});

  @override
  Widget build(BuildContext context) {
    stops.sort(
      (a, b) => (a.sequence ?? 0).toInt().compareTo((b.sequence ?? 0).toInt()),
    );
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "route_schedule".tr,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),
          if (stops.isEmpty)
            Text("no_stops_available".tr)
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stops.length,
              itemBuilder: (context, index) {
                final stop = stops[index];
                final isLast = index == stops.length - 1;
                final stopName = stop is Map ? stop.name : stop.name;
                final distanceToNext = stop is Map
                    ? (stop.distanceToNext ?? 0)
                    : (stop.distanceToNext ?? 0);
                final durationToNext = stop is Map
                    ? (stop.durationToNext ?? '--')
                    : (stop.durationToNext ?? '--');

                return _buildTimelineItem(
                  context,
                  stopName ?? 'stop'.tr + ' ${index + 1}',
                  isLast
                      ? ''
                      : 'to_next_stop'.trParams({'distance': '${(distanceToNext / 1000).toStringAsFixed(1)}km'}),
                  isLast ? '' : '$durationToNext ' + 'min_unit'.tr,
                  true,
                  !isLast,
                  isSelected: index == stops.length - 1, // Example logic
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    String title,
    String subtitle,
    String time,
    bool isActive,
    bool hasLine, {
    bool isSelected = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: isActive
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).cardColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive
                      ? Theme.of(context).primaryColor
                      : const Color(0xFF64748B),
                  width: 3,
                ),
              ),
            ),
            if (hasLine)
              Container(
                width: 2,
                height: 40,
                color: isActive
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).dividerColor,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Text(
                time,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ActionBar extends StatelessWidget {
  final String routeId;
  final String boardingStopId;
  final String dropoffStopId;
  final String fare;
  const ActionBar({
    super.key,
    required this.routeId,
    required this.boardingStopId,
    required this.dropoffStopId,
    required this.fare,
  });

  @override
  Widget build(BuildContext context) {
    final ticketController = Get.isRegistered<TicketController>()
        ? Get.find<TicketController>()
        : Get.put(TicketController());

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "total_fare".tr,
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              Text(
                "$fare ETB",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
            ],
          ),
          Obx(
            () => ElevatedButton.icon(
              onPressed: ticketController.isLoading.value
                  ? null
                  : () => ticketController.purchaseTicket(
                      routeId: routeId,
                      boardingStopId: boardingStopId,
                      dropoffStopId: dropoffStopId,
                    ),
              icon: ticketController.isLoading.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.confirmation_number_outlined,
                      size: 18,
                      color: Colors.white,
                    ),
              label: Text(
                ticketController.isLoading.value
                    ? "processing".tr
                    : "purchase_ticket".tr,
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
