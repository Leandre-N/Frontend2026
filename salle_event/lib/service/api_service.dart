// api_service.dart
import 'package:dio/dio.dart';

class ApiService {
  // Singleton pour réutiliser la même instance partout
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio dio;

  ApiService._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: "http://192.168.1.136:3000/api", // émulateur Android
        connectTimeout: Duration(seconds: 10),
        receiveTimeout: Duration(seconds: 10),
      ),
    );
  }
}