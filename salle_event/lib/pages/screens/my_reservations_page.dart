import 'package:flutter/material.dart';
import 'package:salle_event/pages/screens/reservation_detail_page.dart';
import '../../../../core/colors.dart';
import '../../service/api_service.dart';
import '../../service/storage_service.dart';

class MyReservationsPage extends StatefulWidget {
  const MyReservationsPage({super.key});

  @override
  State<MyReservationsPage> createState() => _MyReservationsPageState();
}

class _MyReservationsPageState extends State<MyReservationsPage> {
  bool _isLoading = true;
  List _reservations = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchReservations();
  }

  Future<void> _fetchReservations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await StorageService().getToken();
      if (token == null) {
        setState(() {
          _error = "Session expirée. Veuillez vous reconnecter.";
          _isLoading = false;
        });
        return;
      }

      final res = await ApiService().getMesReservations(token);
      if (res['statusCode'] == 200) {
        setState(() {
          _reservations = res['body'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = res['body']['message'] ?? "Erreur lors de la récupération";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Erreur: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Mes réservations',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _fetchReservations,
                        child: const Text("Réessayer"),
                      )
                    ],
                  ),
                )
              : _reservations.isEmpty
                  ? const Center(child: Text("Aucune réservation trouvée"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _reservations.length,
                      itemBuilder: (context, index) {
                        final res = _reservations[index];
                        return _reservationCard(res);
                      },
                    ),
    );
  }

  Widget _reservationCard(Map<String, dynamic> res) {
    final salle = res['salle'] ?? {};
    final status = res['statut'];
    final dateStr = res['date'];
    final montant = res['montant_total'];

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReservationDetailPage(reservation: res),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    salle['nom'] ?? 'Salle inconnue',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                _statusBadge(status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(salle['ville'] ?? '',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Date', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(dateStr, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Montant', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text('$montant FCFA',
                        style: const TextStyle(
                            color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
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
        label = 'Confirmée';
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
