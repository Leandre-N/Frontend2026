import 'package:flutter/material.dart';

class AddSallePage extends StatefulWidget {
  const AddSallePage({Key? key}) : super(key: key);

  @override
  State<AddSallePage> createState() => _AddSallePageState();
}

class _AddSallePageState extends State<AddSallePage> {
  String selectedVille = "Douala";
  String selectedType = "Mariage";

  final List<String> villes = [
    "Douala",
    "Yaoundé",
    "Bafoussam",
    "Garoua"
  ];

  final List<String> types = [
    "Mariage",
    "Anniversaire",
    "Conférence",
    "Réunion"
  ];

  final List<String> equipements = [
    "Climatisation",
    "Sonorisation",
    "Éclairage LED",
    "WiFi",
    "Parking",
    "Cuisine équipée",
    "Projecteur",
    "Écran géant",
    "Tables et chaises",
    "Décoration",
    "Sécurité",
    "Jardin",
  ];

  final List<String> selectedEquipements = [];

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
                    buildInputField("Ex: Salle Royale"),

                    buildLabel("Description *"),
                    buildInputField(
                      "Décrivez votre salle...",
                      maxLines: 4,
                    ),

                    buildLabel("Ville *"),
                    buildDropdown(villes, selectedVille, (val) {
                      setState(() {
                        selectedVille = val!;
                      });
                    }),

                    buildLabel("Adresse précise *"),
                    buildInputField(
                      "Ex: Akwa, Rue de la République",
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildLabel("Capacité *"),
                              buildInputField("Ex: 500"),
                            ],
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildLabel("Prix (FCFA) *"),
                              buildInputField("Ex: 35000"),
                            ],
                          ),
                        ),
                      ],
                    ),

                    buildLabel("Type d'événement principal *"),
                    buildDropdown(types, selectedType, (val) {
                      setState(() {
                        selectedType = val!;
                      });
                    }),

                    buildLabel("Équipements disponibles"),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: equipements.map((e) {
                        final isSelected =
                            selectedEquipements.contains(e);

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                selectedEquipements.remove(e);
                              } else {
                                selectedEquipements.add(e);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.deepPurple
                                  : Colors.grey.shade200,
                              borderRadius:
                                  BorderRadius.circular(20),
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
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.image,
                              size: 40,
                              color: Colors.grey),
                          SizedBox(height: 10),
                          Text(
                            "Ajoutez des photos de votre salle",
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Format: JPG, PNG (Max 5 photos)",
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Choisir des photos",
                            style: TextStyle(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text(
                          "Publier la salle",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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

  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: 30,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF6A11CB),
            Color(0xFF9C27B0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Row(
              children: [
                Icon(Icons.arrow_back_ios,
                    color: Colors.white, size: 18),
                SizedBox(width: 6),
                Text(
                  "Retour",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          const Text(
            "Ajouter une salle",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Remplissez les informations de votre salle",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
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
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget buildInputField(String hint, {int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
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
      ValueChanged<String?> onChanged) {
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
        items: items.map((e) {
          return DropdownMenuItem(
            value: e,
            child: Text(e),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
