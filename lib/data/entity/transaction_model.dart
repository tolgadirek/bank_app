import 'package:bank_app/data/entity/account_model.dart';

class TransactionModel {
  final int id;
  final int accountId;
  final String type;
  final double amount;
  final String description;
  final DateTime createdAt;

  // Karşı taraf bilgisi (opsiyonel)
  final AccountModel? relatedAccount;

  TransactionModel({
    required this.id,
    required this.accountId,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdAt,
    this.relatedAccount,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      accountId: json['accountId'],
      type: json['type'],
      amount: (json['amount'] as num).toDouble(),
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      relatedAccount: json['relatedAccount'] != null
          ? AccountModel.fromJson(json['relatedAccount'])
          : null,
    );
  }
}


