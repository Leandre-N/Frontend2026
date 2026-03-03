// auth_service.dart
import 'package:dio/dio.dart';
import 'package:salle_event/models/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final Dio _dio = ApiService().dio;
  final StorageService _storage = StorageService();


  Future<User> login(String email, String password) async {
    try {
      final response = await _dio.post(
        "/users/login",
        data: {"email": email, "mot_de_passe": password},
      );

      // on suppose que le backend retourne { user: {...}, token: "..." }
      final userData = response.data['user'];
      final token = response.data['token'];

      await _storage.saveToken(token);
      final savedToken = await _storage.getToken();
      print("TOKEN SAUVEGARDE DANS LE TELEPHONE : $savedToken");

      // Utilisation de fromJson
      return User.fromJson(userData, token: token);
    } on DioException catch (e) {
      print("Erreur login : ${e.response?.statusCode} - ${e.message}");
      rethrow;
    }

    
  }
}
