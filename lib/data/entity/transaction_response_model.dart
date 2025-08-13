import 'package:bank_app/data/entity/transaction_model.dart';

class TransactionResponseModel {
  final String status;
  final TransactionModel transaction;

  TransactionResponseModel({
    required this.status,
    required this.transaction,
  });

  factory TransactionResponseModel.fromJson(Map<String, dynamic> json) {
    return TransactionResponseModel(
      status: json['status']?.toString() ?? '',
      transaction: TransactionModel.fromJson(
        (json['transaction'] is Map<String, dynamic>)
            ? json['transaction'] as Map<String, dynamic>
            : (json['transaction'] is Map
            ? Map<String, dynamic>.from(json['transaction'] as Map)
            : <String, dynamic>{}),
      ),
    );
  }
}
