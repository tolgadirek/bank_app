import 'package:bank_app/data/entity/account_model.dart';

class AccountResponseModel {
  String status;
  AccountModel account;

  AccountResponseModel({required this.status, required this.account});

  factory AccountResponseModel.fromJson(Map<String, dynamic> json) {
    return AccountResponseModel(
      status: json['status'],
      account: AccountModel.fromJson(json['account']),
    );
  }
}