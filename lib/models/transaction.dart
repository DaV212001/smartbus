class WalletTransaction {
  final String id;
  final String walletId;
  final String type; // CREDIT or DEBIT
  final String? status;
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
      type: json['type'],
      status: json['status'],
      amount: (json['amount'] is num ? json['amount'].toDouble() : 0.0) / 100,
      description: json['description'],
      paymentMethod: json['paymentMethod'],
      paymentReference: json['paymentReference'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
