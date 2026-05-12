import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RouteCardStandard extends StatelessWidget {
  final String routeId;
  final String routeName;
  final String fare;
  final String startStop;
  final String endStop;
  final String duration;
  final String stopsCount;
  final String? frequency;

  const RouteCardStandard({
    super.key,
    required this.routeId,
    required this.routeName,
    required this.fare,
    required this.startStop,
    required this.endStop,
    required this.duration,
    required this.stopsCount,
    this.frequency,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        '/route-detail',
        arguments: {
          'routeId': routeId,
          'route': routeName,
          'price': fare,
          'start': startStop,
          'end': endStop,
        },
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          ),
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
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
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    routeName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                      fontSize: 13,
                    ),
                  ),
                ),
                Text(
                  fare,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStopColumn(startStop, context, isStart: true),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Divider(
                          color: Theme.of(
                            context,
                          ).dividerColor.withValues(alpha: 0.5),
                          thickness: 1,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          color: Theme.of(context).cardColor,
                          child: Text(
                            duration,
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(
                                context,
                              ).textTheme.bodySmall?.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildStopColumn(endStop, context, isStart: false),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoTag(Icons.map, stopsCount, context),
                if (frequency != null) ...[
                  const SizedBox(width: 12),
                  _buildInfoTag(Icons.access_time, frequency!, context),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStopColumn(
    String name,
    BuildContext context, {
    required bool isStart,
  }) {
    return Column(
      crossAxisAlignment: isStart
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        Text(
          isStart ? "Departure" : "Destination",
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTag(IconData icon, String text, BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }
}
