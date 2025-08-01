import 'package:bank_app/data/entity/transaction_model.dart';

class TransactionResponseModel {
  final int status;
  final TransactionModel transaction;

  TransactionResponseModel({
    required this.status,
    required this.transaction,
  });

  factory TransactionResponseModel.fromJson(Map<String, dynamic> json) {
    return TransactionResponseModel(
      status: json['status'],
      transaction: TransactionModel.fromJson(json["transaction"])
    );
  }
}