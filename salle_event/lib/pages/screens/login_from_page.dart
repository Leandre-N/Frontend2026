import 'package:flutter/material.dart';
import 'package:salle_event/models/user_model.dart';
import 'package:salle_event/pages/screens/client_home_page.dart';
import 'package:salle_event/pages/screens/owner_home_page.dart';
import 'package:salle_event/service/auth_service.dart';
import '../../../../core/colors.dart';
import 'login.dart';


class LoginFormPage extends StatefulWidget {
  const LoginFormPage({super.key});

  @override
  State<LoginFormPage> createState() => _LoginFormPageState();
}

class _LoginFormPageState extends State<LoginFormPage> {
  final _formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool hidePassword = true;
  final AuthService _authService = AuthService();
  bool isLoading = false;

  void login() async {
    setState(() => isLoading = true);
    try {
      User user = await _authService.login(emailCtrl.text, passCtrl.text);
      print("Connecté : ${user.nom}, token: ${user.token}");

      // Ici tu peux naviguer vers la page principale
      if (user.role == "CLIENT") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ClientHomePage(fullName: user.nom,)),

        );
      }
      else if(user.role == "PROPRIETAIRE") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OwnerHomePage()),

        );
        
      }
    } catch (e) {
      print("Erreur login: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email ou mot de passe incorrect")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          _header(context),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    _buildField(
                      label: "Email",
                      hint: "votre@email.com",
                      controller: emailCtrl,
                    ),

                    const SizedBox(height: 15),

                    _buildPasswordField(),

                    const SizedBox(height: 25),

                    isLoading
                        ? CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  login();
                                }
                              },
                              child: const Text(
                                "Se connecter",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),

                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      child: const Text(
                        "Pas encore de compte ? S’inscrire",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
            "Connexion",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text("Bienvenue !", style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: (v) => v == null || v.isEmpty ? "Champ requis" : null,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Mot de passe"),
        const SizedBox(height: 6),
        TextFormField(
          controller: passCtrl,
          obscureText: hidePassword,
          validator: (v) => v == null || v.isEmpty ? "Champ requis" : null,
          decoration: InputDecoration(
            hintText: "********",
            filled: true,
            fillColor: Colors.grey.shade100,
            suffixIcon: IconButton(
              icon: Icon(
                hidePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  hidePassword = !hidePassword;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
