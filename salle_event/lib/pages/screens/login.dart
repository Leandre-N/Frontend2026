import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import 'account_type_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.secondary,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.apartment,
              color: Colors.white,
              size: 80,
            ),
            const SizedBox(height: 20),

            const Text(
              'SalleEvent',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Réservez votre salle parfaite',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 40),

            _loginButton(),
            const SizedBox(height: 15),
            _registerButton(context), 
          ],
        ),
      ),
    );
  }

  Widget _loginButton() {
    return SizedBox(
      width: 260,
      height: 45,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {},
        child: const Text('Se connecter'),
      ),
    );
  }

  Widget _registerButton(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 45,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AccountTypePage(),
            ),
          );
        },
        child: const Text(
          'S’inscrire',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
