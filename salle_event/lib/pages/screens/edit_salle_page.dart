import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:salle_event/service/api_service.dart';
import 'package:salle_event/service/storage_service.dart';

class EditSallePage extends StatefulWidget {
  final Map<String, dynamic> salle;
  const EditSallePage({super.key, required this.salle});

  @override
  State<EditSallePage> createState() => _EditSallePageState();
}

class _EditSallePageState extends State<EditSallePage> {

  final ApiService _apiService = ApiService();
  final StorageService _storage = StorageService();
  bool _isLoading = false;

  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final capacityCtrl = TextEditingController();
  final priceCtrl = TextEditingController();


  String selectedVille = "Douala";
  String selectedType = "Mariage";
  File? image;
  final ImagePicker picker = ImagePicker();

  final List<String> villes = [
    "Douala", "Yaoundé", "Bafoussam", "Garoua",
  ];

  final List<String> types = [
    "Mariage", "Anniversaire", "Conférence", "Réunion",
  ];

  final List<String> equipements = [
    "Climatisation", "Sonorisation", "Éclairage LED", "WiFi",
    "Parking", "Cuisine équipée", "Projecteur", "Écran géant",
    "Tables et chaises", "Décoration", "Sécurité", "Jardin",
  ];

  final List<String> selectedEquipements = [];


  @override
  void initState() {
    super.initState();
    nameCtrl.text = widget.salle['nom'] ?? '';
    descCtrl.text = widget.salle['description'] ?? '';
    addressCtrl.text = widget.salle['adresse'] ?? '';
    capacityCtrl.text = widget.salle['capacite']?.toString() ?? '';
    priceCtrl.text = widget.salle['prix']?.toString() ?? '';
    
    if (villes.contains(widget.salle['ville'])) {
      selectedVille = widget.salle['ville'];
    }

    // Charger les équipements existants
    if (widget.salle['equipements'] != null) {
      for (var eq in widget.salle['equipements']) {
        if (eq['nom'] != null) {
          selectedEquipements.add(eq['nom']);
        }
      }
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    addressCtrl.dispose();
    capacityCtrl.dispose();
    priceCtrl.dispose();
    super.dispose();
  }


  Future<void> pickImage() async {
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => image = File(picked.path));
    }
  }


  Future<void> submit() async {

    if (nameCtrl.text.isEmpty ||
        priceCtrl.text.isEmpty ||
        capacityCtrl.text.isEmpty ||
        addressCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Remplis tous les champs obligatoires"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final prix = double.tryParse(priceCtrl.text);
    final capacite = int.tryParse(capacityCtrl.text);

    if (prix == null || capacite == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Prix et capacité doivent être des nombres"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final token = await _storage.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Session expirée, veuillez vous reconnecter"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _apiService.modifierSalle(
        id: widget.salle['id'],
        nom: nameCtrl.text.trim(),
        description: descCtrl.text.trim(),
        ville: selectedVille,
        adresse: addressCtrl.text.trim(),
        capacite: capacite,
        prix: prix,
        token: token,
        image: image,
        equipements: selectedEquipements, // AJOUTER
      );

      if (!mounted) return;

      final statusCode = result['statusCode'];
      final message = result['body']['message'] ?? 'Erreur inconnue';

      if (statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Salle modifiée avec succès ✅"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    buildLabel("Nom de la salle *"),
                    buildInputField("Ex: Salle Royale", controller: nameCtrl),

                    buildLabel("Description *"),
                    buildInputField(
                      "Décrivez votre salle...",
                      controller: descCtrl,
                      maxLines: 4,
                    ),

                    buildLabel("Ville *"),
                    buildDropdown(villes, selectedVille, (val) {
                      setState(() => selectedVille = val!);
                    }),

                    buildLabel("Adresse précise *"),
                    buildInputField("Ex: Akwa", controller: addressCtrl),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildLabel("Capacité *"),
                              buildInputField(
                                "Ex: 500",
                                controller: capacityCtrl,
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildLabel("Prix (FCFA) *"),
                              buildInputField(
                                "Ex: 35000",
                                controller: priceCtrl,
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    buildLabel("Type d'événement principal *"),
                    buildDropdown(types, selectedType, (val) {
                      setState(() => selectedType = val!);
                    }),

                    buildLabel("Équipements disponibles"),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: equipements.map((e) {
                        final isSelected = selectedEquipements.contains(e);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              isSelected
                                  ? selectedEquipements.remove(e)
                                  : selectedEquipements.add(e);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.deepPurple
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              e,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    buildLabel("Photos de la salle"),
                    GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: image == null
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate,
                                        size: 40, color: Colors.deepPurple),
                                    SizedBox(height: 8),
                                    Text(
                                      "Choisir une photo",
                                      style: TextStyle(color: Colors.deepPurple),
                                    ),
                                  ],
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(image!, fit: BoxFit.cover),
                              ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Mettre à jour la salle",
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= WIDGETS =================

  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF9C27B0)],
        ),
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
            "Modifier la salle",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            "Mettez à jour les informations de votre salle",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget buildInputField(
    String hint, {
    int maxLines = 1,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget buildDropdown(
    List<String> items,
    String selected,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: selected,
        isExpanded: true,
        underline: const SizedBox(),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}