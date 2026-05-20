import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smartbus/utils/wrappers/shimmer_wrapper.dart';

import '../controllers/wallet_controller.dart';
import '../models/transaction.dart';
import '../utils/animations.dart';
import '../utils/api_call_status.dart';
import '../utils/templates/loaded_widgets_template.dart';
import '../widgets/animated_widgets/loading_animation_button.dart';

final walletCardAnimation = AnimationInfo(
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

final walletActivityHeaderAnimation = AnimationInfo(
  trigger: AnimationTrigger.onPageLoad,
  effects: [
    FadeEffect(
      curve: Curves.easeInOut,
      delay: const Duration(milliseconds: 100),
      duration: const Duration(milliseconds: 500),
      begin: 0.0,
      end: 1.0,
    ),
  ],
);

final walletTransactionItemAnimation = AnimationInfo(
  trigger: AnimationTrigger.onPageLoad,
  effects: [
    FadeEffect(
      curve: Curves.easeInOut,
      delay: const Duration(milliseconds: 150),
      duration: const Duration(milliseconds: 500),
      begin: 0.0,
      end: 1.0,
    ),
    MoveEffect(
      curve: Curves.easeInOut,
      delay: const Duration(milliseconds: 150),
      duration: const Duration(milliseconds: 500),
      begin: const Offset(0.0, 20.0),
      end: const Offset(0.0, 0.0),
    ),
  ],
);

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.put(WalletController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'my_wallet'.tr,
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        centerTitle: false,
        actions: [
          // Padding(
          //   padding: const EdgeInsets.only(right: 16.0),
          //   child: CircleAvatar(
          //     backgroundColor: theme.cardColor,
          //     radius: 16,
          //     child: Icon(
          //       LucideIcons.moreHorizontal,
          //       size: 18,
          //       color: theme.iconTheme.color,
          //     ),
          //   ),
          // ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerWrapper(
                  isEnabled: true,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      width: double.infinity,
                      height: 180,
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey[300],
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
                    'recent_activity'.tr,
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
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return ShimmerWrapper(
                      isEnabled: true,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Container(
                                      width: 150,
                                      height: 14,
                                      color: Colors.grey[300],
                                    ),
                                  ),
                                  // const SizedBox(height: 8),
                                  Container(
                                    width: 100,
                                    height: 12,
                                    color: Colors.grey[300],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 60,
                              height: 14,
                              color: Colors.grey[300],
                            ),
                          ],
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
          apiCallStatus: controller.transactionsStatus.value,
          errorData: controller.transactionsError.value,
          loadingChild: shimmerLoading(),
          errorChild: null,
          onReload: () async {
            await controller.fetchWalletData();
            await controller.fetchTransactions();
          },
          child:
              // shimmerLoading(),
              RefreshIndicator(
                onRefresh: () async {
                  await controller.fetchWalletData();
                  await controller.fetchTransactions();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BalanceCard(
                        controller: controller,
                        balance: controller.balance.value,
                        onAddFunds: () =>
                            _showAddFundsDialog(context, controller),
                      ).animateOnPageLoad(walletCardAnimation),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: Text(
                          'recent_activity'.tr,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: theme.textTheme.titleLarge?.color,
                          ),
                        ),
                      ).animateOnPageLoad(walletActivityHeaderAnimation),
                      TransactionList(transactions: controller.transactions),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
        );
      }),
    );
  }
}

class BalanceCard extends StatelessWidget {
  final double balance;
  final WalletController controller;
  final VoidCallback onAddFunds;
  const BalanceCard({
    super.key,
    required this.controller,
    required this.balance,
    required this.onAddFunds,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor,
            theme.primaryColor.withValues(alpha: 0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'total_balance'.tr,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Obx(
            () => ShimmerWrapper(
              isEnabled:
                  controller.balanceStatus.value == ApiCallStatus.loading,
              child: Text(
                '${balance.toStringAsFixed(2)} ETB',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAddFunds,
            icon: const Icon(LucideIcons.plus, size: 18),
            label: Text('add_funds'.tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: const StadiumBorder(
                side: BorderSide(color: Colors.white70),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ).animateOnPress(),
        ],
      ),
    );
  }
}

void _showAddFundsDialog(BuildContext context, WalletController controller) {
  final amountController = TextEditingController();
  controller.prepareNewTopUp();
  final suggestedAmounts = controller.getSuggestedTopUpAmounts();

  Get.dialog(
    AlertDialog(
      title: Text('add_funds'.tr),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (suggestedAmounts.isNotEmpty) ...[
            Text(
              'suggested_for_you'.tr,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: suggestedAmounts.map((amount) {
                return ActionChip(
                  label: Text('${amount.toStringAsFixed(0)} ETB'),
                  onPressed: () {
                    amountController.text = amount.toStringAsFixed(0);
                  },
                  backgroundColor: Theme.of(
                    context,
                  ).primaryColor.withValues(alpha: 0.1),
                  side: BorderSide(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.2),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'enter_amount'.tr,
              suffixText: 'ETB',
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('cancel'.tr),
        ).animateOnPress(),
        Obx(() {
          final theme = Theme.of(context);
          final isLoading =
              controller.topupStatus.value == ApiCallStatus.loading;
          if (isLoading) {
            return LoadingAnimatedButton(
              width: 100,
              height: 38,
              color: theme.primaryColor,
              borderColor: Colors.white,
              borderRadius: 8.0,
              borderWidth: 3.0,
              onTap: () {},
              child: Text(
                'adding'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            );
          }
          return ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                controller.addFunds(amount);
              } else {
                Get.snackbar('error'.tr, 'please_enter_valid_amount'.tr);
              }
            },
            child: Text('add'.tr),
          ).animateOnPress();
        }),
      ],
    ),
  );
}

class TransactionList extends StatelessWidget {
  final List<WalletTransaction> transactions;
  const TransactionList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              Icon(LucideIcons.layers, size: 48, color: theme.disabledColor),
              const SizedBox(height: 16),
              Text(
                'no_transactions_yet'.tr,
                style: TextStyle(color: theme.textTheme.bodySmall?.color),
              ),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: transactions.map((tx) {
          return TransactionItem(
            transaction: tx,
          ).animateOnPageLoad(walletTransactionItemAnimation);
        }).toList(),
      ),
    );
  }
}

class TransactionItem extends StatelessWidget {
  final WalletTransaction transaction;

  const TransactionItem({super.key, required this.transaction});

  IconData _getIcon(WalletTransactionType type) {
    switch (type) {
      case WalletTransactionType.TOPUP:
        return LucideIcons.arrowDownLeft;
      case WalletTransactionType.TICKET_PURCHASE:
        return LucideIcons.ticket;
      case WalletTransactionType.REFUND:
        return LucideIcons.rotateCcw;
      case WalletTransactionType.ADJUSTMENT:
        return LucideIcons.sliders;
      case WalletTransactionType.UNKNOWN:
        return LucideIcons.wallet;
    }
  }

  String _getLocalizedTypeName(WalletTransactionType type) {
    switch (type) {
      case WalletTransactionType.TOPUP:
        return 'tx_type_topup'.tr;
      case WalletTransactionType.TICKET_PURCHASE:
        return 'tx_type_ticket_purchase'.tr;
      case WalletTransactionType.REFUND:
        return 'tx_type_refund'.tr;
      case WalletTransactionType.ADJUSTMENT:
        return 'tx_type_adjustment'.tr;
      case WalletTransactionType.UNKNOWN:
        return 'tx_type_unknown'.tr;
    }
  }

  Color _getTypeColor(WalletTransactionType type) {
    switch (type) {
      case WalletTransactionType.TOPUP:
        return const Color(0xFF10B981); // Emerald
      case WalletTransactionType.TICKET_PURCHASE:
        return const Color(0xFF3B82F6); // Indigo/Blue
      case WalletTransactionType.REFUND:
        return const Color(0xFF06B6D4); // Teal
      case WalletTransactionType.ADJUSTMENT:
        return const Color(0xFFF59E0B); // Amber
      case WalletTransactionType.UNKNOWN:
        return const Color(0xFF6B7280); // Gray
    }
  }

  Color _getStatusBgColor(WalletTransactionStatus status) {
    switch (status) {
      case WalletTransactionStatus.PENDING:
        return const Color(0xFFF59E0B).withValues(alpha: 0.1);
      case WalletTransactionStatus.COMPLETED:
        return const Color(0xFF0B66B2).withValues(alpha: 0.1);
      case WalletTransactionStatus.FAILED:
        return const Color(0xFFEF4444).withValues(alpha: 0.1);
      case WalletTransactionStatus.REVERSED:
        return const Color(0xFF6B7280).withValues(alpha: 0.1);
      case WalletTransactionStatus.UNKNOWN:
        return const Color(0xFF94A3B8).withValues(alpha: 0.1);
    }
  }

  Color _getStatusTextColor(WalletTransactionStatus status) {
    switch (status) {
      case WalletTransactionStatus.PENDING:
        return const Color(0xFFD97706);
      case WalletTransactionStatus.COMPLETED:
        return const Color(0xFF0B66B2);
      case WalletTransactionStatus.FAILED:
        return const Color(0xFFDC2626);
      case WalletTransactionStatus.REVERSED:
        return const Color(0xFF4B5563);
      case WalletTransactionStatus.UNKNOWN:
        return const Color(0xFF64748B);
    }
  }

  String _getLocalizedStatusName(WalletTransactionStatus status) {
    switch (status) {
      case WalletTransactionStatus.PENDING:
        return 'tx_status_pending'.tr;
      case WalletTransactionStatus.COMPLETED:
        return 'tx_status_completed'.tr;
      case WalletTransactionStatus.FAILED:
        return 'tx_status_failed'.tr;
      case WalletTransactionStatus.REVERSED:
        return 'tx_status_reversed'.tr;
      case WalletTransactionStatus.UNKNOWN:
        return 'tx_status_unknown'.tr;
    }
  }

  String _formatDateTime(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = months[dt.month - 1];
    final day = dt.day.toString().padLeft(2, '0');
    final year = dt.year;
    final hourInt = dt.hour;
    final period = hourInt >= 12 ? 'PM' : 'AM';
    final hour = (hourInt % 12 == 0 ? 12 : hourInt % 12).toString().padLeft(
      2,
      '0',
    );
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$month $day, $year • $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final txType = transaction.transactionType;
    final txStatus = transaction.transactionStatus;
    final isCredit = transaction.isCredit;

    final typeColor = _getTypeColor(txType);
    final statusBg = _getStatusBgColor(txStatus);
    final statusText = _getStatusTextColor(txStatus);

    final amountPrefix = isCredit ? '+' : '-';
    final amountColor = isCredit
        ? const Color(0xFF0B66B2)
        : theme.textTheme.bodyLarge?.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.08)),
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Section: Icon inside beautiful soft circular background
            // Container(
            //   alignment: Alignment.center,
            //   width: 44,
            //   height: 44,
            //   decoration: BoxDecoration(
            //     color: typeColor.withValues(alpha: 0.1),
            //     shape: BoxShape.circle,
            //   ),
            //   child: Icon(
            //     _getIcon(txType),
            //     color: typeColor,
            //     size: 20,
            //   ),
            // ),
            // const SizedBox(width: 14),

            // Middle Section: Type, description, formatted date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Type Name
                  Text(
                    _getLocalizedTypeName(txType),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleMedium?.color,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Description (if any)
                  if (transaction.description != null &&
                      transaction.description!.trim().isNotEmpty &&
                      transaction.description != transaction.type) ...[
                    const SizedBox(height: 4),
                    Text(
                      transaction.description!,
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color?.withValues(
                          alpha: 0.7,
                        ),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 6),

                  // Date & Payment Method Row
                  Row(
                    children: [
                      Icon(
                        LucideIcons.calendar,
                        size: 11,
                        color: theme.iconTheme.color?.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateTime(transaction.createdAt),
                        style: TextStyle(
                          color: theme.textTheme.bodySmall?.color,
                          fontSize: 11,
                        ),
                      ),
                      if (transaction.paymentMethod != null &&
                          transaction.paymentMethod!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: theme.dividerColor.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            transaction.paymentMethod!.toUpperCase(),
                            style: TextStyle(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.8),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Right Section: Status Badge (Top-Right) & Amount (Bottom-Right)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top-Right: Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getLocalizedStatusName(txStatus),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: statusText,
                    ),
                  ),
                ),

                // Bottom-Right: Amount
                Text(
                  '$amountPrefix ${transaction.amount.toStringAsFixed(2)} ETB',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: amountColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
