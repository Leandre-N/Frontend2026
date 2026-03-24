import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:salle_event/service/auth_service.dart';
import '../screens/login.dart';
import '../screens/owner_home_page.dart';

class OwnerRegisterPage extends StatefulWidget {
  const OwnerRegisterPage({super.key});

  @override
  State<OwnerRegisterPage> createState() => _OwnerRegisterPageState();
}

class _OwnerRegisterPageState extends State<OwnerRegisterPage> {
  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool acceptTerms = false;
  bool _isLoading = false;

  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final etabCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    etabCtrl.dispose();
    addressCtrl.dispose();
    passCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  // ─── SOUMISSION ──────────────────────────────────────────────

  Future<void> _soumettre() async {
    if (!_formKey.currentState!.validate()) return;

    if (!acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez accepter les conditions d'utilisation"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (passCtrl.text != confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Les mots de passe ne correspondent pas"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _authService.register(
        nom: nameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        telephone: phoneCtrl.text.trim(),
        motDePasse: passCtrl.text,
        role: 'PROPRIETAIRE',
        // etabCtrl et addressCtrl affichés mais non envoyés au backend
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bienvenue ${user.nom} 🎉'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OwnerHomePage()),
      );

    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message'] ?? 'Erreur inconnue'
          : 'Erreur inconnue';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );

    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── BUILD ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _header(context),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _field("Nom complet", nameCtrl),
                      _field("Email", emailCtrl,
                          keyboardType: TextInputType.emailAddress),
                      _field("Téléphone", phoneCtrl,
                          keyboardType: TextInputType.phone),
                      _field("Nom de l'établissement", etabCtrl),
                      _field("Adresse", addressCtrl),
                      _passwordField("Mot de passe", passCtrl, true),
                      _passwordField("Confirmer mot de passe", confirmCtrl, false),

                      // ─── CONDITIONS ──────────────────────────
                      Row(
                        children: [
                          Checkbox(
                            value: acceptTerms,
                            activeColor: const Color(0xFF8A2BE2),
                            onChanged: (v) => setState(() => acceptTerms = v!),
                          ),
                          const Expanded(
                            child: Text("J'accepte les conditions d'utilisation"),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // ─── BOUTON ──────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8A2BE2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _isLoading ? null : _soumettre,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "S'inscrire",
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        ),
                        child: const Text(
                          "Déjà un compte ? Se connecter",
                          style: TextStyle(color: Colors.deepPurple),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── HEADER ──────────────────────────────────────────────────

  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF8A2BE2),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Row(
              children: [
                Icon(Icons.arrow_back, color: Colors.white),
                SizedBox(width: 6),
                Text("Retour", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Inscription Propriétaire",
            style: TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            "Créez votre compte professionnel",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // ─── INPUT FIELD ─────────────────────────────────────────────

  Widget _field(
    String hint,
    TextEditingController ctrl, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        validator: (v) => v!.isEmpty ? "Champ requis" : null,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ─── PASSWORD FIELD ──────────────────────────────────────────

  Widget _passwordField(String hint, TextEditingController ctrl, bool main) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        obscureText: main ? hidePassword : hideConfirmPassword,
        validator: (v) => v!.isEmpty ? "Champ requis" : null,
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: IconButton(
            icon: Icon(
              (main ? hidePassword : hideConfirmPassword)
                  ? Icons.visibility_off
                  : Icons.visibility,
            ),
            onPressed: () => setState(() {
              main
                  ? hidePassword = !hidePassword
                  : hideConfirmPassword = !hideConfirmPassword;
            }),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}