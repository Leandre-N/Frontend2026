// auth_service.dart

import 'package:dio/dio.dart';
import 'package:salle_event/models/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final Dio _dio = ApiService().dio;
  final StorageService _storage = StorageService();

  // LOGIN

  Future<User> login(String email, String password) async {
    try {
      print("EMAIL ENVOYE : '${email}'");
      print("PASSWORD ENVOYE:'${password}'");
      final response = await _dio.post(
        "/users/login",
        data: {"email": email, "mot_de_passe": password},
      );

      final userData = response.data['user'];
      final token = response.data['token'];

      // Sauvegarde du token dans le téléphone
      await _storage.saveToken(token);

      final savedToken = await _storage.getToken();
      print("TOKEN SAUVEGARDE DANS LE TELEPHONE : $savedToken");

      return User.fromJson(userData, token: token);
    } on DioException catch (e) {
      print("Erreur login : ${e.response?.statusCode} - ${e.message}");
      rethrow;
    }
  }
  // ─── REGISTER ────────────────────────────────────────────────

  Future<User> register({
    required String nom,
    required String email,
    required String telephone,
    required String motDePasse,
    String role = 'CLIENT',
  }) async {
    try {
      print("   nom: $nom");
      print("   email: $email");
      print("   telephone: $telephone");
      print("   role: $role");
      final response = await _dio.post(
        "/users",
        data: {
          "nom": nom,
          "email": email,
          "telephone": telephone,
          "mot_de_passe": motDePasse,
          "role": role,
        },
      );


      return await login(email, motDePasse);
    } on DioException catch (e) {
      print("Erreur register : ${e.response?.statusCode} - ${e.message}");
      rethrow;
    }
  }

  // ─── LOGOUT ──────────────────────────────────────────────────

  Future<void> logout() async {
    await _storage.deleteToken();
    print("Token supprimé — utilisateur déconnecté");
  }
}
