// user.dart
class User {
  final int id;
  final String nom;
  final String email;
  final String telephone;
  final String role;
  final bool verified;
  final String token;

  // Constructeur
  User({
    required this.id,
    required this.nom,
    required this.email,
    required this.telephone,
    required this.role,
    required this.verified,
    required this.token,
  });

  // Transformer JSON → User
  factory User.fromJson(Map<String, dynamic> json, {String? token}) {
    return User(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      nom: json['nom'] ?? '',
      email: json['email'] ?? '',
      telephone: json['telephone'] ?? '',
      role: json['role'] ?? '',
      verified: json['verified'] ?? false,
      token: token ?? json['token'] ?? '',
    );
  }

  // Transformer User → JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'email': email,
      'telephone': telephone,
      'role': role,
      'verified': verified,
      'token': token,
    };
  }
}