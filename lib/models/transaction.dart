// ignore_for_file: constant_identifier_names

enum WalletTransactionType {
  TOPUP,
  TICKET_PURCHASE,
  REFUND,
  ADJUSTMENT,
  UNKNOWN,
}

enum WalletTransactionStatus { PENDING, COMPLETED, FAILED, REVERSED, UNKNOWN }

class WalletTransaction {
  final String id;
  final String walletId;
  final String type; // TOPUP, TICKET_PURCHASE, REFUND, ADJUSTMENT, etc.
  final String? status; // PENDING, COMPLETED, FAILED, REVERSED
  final double amount; // In Birr
  final String? description;
  final String? paymentMethod;
  final String? paymentReference;
  final DateTime createdAt;

  WalletTransaction({
    required this.id,
    required this.walletId,
    required this.type,
    this.status,
    required this.amount,
    this.description,
    this.paymentMethod,
    this.paymentReference,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'],
      walletId: json['walletId'],
      type: json['type'] ?? '',
      status: json['status'],
      amount: (json['amount'] is num ? json['amount'].toDouble() : 0.0),
      description: json['description'],
      paymentMethod: json['paymentMethod'],
      paymentReference: json['paymentReference'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  WalletTransactionType get transactionType {
    switch (type.toUpperCase()) {
      case 'TOPUP':
        return WalletTransactionType.TOPUP;
      case 'TICKET_PURCHASE':
        return WalletTransactionType.TICKET_PURCHASE;
      case 'REFUND':
        return WalletTransactionType.REFUND;
      case 'ADJUSTMENT':
        return WalletTransactionType.ADJUSTMENT;
      default:
        // Retro-compatibility fallback if old values CREDIT/DEBIT are present
        if (type.toUpperCase() == 'CREDIT') return WalletTransactionType.TOPUP;
        if (type.toUpperCase() == 'DEBIT')
          return WalletTransactionType.TICKET_PURCHASE;
        return WalletTransactionType.UNKNOWN;
    }
  }

  WalletTransactionStatus get transactionStatus {
    switch (status?.toUpperCase()) {
      case 'PENDING':
        return WalletTransactionStatus.PENDING;
      case 'COMPLETED':
        return WalletTransactionStatus.COMPLETED;
      case 'FAILED':
        return WalletTransactionStatus.FAILED;
      case 'REVERSED':
        return WalletTransactionStatus.REVERSED;
      default:
        return WalletTransactionStatus.UNKNOWN;
    }
  }

  bool get isCredit {
    switch (transactionType) {
      case WalletTransactionType.TOPUP:
      case WalletTransactionType.REFUND:
        return true;
      case WalletTransactionType.TICKET_PURCHASE:
        return false;
      case WalletTransactionType.ADJUSTMENT:
        // Adjustments can be credit (positive) or debit (negative)
        return amount >= 0;
      case WalletTransactionType.UNKNOWN:
        // Fallback checks
        return type.toUpperCase() == 'CREDIT' || amount >= 0;
    }
  }
}
