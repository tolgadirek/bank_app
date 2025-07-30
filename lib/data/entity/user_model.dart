class UserModel {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;

  UserModel({required this.id, required this.email, required this.firstName, required this.lastName, required this.phoneNumber});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phoneNumber: json['phoneNumber'],
    );
  }
}
