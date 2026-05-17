import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smartbus/utils/wrappers/shimmer_wrapper.dart';

import '../controllers/wallet_controller.dart';
import '../models/transaction.dart';

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
          'My Wallet',
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: theme.cardColor,
              radius: 16,
              child: Icon(
                LucideIcons.moreHorizontal,
                size: 18,
                color: theme.iconTheme.color,
              ),
            ),
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
        return RefreshIndicator(
          onRefresh: () async {
            controller.fetchWalletData();
            controller.fetchTransactions();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BalanceCard(
                  controller: controller,
                  balance: controller.balance.value,
                  onAddFunds: () => _showAddFundsDialog(context, controller),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),
                ),
                Obx(
                  () => TransactionList(
                    transactions: controller.transactions.value,
                  ),
                ),
                const SizedBox(height: 20),
              ],
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
          colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Obx(
            () => ShimmerWrapper(
              isEnabled: controller.isBalanceLoading.value,
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
            label: const Text('Add Funds'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: const StadiumBorder(
                side: BorderSide(color: Colors.white70),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

void _showAddFundsDialog(BuildContext context, WalletController controller) {
  final amountController = TextEditingController();
  controller.prepareNewTopUp();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Add Funds'),
      content: TextField(
        controller: amountController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          hintText: 'Enter amount',
          suffixText: 'ETB',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        Obx(()=>ElevatedButton(
          onPressed: () {
            final amount = double.tryParse(amountController.text);
            if (amount != null && amount > 0) {
              controller.addFunds(amount);
              // Navigator.pop(context);
            } else {
              Get.snackbar('Error', 'Please enter a valid amount');
            }
          },
          child: controller.isWalletLoading.value
              ? SizedBox(
            height: 10,
            width: 10,
            child: CircularProgressIndicator(color: Colors.white),
          )
              : const Text('Add'),
        ),)

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
                'No transactions yet',
                style: TextStyle(color: theme.textTheme.bodySmall?.color),
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          top: BorderSide(color: theme.dividerColor),
          bottom: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Column(
        children: transactions.map((tx) {
          final isCredit = tx.type == 'CREDIT';
          return TransactionItem(
            icon: isCredit ? LucideIcons.wallet : LucideIcons.bus,
            title: tx.description ?? 'Transaction',
            date: tx.createdAt.toString(),
            amount:
                '${isCredit ? '+' : '-'}${tx.amount.toStringAsFixed(2)} ETB',
            type: isCredit ? TransactionType.credit : TransactionType.debit,
          );
        }).toList(),
      ),
    );
  }
}

enum TransactionType { credit, debit, refund }

class TransactionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String date;
  final String amount;
  final TransactionType type;

  const TransactionItem({
    super.key,
    required this.icon,
    required this.title,
    required this.date,
    required this.amount,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color iconColor;
    Color bgColor;
    Color amountColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    switch (type) {
      case TransactionType.credit:
        iconColor = const Color(0xFF10B981);
        bgColor = iconColor.withOpacity(0.1);
        amountColor = iconColor;
        break;
      case TransactionType.debit:
        iconColor = const Color(0xFFEF4444);
        bgColor = iconColor.withOpacity(0.1);
        break;
      case TransactionType.refund:
        iconColor = const Color(0xFFF59E0B);
        bgColor = iconColor.withOpacity(0.1);
        amountColor = const Color(0xFF10B981);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: theme.textTheme.titleMedium?.color,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    color: theme.textTheme.bodySmall?.color,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}
