import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../controllers/ticket_detail_controller.dart';

import '../models/ticket.dart';

class TicketDetailScreen extends StatelessWidget {
  TicketDetailScreen({super.key});
  final controller = Get.put(TicketDetailController());
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final String? ticketId = args['id'] ?? args['ticketId'];
    final theme = Theme.of(context);

    if (ticketId != null && controller.ticket.value == null) {
      Future.microtask(() => controller.fetchTicketDetail(ticketId));
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Ticket Details',
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              LucideIcons.share2,
              color: theme.iconTheme.color,
              size: 20,
            ),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: theme.dividerColor, height: 1),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final ticket = controller.ticket.value;
        if (ticket == null) {
          return const Center(child: Text('Ticket not found'));
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchTicketDetail(ticketId!),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 1. Main Ticket Card
                _buildTicketCard(context, ticket),
                const SizedBox(height: 24),

                // 2. Journey Information
                _buildJourneyInfo(context, ticket),
                const SizedBox(height: 24),

                // 3. Transaction Details
                _buildDetailsSection(context, ticket),
                const SizedBox(height: 32),

                // 4. Action Buttons
                _buildActions(context),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTicketCard(BuildContext context, Ticket ticket) {
    final theme = Theme.of(context);
    final status = ticket.status.toUpperCase();
    final isExpired = status == 'EXPIRED';

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.route?.routeNumber ?? 'N/A',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      ticket.route?.name ?? 'Route Name',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body with QR
          Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor, width: 2),
                  ),
                  child: Opacity(
                    opacity: isExpired ? 0.3 : 1.0,
                    child: QrImageView(
                      data: ticket.qrPayload ?? '',
                      version: QrVersions.auto,
                      size: 200.0,
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
                ),
                if (isExpired)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      'TICKET EXPIRED',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Text(
                  'Ticket ID: ${ticket.id.substring(0, 8).toUpperCase()}',
                  style: TextStyle(
                    color: theme.textTheme.bodySmall?.color,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyInfo(BuildContext context, Ticket ticket) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'JOURNEY DETAILS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF64748B),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                  Container(width: 2, height: 40, color: theme.dividerColor),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.primaryColor, width: 3),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    _buildStopInfo(
                      context,
                      'Boarding From',
                      ticket.boardingStop?.name ?? 'Starting Stop',
                    ),
                    const SizedBox(height: 24),
                    _buildStopInfo(
                      context,
                      'Dropping At',
                      ticket.dropoffStop?.name ?? 'Destination Stop',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStopInfo(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(
    BuildContext context,
    Ticket ticket,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TRANSACTION DETAILS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF64748B),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            children: [
              _buildDetailRow(
                context,
                'Fare Amount',
                '${ticket.fareAmount.toStringAsFixed(2)} ETB',
              ),
              const Divider(height: 24),
              _buildDetailRow(
                context,
                'Purchased On',
                _formatDate(ticket.purchasedAt),
              ),
              const Divider(height: 24),
              _buildDetailRow(
                context,
                'Expires At',
                _formatDate(ticket.expiresAt),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    final theme = Theme.of(context);
    final ticket = controller.ticket.value;
    return Column(
      children: [
        if (ticket?.status == 'ACTIVE')
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.front_hand, color: Colors.red, size: 18),
            label: const Text(
              "Request Weraj (Drop-off)",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        const SizedBox(height: 12),
        // OutlinedButton.icon(
        //   onPressed: () {},
        //   icon: const Icon(LucideIcons.helpCircle, size: 18),
        //   label: const Text('Report an Issue'),
        //   style: OutlinedButton.styleFrom(
        //     minimumSize: const Size(double.infinity, 54),
        //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        //     side: BorderSide(color: theme.dividerColor),
        //   ),
        // ),
      ],
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final DateTime dateTime = date is DateTime ? date : DateTime.parse(date.toString());
      final localizedDate = dateTime.toUtc().add(const Duration(hours: 3));
      return DateFormat('MMM dd, yyyy • HH:mm').format(localizedDate);
    } catch (e) {
      return date.toString();
    }
  }
}
