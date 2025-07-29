import 'package:bank_app/data/entity/user_response_model.dart';
import 'package:bank_app/data/services/dio_service.dart';
import 'package:dio/dio.dart';

class Repository {
  final Dio dio = DioService.dio;

  Future<UserResponseModel> register(String email, String password, String firstName, String lastName) async {
    try{
      final response = await dio.post("/auth/register", data: {
        "email" : email,
        "password" : password,
        "firstName" : firstName,
        "lastName" : lastName
      });

      return UserResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<UserResponseModel> login(String email, String password) async {
    try {
      final response = await dio.post("/auth/login", data: {
        "email": email,
        "password": password
      });

      return UserResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

}