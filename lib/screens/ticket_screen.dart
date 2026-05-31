import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../controllers/ticket_controller.dart';
import '../models/ticket.dart';
import '../utils/animations.dart';
import '../utils/templates/loaded_widgets_template.dart';
import '../utils/wrappers/shimmer_wrapper.dart';
import 'ticket_detail_screen.dart';

final ticketCardAnimation = AnimationInfo(
  trigger: AnimationTrigger.onPageLoad,
  effects: [
    FadeEffect(
      curve: Curves.easeInOut,
      delay: Duration.zero,
      duration: const Duration(milliseconds: 600),
      begin: 0.0,
      end: 1.0,
    ),
    ScaleEffect(
      curve: Curves.easeInOut,
      delay: Duration.zero,
      duration: const Duration(milliseconds: 600),
      begin: const Offset(0.95, 0.95),
      end: const Offset(1.0, 1.0),
    ),
  ],
);

final ticketHistoryAnimation = AnimationInfo(
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
      begin: const Offset(0.0, 20.0),
      end: const Offset(0.0, 0.0),
    ),
  ],
);

class TicketScreen extends StatelessWidget {
  TicketScreen({super.key});
  final controller = Get.put(TicketController());
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        title: Text(
          'my_tickets'.tr,
          style: TextStyle(
            color: theme.textTheme.titleMedium?.color,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: theme.dividerColor, height: 1),
        ),
      ),
      body: Obx(() {
        Widget shimmerLoading() {
          return SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerWrapper(
                  isEnabled: true,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      width: double.infinity,
                      height: 280,
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Text(
                    'ticket_history'.tr,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          border: Border.all(color: theme.dividerColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ShimmerWrapper(
                          isEnabled: true,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'title',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: theme.textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                  Text(
                                    'meta..........',
                                    style: const TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  // color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'status'.toUpperCase(),
                                  style: TextStyle(
                                    // color: statusColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        }

        return LoadedWidget(
          apiCallStatus: controller.ticketsStatus.value,
          errorData: controller.ticketsError.value,
          loadingChild: shimmerLoading(),
          errorChild: null,
          onReload: controller.fetchTickets,
          child:
              // shimmerLoading(),
              RefreshIndicator(
                onRefresh: controller.fetchTickets,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (controller.activeTicket.value != null)
                        ActiveTicketSection(
                              ticket: controller.activeTicket.value!,
                            )
                            .animateOnPageLoad(ticketCardAnimation)
                            .animateOnPress()
                      else
                        const NoActiveTicketSection().animateOnPageLoad(
                          ticketCardAnimation,
                        ),
                      HistorySection(history: controller.ticketHistory),
                    ],
                  ),
                ),
              ),
        );
      }),
    );
  }
}

class NoActiveTicketSection extends StatelessWidget {
  const NoActiveTicketSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          Icon(LucideIcons.qrCode, size: 64, color: theme.disabledColor),
          const SizedBox(height: 16),
          Text(
            'no_active_ticket'.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'purchase_ticket_description'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.textTheme.bodySmall?.color),
          ),
        ],
      ),
    );
  }
}

/// The main ticket card with the custom "rip" effect
class ActiveTicketSection extends StatelessWidget {
  final Ticket ticket;
  const ActiveTicketSection({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: GestureDetector(
        onTap: () =>
            Get.to(() => TicketDetailScreen(), arguments: {'id': ticket.id}),
        child: ClipPath(
          clipper: TicketClipper(),
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              children: [
                // Ticket Header
                Container(
                  padding: const EdgeInsets.all(16),
                  color: theme.primaryColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ticket.route?.routeNumber ?? 'N/A',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'to'.tr,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            ticket.dropoffStop?.name ?? 'destination'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Ticket Body
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // QR Placeholder
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: theme.dividerColor,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: QrImageView(
                          data: ticket.qrPayload != null
                              ? jsonEncode({
                                  'payload': ticket.qrPayload,
                                  'qrPayload': ticket.qrPayload,
                                  'qrSignature': ticket.qrSignature,
                                })
                              : '',
                          version: QrVersions.auto,
                          size: 150.0,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Colors.black,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Timer Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              LucideIcons.timer,
                              size: 16,
                              color: Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 6),
                            Builder(
                              builder: (context) {
                                String timeStr = 'N/A';
                                if (ticket.expiresAt != null) {
                                  try {
                                    DateTime utcTime = ticket.expiresAt!;
                                    // Localize to Ethiopian Time (UTC+3)
                                    DateTime ethiopianTime = utcTime
                                        .toUtc()
                                        .add(const Duration(hours: 3));
                                    timeStr = DateFormat(
                                      'HH:mm',
                                    ).format(ethiopianTime);
                                  } catch (e) {
                                    timeStr = 'N/A';
                                  }
                                }
                                return Text(
                                  'expires_at'.trParams({'time': timeStr}),
                                  style: const TextStyle(
                                    color: Color(0xFFF59E0B),
                                    fontWeight: FontWeight.w600,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Divider(thickness: 2, color: theme.dividerColor),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfo(context, 'passenger'.tr, 'adult_one'.tr),
                          _buildInfo(
                            context,
                            'price'.tr,
                            '${ticket.fareAmount.toStringAsFixed(2)} ETB',
                            crossAxis: CrossAxisAlignment.end,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfo(
    BuildContext context,
    String label,
    String value, {
    CrossAxisAlignment crossAxis = CrossAxisAlignment.start,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: crossAxis,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }
}

/// Section for historical tickets
class HistorySection extends StatelessWidget {
  final List<Ticket> history;
  const HistorySection({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ticket_history'.tr,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: theme.textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          if (history.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Text(
                  'no_ticket_history_found'.tr,
                  style: TextStyle(color: theme.disabledColor),
                ),
              ),
            )
          else
            ...history.map(
              (t) => _historyItem(
                context,
                t,
                '${t.route?.routeNumber ?? 'R--'} • ${t.dropoffStop?.name ?? 'Dest'}',
                t.purchasedAt.toString(),
                t.status,
                _getStatusColor(t.status),
              ).animateOnPageLoad(ticketHistoryAnimation).animateOnPress(),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'used':
        return Colors.grey;
      case 'expired':
        return Colors.redAccent;
      case 'refunded':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  Widget _historyItem(
    BuildContext context,
    Ticket ticket,
    String title,
    String meta,
    String status,
    Color statusColor,
  ) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () =>
          Get.to(() => TicketDetailScreen(), arguments: {'id': ticket.id}),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  meta,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom Clipper for the circular cut-outs on the ticket sides
class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, 72);
    path.arcToPoint(
      const Offset(0, 92),
      radius: const Radius.circular(10),
      clockwise: true,
    );
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 92);
    path.arcToPoint(
      Offset(size.width, 72),
      radius: const Radius.circular(10),
      clockwise: true,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
