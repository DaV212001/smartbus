import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../controllers/ticket_controller.dart';
import '../models/ticket.dart';
import 'ticket_detail_screen.dart';

class TicketScreen extends StatelessWidget {
  const TicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TicketController());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        title: Text(
          'My Tickets',
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
        if (controller.isLoading.value && controller.ticketHistory.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: controller.fetchTickets,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller.activeTicket.value != null)
                  ActiveTicketSection(ticket: controller.activeTicket.value!)
                else
                  const NoActiveTicketSection(),
                HistorySection(history: controller.ticketHistory),
              ],
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
            'No Active Ticket',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Purchase a ticket to start your journey',
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
                          const Text(
                            'TO',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            ticket.dropoffStop?.name ?? 'Destination',
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
                          data: ticket.qrPayload ?? '',
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
                                  'Expires at $timeStr',
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
                          _buildInfo(context, 'Passenger', 'Adult (1)'),
                          _buildInfo(
                            context,
                            'Price',
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
            'Ticket History',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: theme.textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.search,
                  size: 18,
                  color: Color(0xFF94A3B8),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Search tickets...',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.listFilter,
                        size: 14,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Filter',
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (history.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Text(
                  'No ticket history found',
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
              ),
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
