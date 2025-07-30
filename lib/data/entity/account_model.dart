class AccountModel {
  int id;
  String name;
  String accountNumber;
  String iban;
  double balance;
  DateTime createdAt;

  AccountModel({required this.id, required this.name, required this.accountNumber,
    required this.iban, required this.balance, required this.createdAt});

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json["id"],
      name: json["name"],
      accountNumber: json["accountNumber"],
      iban: json["iban"],
      balance: (json["balance"] as num).toDouble(),
      createdAt: DateTime.parse(json["createdAt"]),
    );
  }
}

