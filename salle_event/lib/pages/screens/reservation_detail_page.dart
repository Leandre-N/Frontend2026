import 'package:flutter/material.dart';
import 'package:salle_event/service/api_service.dart';
import '../widgets/salle_card.dart';

class ReservationDetailPage extends StatelessWidget {
  final Map<String, dynamic> reservation;

  const ReservationDetailPage({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    final salle = reservation['salle'] ?? {};
    final status = reservation['statut'];
    final dateStr = reservation['date'];
    final montant = reservation['montant_total'];
    
    // Base URL for images
    const String baseUrl = ApiService.baseUrl;
    final imageUrl = salle['image'] != null ? '$baseUrl/${salle['image']}' : null;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Détails de la réservation',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Salle Card (simplified or reusable)
            SalleCard(
              id: salle['id'] ?? 0,
              ownerId: salle['proprietaire_id'] ?? 0, // ✅ AJOUT
              name: salle['nom'] ?? 'Salle inconnue',
              city: salle['ville'] ?? '',
              rating: 0, // Not available here
              capacity: salle['capacite'] ?? 0,
              price: salle['prix'] ?? 0,
              imageUrl: imageUrl,
              tags: const [], // Not available here
            ),
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Statut de la réservation',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 8),
                  _statusBadge(status),
                  const Divider(height: 32),
                  _infoRow('Date de l\'événement', dateStr),
                  const SizedBox(height: 12),
                  _infoRow('Montant total', '$montant FCFA'),
                  const SizedBox(height: 12),
                  _infoRow('Méthode de paiement', reservation['mode_paiement'] ?? 'N/A'),
                  const SizedBox(height: 12),
                  _infoRow('Numéro de téléphone', reservation['num_tel'] ?? 'N/A'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case 'EN_ATTENTE':
        color = Colors.orange;
        label = 'En attente';
        break;
      case 'CONFIRMEE':
        color = Colors.green;
        label = 'Réservation confirmée';
        break;
      case 'ANNULEE':
        color = Colors.red;
        label = 'Annulée';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
