import 'package:bank_app/data/entity/user_model.dart';

class AccountModel {
  int id;
  String name;
  String accountNumber;
  String iban;
  double balance;
  DateTime createdAt;
  UserModel? user; // Ekledik

  AccountModel({required this.id, required this.name, required this.accountNumber,
    required this.iban, required this.balance, required this.createdAt, this.user});

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json["id"],
      name: json["name"],
      accountNumber: json["accountNumber"],
      iban: json["iban"],
      balance: (json["balance"] as num).toDouble(),
      createdAt: DateTime.parse(json["createdAt"]),
      user: json["user"] != null ? UserModel.fromJson(json["user"]) : null, // user varsa parse et
    );
  }
}

