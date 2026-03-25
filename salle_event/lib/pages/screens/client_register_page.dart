
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:salle_event/service/auth_service.dart';
import '../../../../core/colors.dart';
import 'client_home_page.dart';

class ClientRegisterPage extends StatefulWidget {
  const ClientRegisterPage({super.key});

  @override
  State<ClientRegisterPage> createState() => _ClientRegisterPageState();
}

class _ClientRegisterPageState extends State<ClientRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

 
  Future<void> _soumettre() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = await _authService.register(
        nom: nameController.text.trim(),
        email: emailController.text.trim(),
        telephone: phoneController.text.trim(),
        motDePasse: passwordController.text,
        role: 'CLIENT',
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
        MaterialPageRoute(
          builder: (_) => ClientHomePage(fullName: user.nom),
        ),
      );
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Erreur inconnue';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(context),
            const SizedBox(height: 20),
            _form(),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 8),
          const Text('Retour', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _form() {
    return Expanded(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Inscription Client',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Créez votre compte',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 25),

              _inputField(
                label: 'Nom complet *',
                controller: nameController,
                validator: _requiredValidator,
              ),
              const SizedBox(height: 15),

              _inputField(
                label: 'Email *',
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                validator: _emailValidator,
              ),
              const SizedBox(height: 15),

              _inputField(
                label: 'Téléphone *',
                controller: phoneController,
                keyboardType: TextInputType.phone,
                validator: _requiredValidator,
              ),
              const SizedBox(height: 15),

              _inputField(
                label: 'Mot de passe *',
                controller: passwordController,
                obscureText: true,
                validator: _passwordValidator,
              ),
              const SizedBox(height: 15),

              _inputField(
                label: 'Confirmer le mot de passe *',
                controller: confirmPasswordController,
                obscureText: true,
                validator: _confirmPasswordValidator,
              ),
              const SizedBox(height: 25),

              _registerButton(),
              const SizedBox(height: 15),

              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    'Déjà un compte ? Se connecter',
                    style: TextStyle(color: AppColors.primary, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _registerButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
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
                'S\'inscrire',
                style: TextStyle(color: Colors.white),
              ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ce champ est obligatoire';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) return 'Email requis';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Email invalide';
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Mot de passe requis';
    if (value.length < 8) return 'Minimum 8 caractères';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Ajoutez une majuscule';
    if (!RegExp(r'[a-z]').hasMatch(value)) return 'Ajoutez une minuscule';
    if (!RegExp(r'\d').hasMatch(value)) return 'Ajoutez un chiffre';
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Confirmation requise';
    if (value != passwordController.text) return 'Les mots de passe ne correspondent pas';
    return null;
  }
}