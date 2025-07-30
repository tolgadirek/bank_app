import 'package:bank_app/data/entity/account_model.dart';
import 'package:bank_app/data/entity/account_response_model.dart';
import 'package:bank_app/data/entity/user_response_model.dart';
import 'package:bank_app/data/services/dio_service.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Repository {
  final Dio dio = DioService.dio;

  Future<UserResponseModel?> register(String email, String password, String firstName, String lastName, String phoneNumber) async {
    try{
      final response = await dio.post("/auth/register", data: {
        "email" : email,
        "password" : password,
        "firstName" : firstName,
        "lastName" : lastName,
        "phoneNumber" : phoneNumber
      });
      final token = response.data['token'];
      if (token != null) await saveToken(token);

      return UserResponseModel.fromJson(response.data);
    } catch (e) {
      print("Hata: $e");
      return null;
    }
  }

  Future<UserResponseModel?> login(String email, String password) async {
    try {
      final response = await dio.post("/auth/login", data: {
        "email": email,
        "password": password
      });

      final token = response.data['token'];
      if (token != null) await saveToken(token);
      print("Token: $token");
      print("data: ${response.data}");
      return UserResponseModel.fromJson(response.data);
    } catch (e) {
      print("Hata: $e");
      return null;
    }
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<AccountResponseModel?> createBankAccount(String name) async {
    final authDio = await DioService.getAuthorizedDio();
    try {
      final response = await authDio.post("/account", data: {
        "name": name,
      });
      return AccountResponseModel.fromJson(response.data);
    } catch (e) {
      print("Hata: $e");
      return null;
    }
  }

  Future<List<AccountModel>> getBankAccounts() async {
    final authDio = await DioService.getAuthorizedDio();
    try {
      final response = await authDio.get("/account");
      final List data = response.data["accounts"];
      print("Account datas $data");
      return data.map((json) => AccountModel.fromJson(json)).toList();
    } catch (e) {
      print("Hata: $e");
      return [];
    }
  }

}