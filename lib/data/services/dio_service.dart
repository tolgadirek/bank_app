import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioService {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:5000/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

// Token'lı kullanım
  static Future<Dio> getAuthorizedDio() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    return Dio(
      BaseOptions(
        baseUrl: 'http://10.0.2.2:5000/api',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ),
    );
  }
}
