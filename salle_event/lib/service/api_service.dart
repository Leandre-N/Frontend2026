import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio dio;

  ApiService._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: "http://10.0.2.2:3000/api",
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  // ─── GESTION DES ERREURS ─────────────────────────────────────

  Map<String, dynamic> _handleDioError(DioException e) {
    if (e.response != null) {
      return {
        'statusCode': e.response!.statusCode,
        'body': e.response!.data is Map
            ? e.response!.data
            : {'message': e.response!.data.toString()},
      };
    } else {
      return {
        'statusCode': 500,
        'body': {'message': 'Impossible de joindre le serveur. Vérifiez votre connexion.'},
      };
    }
  }

  // ─── SALLES ──────────────────────────────────────────────────

  Future<Map<String, dynamic>> ajouterSalle({
  required String nom,
  required String description,
  required String ville,
  required String adresse,
  required int capacite,
  required double prix,
  required String token,
  File? image, // ← AJOUTER
  List<String>? equipements, // AJOUTER
}) async {
  try {
    // ✅ MultipartFormData pour envoyer image + données
    final formData = FormData.fromMap({
      'nom': nom,
      'description': description,
      'ville': ville,
      'adresse': adresse,
      'capacite': capacite.toString(),
      'prix': prix.toString(),
      if (equipements != null)
        'equipements': jsonEncode(equipements),
      if (image != null)
        'image': await MultipartFile.fromFile(
          image.path,
          filename: image.path.split('/').last,
        ),
    });

    final response = await dio.post(
      '/salles',
      data: formData,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    return {'statusCode': response.statusCode, 'body': response.data};
  } on DioException catch (e) {
    return _handleDioError(e);
  }
}

Future<Map<String, dynamic>> getSalles() async {
  try {
    final response = await dio.get('/salles');
    return {'statusCode': response.statusCode, 'body': response.data};
  } on DioException catch (e) {
    return _handleDioError(e);
  }
}

Future<Map<String, dynamic>> getSalleById(int id) async {
  try {
    final response = await dio.get('/salles/$id');
    return {'statusCode': response.statusCode, 'body': response.data};
  } on DioException catch (e) {
    return _handleDioError(e);
  }
}

Future<Map<String, dynamic>> getOwnerDashboard(String token) async {
  try {
    final response = await dio.get(
      '/users/dashboard',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return {'statusCode': response.statusCode, 'body': response.data};
  } on DioException catch (e) {
    return _handleDioError(e);
  }
}

Future<Map<String, dynamic>> modifierSalle({
  required int id,
  required String nom,
  required String description,
  required String ville,
  required String adresse,
  required int capacite,
  required double prix,
  required String token,
  File? image,
  List<String>? equipements, // AJOUTER
}) async {
  try {
    final formData = FormData.fromMap({
      'nom': nom,
      'description': description,
      'ville': ville,
      'adresse': adresse,
      'capacite': capacite.toString(),
      'prix': prix.toString(),
      if (equipements != null)
        'equipements': jsonEncode(equipements),
      if (image != null)
        'image': await MultipartFile.fromFile(
          image.path,
          filename: image.path.split('/').last,
        ),
    });

    final response = await dio.put(
      '/salles/$id',
      data: formData,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return {'statusCode': response.statusCode, 'body': response.data};
  } on DioException catch (e) {
    return _handleDioError(e);
  }
}

  Future<Map<String, dynamic>> supprimerSalle(int id, String token) async {
    try {
      final response = await dio.delete(
        '/salles/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return {'statusCode': response.statusCode, 'body': response.data};
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  // ─── RESERVATIONS ────────────────────────────────────────────

  Future<Map<String, dynamic>> creerReservation({
    required int salleId,
    required String date,
    required String creneau,
    required double montantTotal,
    required String numTel,
    required String modePaiement,
    required String token,
  }) async {
    try {
      final response = await dio.post(
        '/reservations',
        data: {
          'salle_id': salleId,
          'date': date,
          'creneau': creneau,
          'montant_total': montantTotal,
          'num_tel': numTel,
          'mode_paiement': modePaiement,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return {'statusCode': response.statusCode, 'body': response.data};
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getMesReservations(String token) async {
    try {
      final response = await dio.get(
        '/reservations/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return {'statusCode': response.statusCode, 'body': response.data};
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getProprietaireReservations(String token) async {
    try {
      final response = await dio.get(
        '/reservations/proprietaire',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return {'statusCode': response.statusCode, 'body': response.data};
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> updateReservationStatus(
      int id, String statut, String token) async {
    try {
      final response = await dio.put(
        '/reservations/$id',
        data: {'statut': statut},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return {'statusCode': response.statusCode, 'body': response.data};
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getBlockedDates(int salleId) async {
    try {
      final response = await dio.get('/reservations/blocked-dates/$salleId');
      return {'statusCode': response.statusCode, 'body': response.data};
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getNotifications(String token) async {
    try {
      final response = await dio.get(
        '/notifications/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return {'statusCode': response.statusCode, 'body': response.data};
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> markNotificationsAsRead(String token) async {
    try {
      final response = await dio.put(
        '/notifications/mark-as-read',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return {'statusCode': response.statusCode, 'body': response.data};
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }
}