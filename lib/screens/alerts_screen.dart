import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../controllers/alert_controller.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alertController = Get.put(AlertController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        title: Text(
          'alerts'.tr,
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () => alertController.markAllAsRead(),
            child: Text(
              'mark_all_read'.tr,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Theme.of(context).dividerColor, height: 1),
        ),
      ),
      body: Obx(() {
        if (alertController.isLoading.value && alertController.alerts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (alertController.alerts.isEmpty) {
          return Center(child: Text("no_alerts_yet".tr));
        }

        return RefreshIndicator(
          onRefresh: alertController.fetchAlerts,
          child: ListView.builder(
            itemCount: alertController.alerts.length,
            itemBuilder: (context, index) {
              final alert = alertController.alerts[index];
              return NotificationItem(
                icon: _getIconForType(alert['type']),
                title: alert['title'] ?? 'alert'.tr,
                message: alert['message'] ?? '',
                time: alert['time'] ?? '',
                type: _getNotificationType(alert['type']),
                isUnread: alert['isUnread'] ?? false,
              );
            },
          ),
        );
      }),
    );
  }

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'success':
        return LucideIcons.checkCircle;
      case 'warning':
        return LucideIcons.info;
      case 'muted':
        return LucideIcons.ticket;
      default:
        return LucideIcons.megaphone;
    }
  }

  NotificationType _getNotificationType(String? type) {
    switch (type) {
      case 'success':
        return NotificationType.success;
      case 'warning':
        return NotificationType.warning;
      case 'muted':
        return NotificationType.muted;
      default:
        return NotificationType.info;
    }
  }
}

/// Category Headers
class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }
}

enum NotificationType { success, warning, info, muted }

class NotificationItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String time;
  final NotificationType type;
  final bool isUnread;

  const NotificationItem({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isUnread = false,
  });

  @override
  Widget build(BuildContext context) {
    Color accentColor;
    switch (type) {
      case NotificationType.success:
        accentColor = const Color(0xFF10B981);
        break;
      case NotificationType.warning:
        accentColor = const Color(0xFFF59E0B);
        break;
      case NotificationType.info:
        accentColor = const Color(0xFF2563EB);
        break;
      case NotificationType.muted:
        accentColor = const Color(0xFF64748B);
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread
            ? Theme.of(context).primaryColor.withOpacity(0.03)
            : Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicator for unread
          if (isUnread)
            Container(
              margin: const EdgeInsets.only(top: 14, right: 8),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
            )
          else
            const SizedBox(width: 16),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color:
                        Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withOpacity(0.8) ??
                        const Color(0xFF475569),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
