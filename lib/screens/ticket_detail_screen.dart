import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../controllers/ticket_detail_controller.dart';
import '../models/ticket.dart';
import '../utils/templates/loaded_widgets_template.dart';
import '../utils/wrappers/shimmer_wrapper.dart';
import '../widgets/animated_widgets/loading_animation_button.dart';

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
          'ticket_details'.tr,
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
        Widget shimmerLoading() {
          return SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ShimmerWrapper(
                  isEnabled: true,
                  child: Container(
                    width: double.infinity,
                    height: 320,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ShimmerWrapper(
                  isEnabled: true,
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ShimmerWrapper(
                  isEnabled: true,
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final ticket = controller.ticket.value;

        return LoadedWidget(
          apiCallStatus: controller.detailStatus.value,
          errorData: controller.detailError.value,
          loadingChild: shimmerLoading(),
          errorChild: null,
          onReload: () => ticketId != null ? controller.fetchTicketDetail(ticketId) : null,
          child: ticket == null
              ? Center(child: Text('ticket_not_found'.tr))
              : RefreshIndicator(
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
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      'ticket_expired'.tr,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Text(
                  'ticket_id_label'.trParams({'id': ticket.id.substring(0, 8).toUpperCase()}),
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
        Text(
          'journey_details'.tr,
          style: const TextStyle(
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
                      'boarding_from'.tr,
                      ticket.boardingStop?.name ?? 'starting_stop'.tr,
                    ),
                    const SizedBox(height: 24),
                    _buildStopInfo(
                      context,
                      'dropping_at'.tr,
                      ticket.dropoffStop?.name ?? 'destination_stop'.tr,
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
        Text(
          'transaction_details'.tr,
          style: const TextStyle(
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
                'fare_amount'.tr,
                '${ticket.fareAmount.toStringAsFixed(2)} ETB',
              ),
              const Divider(height: 24),
              _buildDetailRow(
                context,
                'purchased_on'.tr,
                _formatDate(ticket.purchasedAt),
              ),
              const Divider(height: 24),
              _buildDetailRow(
                context,
                'expires_at_label'.tr,
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
    final ticket = controller.ticket.value;
    final isRequesting = controller.isRequestingDropSignal.value;

    return Column(
      children: [
        if (ticket?.status == 'ACTIVE')
          isRequesting
              ? Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: LoadingAnimatedButton(
                    width: MediaQuery.of(context).size.width - 40,
                    height: 48,
                    color: Colors.red,
                    borderColor: Colors.red.withOpacity(0.2),
                    borderRadius: 30.0,
                    borderWidth: 2.0,
                    onTap: () {},
                    child: Text(
                      'requesting_weraj'.tr,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              : ElevatedButton.icon(
                  onPressed: () {
                    if (ticket?.id != null) {
                      controller.requestDropSignal(ticket!.id);
                    }
                  },
                  icon: const Icon(Icons.front_hand, color: Colors.red, size: 18),
                  label: Text(
                    'request_weraj'.tr,
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
        const SizedBox(height: 12),
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
