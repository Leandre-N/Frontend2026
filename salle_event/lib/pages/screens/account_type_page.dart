import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import 'client_register_page.dart';
import 'owner_register_page.dart';

class AccountTypePage extends StatefulWidget {
  const AccountTypePage({super.key});

  @override
  State<AccountTypePage> createState() => _AccountTypePageState();
}

class _AccountTypePageState extends State<AccountTypePage> {
  String selectedType = 'client';

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
            _content(),
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

  Widget _content() {
    return Expanded(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Type de compte',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text('Qui êtes-vous ?', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 25),

            _accountOption(
              value: 'client',
              title: 'Client',
              subtitle: 'Je recherche une salle pour mon événement',
              icon: Icons.person_outline,
            ),

            const SizedBox(height: 15),

            _accountOption(
              value: 'owner',
              title: 'Propriétaire',
              subtitle: 'Je possède une ou plusieurs salles à louer',
              icon: Icons.apartment_outlined,
            ),

            const Spacer(),

            _continueButton(),
          ],
        ),
      ),
    );
  }

  Widget _accountOption({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final bool isSelected = selectedType == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedType = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _continueButton() {
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
        onPressed: () {
          if (selectedType == 'client') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ClientRegisterPage(),
              ),
            );
          } else if (selectedType == 'owner') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const OwnerRegisterPage(),
              ),
            );
          }
        },
        child: const Text(
          'Continuer',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
