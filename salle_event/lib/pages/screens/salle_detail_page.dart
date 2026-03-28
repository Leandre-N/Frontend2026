import 'package:flutter/material.dart';
import 'package:salle_event/service/api_service.dart';
import '../../../../core/colors.dart';
import '../screens/reservation_page.dart';

class SalleDetailPage extends StatefulWidget {
  final int salleId;

  const SalleDetailPage({super.key, required this.salleId});

  @override
  State<SalleDetailPage> createState() => _SalleDetailPageState();
}

class _SalleDetailPageState extends State<SalleDetailPage> {
  static const String baseUrl = 'http://10.0.2.2:3000';

  bool _isLoading = true;
  Map<String, dynamic>? salle;
  String? _error;
  
  get proprio => null;

  @override
  void initState() {
    super.initState();
    _chargerSalle();
  }

  Future<void> _chargerSalle() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await ApiService().getSalleById(widget.salleId);

    if (result['statusCode'] == 200) {
      setState(() {
        salle = Map<String, dynamic>.from(result['body']);
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = 'Impossible de charger la salle';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_error != null || salle == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.grey),
              const SizedBox(height: 12),
              Text(_error ?? 'Erreur inconnue'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _chargerSalle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text(
                  'Réessayer',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final nom = salle!['nom'] ?? 'Sans nom';
    final ville = salle!['ville'] ?? '';
    final adresse = salle!['adresse'] ?? '';
    final capacite = salle!['capacite'] ?? 0;
    final prix = (salle!['prix'] ?? 0).toInt();
    final description =
        salle!['description'] ?? 'Aucune description disponible.';
    final imageUrl = salle!['image'] != null
        ? '$baseUrl/${salle!['image']}'
        : null;

    final equipements = salle!['equipements'] as List? ?? [];

    final proprio = salle!['user'];
    final propNom = proprio?['nom'] ?? 'Propriétaire';
    final propTel = proprio?['telephone'] ?? 'Non renseigné';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _imageHeader(context, imageUrl),
                  _content(
                    nom: nom,
                    ville: ville,
                    adresse: adresse,
                    capacite: capacite,
                    prix: prix,
                    description: description,
                    propNom: propNom,
                    propTel: propTel,
                    equipements: equipements,
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
            _reserveButton(
              context,
              nom: nom,
              ville: '$adresse, $ville',
              prix: prix,
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageHeader(BuildContext context, String? imageUrl) {
    return Stack(
      children: [
        imageUrl != null
            ? Image.network(
                imageUrl,
                height: 260,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _imagePlaceholder(),
              )
            : _imagePlaceholder(),
        Positioned(
          top: 12,
          left: 12,
          child: _iconBtn(Icons.arrow_back, () => Navigator.pop(context)),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: _iconBtn(Icons.favorite_border, () {}),
        ),
      ],
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 260,
      width: double.infinity,
      color: Colors.deepPurple.shade100,
      child: const Center(
        child: Icon(Icons.apartment, size: 80, color: Colors.deepPurple),
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }

  // ✅ CORRECTION ICI (fonction bien définie)
  Widget _content({
    required String nom,
    required String ville,
    required String adresse,
    required int capacite,
    required int prix,
    required String description,
    required String propNom,
    required String propTel,
    required List equipements,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  nom,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.star, color: Colors.orange, size: 18),
              const Text('N/A'),
            ],
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '$adresse, $ville',
                  style: const TextStyle(color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              _infoItem(Icons.people, '$capacite personnes'),
              const Spacer(),
              _infoItem(Icons.monetization_on, '$prix FCFA / jour'),
            ],
          ),

          const SizedBox(height: 20),

          const Text(
            'Description',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(color: Colors.grey, height: 1.5),
          ),

          const SizedBox(height: 20),

          
          if (equipements.isNotEmpty) ...[
            const Text(
              'Équipements',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: equipements.map((eq) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.deepPurple.shade100),
                  ),
                  child: Text(
                    eq['nom'] ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],

          const Text(
            'Propriétaire',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        propNom,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        propTel,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.call, color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 6),
        Text(text),
      ],
    );
  }

  Widget _reserveButton(
    BuildContext context, {
    required String nom,
    required String ville,
    required int prix,
  }) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: SizedBox(
        height: 48,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReservationPage(
                  id: widget.salleId,
                  ownerId: proprio?['id'] ?? 0, // ✅ AJOUT
                  name: nom,
                  city: ville,
                  price: prix,
                ),
              ),
            );
          },
          child: const Text(
            'Réserver maintenant',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
