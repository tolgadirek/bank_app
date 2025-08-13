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
    int _asInt(dynamic v) =>
        (v is num) ? v.toInt() : int.parse(v.toString());
    double _asDouble(dynamic v) =>
        (v is num) ? v.toDouble() : double.parse(v.toString());

    final rel = json['relatedAccount'];
    return TransactionModel(
      id: _asInt(json['id']),
      accountId: _asInt(json['accountId']),
      type: json['type']?.toString() ?? '',
      amount: _asDouble(json['amount']),
      description: json['description']?.toString() ?? '', // <-- default
      createdAt: DateTime.parse(json['createdAt'].toString()),
      relatedAccount: (rel is Map<String, dynamic>)
          ? AccountModel.fromJson(rel)
          : (rel is Map ? AccountModel.fromJson(Map<String, dynamic>.from(rel)) : null),
    );
  }
}
