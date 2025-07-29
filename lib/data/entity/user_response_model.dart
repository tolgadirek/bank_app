import 'user_model.dart';

class UserResponseModel {
  final String token;
  final UserModel user;

  UserResponseModel({required this.token, required this.user});

  factory UserResponseModel.fromJson(Map<String, dynamic> json) {
    return UserResponseModel(
      token: json['token'],
      user: UserModel.fromJson(json['user']),
    );
  }
}
