import 'package:flutter/material.dart';
import '../screens/login.dart';
import 'add_salle_page.dart';
import 'inbox_page.dart'; // ✅ REMPLACÉ
import 'edit_salle_page.dart';
import '../../service/api_service.dart';
import '../../service/storage_service.dart';

class OwnerHomePage extends StatefulWidget {
  const OwnerHomePage({super.key});

  @override
  State<OwnerHomePage> createState() => _OwnerHomePageState();
}

class _OwnerHomePageState extends State<OwnerHomePage> {
  bool showReservations = false;
  List<Map<String, dynamic>> salles = [];
  List _reservations = [];
  bool _isLoading = true;
  String? _error;
  int _totalReservations = 0;
  double _totalRevenue = 0;
  int _totalMessages = 0; // ✅ AJOUT

  @override
  void initState() {
    super.initState();
    _chargerDashboard();
  }

  Future<void> _chargerDashboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final token = await StorageService().getToken();
    if (token == null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return;
    }

    final result = await ApiService().getOwnerDashboard(token);
    final resReservations = await ApiService().getProprietaireReservations(token);

    if (result['statusCode'] == 200) {
      if (!mounted) return;
      setState(() {
        salles = List<Map<String, dynamic>>.from(result['body']['salles']);
        _totalReservations = result['body']['total_reservations'] ?? 0;
        _totalRevenue = (result['body']['revenus_totaux'] ?? 0).toDouble();
        _totalMessages = result['body']['total_messages'] ?? 0; // ✅ AJOUT
        if (resReservations['statusCode'] == 200) {
          _reservations = resReservations['body'];
        }
        _isLoading = false;
      });
    } else {
      if (!mounted) return;
      setState(() {
        _error = 'Erreur lors du chargement des données';
        _isLoading = false;
      });
    }
  }
  static const String baseUrl = 'http://10.0.2.2:3000';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            _statsSection(),
            _tabs(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
                  : _error != null
                      ? Center(child: Text(_error!))
                      : RefreshIndicator(
                          onRefresh: _chargerDashboard,
                          color: Colors.deepPurple,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                if (!showReservations) _addSalleButton(),
                                const SizedBox(height: 12),
                                showReservations ? _reservationList() : _salleList(),
                              ],
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _header() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8A2BE2), Color(0xFF6A1B9A)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Espace Propriétaire",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          Row(
            children: [
              const Icon(Icons.notifications, color: Colors.white),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _logout,
                child: const Icon(Icons.logout, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statsSection() {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statCard("${salles.length}", "Salles", Icons.apartment, null),
          _statCard("$_totalReservations", "Réservations", Icons.calendar_month, null),
          _statCard("${_totalRevenue.toInt()}", "Revenus", Icons.trending_up, null),
          _statCard(
            "$_totalMessages",
            "Messages",
            Icons.message_outlined,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InboxPage()), // ✅ REMPLACÉ
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _statCard(
      String value, String label, IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 85,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.deepPurple),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _tabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _tabButton("Mes Salles", !showReservations),
          _tabButton("Réservations", showReservations),
        ],
      ),
    );
  }

  Widget _tabButton(String title, bool active) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => showReservations = title == "Réservations");
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? Colors.deepPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: active ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _addSalleButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () async {
          final newSalle = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddSallePage()),
          );

          if (newSalle != null && newSalle is Map<String, dynamic>) {
            setState(() {
              salles.add(newSalle);
            });
          }
        },
        child: Container(
          height: 55,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF9C27B0)],
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: Colors.white),
              SizedBox(width: 8),
              Text(
                "Ajouter une salle",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _salleList() {
    if (salles.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: Text(
            "Aucune salle ajoutée",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: salles.map((salle) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _salleCard(salle),
        );
      }).toList(),
    );
  }

  Widget _salleCard(Map<String, dynamic> salle) {
    final imageUrl = salle["image"] != null
        ? '$baseUrl/${salle["image"]}'
        : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(14)),
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 160,
                        color: Colors.deepPurple.shade50,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.deepPurple,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => _imagePlaceholder(),
                  )
                : _imagePlaceholder(),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  salle["nom"] ?? "Sans nom",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "${salle["prix"]} FCFA",
                  style: const TextStyle(color: Colors.deepPurple),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  "${salle["ville"] ?? ''} • ${salle["adresse"] ?? ''}",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 12),
            child: Row(
              children: [
                const Icon(Icons.people, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  "${salle["capacite"] ?? 0} personnes",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.black12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditSallePage(salle: salle),
                      ),
                    ).then((updated) {
                      if (updated == true) {
                        _chargerDashboard();
                      }
                    });
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text("Modifier", style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                    side: const BorderSide(color: Colors.deepPurple),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _confirmDelete(salle),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text("Supprimer", style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  void _confirmDelete(Map<String, dynamic> salle) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Supprimer la salle"),
        content: Text("Voulez-vous vraiment supprimer la salle '${salle['nom']}' ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSalle(salle['id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Supprimer", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSalle(int id) async {
    setState(() => _isLoading = true);
    final token = await StorageService().getToken();
    if (token == null) return;
    
    final result = await ApiService().supprimerSalle(id, token);
    if (result['statusCode'] == 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Salle supprimée ✅"), backgroundColor: Colors.green),
      );
      _chargerDashboard();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de la suppression"), backgroundColor: Colors.red),
      );
      setState(() => _isLoading = false);
    }
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 160,
      width: double.infinity,
      color: Colors.deepPurple.shade100,
      child: const Center(
        child: Icon(Icons.apartment, size: 60, color: Colors.deepPurple),
      ),
    );
  }

  Widget _reservationList() {
    if (_reservations.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: Text(
            "Aucune réservation",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    return Column(
      children: _reservations.map((res) => _reservationCard(res)).toList(),
    );
  }

  Widget _reservationCard(Map<String, dynamic> res) {
    final salle = res['salle'] ?? {};
    final user = res['user'] ?? {};
    final status = res['statut'];
    final date = res['date'];
    final price = res['montant_total'];
    final phone = res['num_tel'] ?? user['telephone'] ?? 'N/A';
    final mode = res['mode_paiement'] ?? 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                salle['nom'] ?? "Salle inconnue",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text("$price FCFA",
                  style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(user['nom'] ?? 'Client inconnu',
              style: const TextStyle(fontWeight: FontWeight.w500)),
          Text("Tel: $phone ($mode)", style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_month, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(date, style: const TextStyle(fontSize: 13)),
              const Spacer(),
              _statusBadge(status),
            ],
          ),
          if (status == 'EN_ATTENTE') ...[
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateStatus(res['id'], 'ANNULEE'),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text("Refuser"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateStatus(res['id'], 'CONFIRMEE'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text("Accepter", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color = Colors.grey;
    String label = status;
    if (status == 'EN_ATTENTE') {
      color = Colors.orange;
      label = "En attente";
    } else if (status == 'CONFIRMEE') {
      color = Colors.green;
      label = "Confirmée";
    } else if (status == 'ANNULEE') {
      color = Colors.red;
      label = "Annulée";
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Future<void> _updateStatus(int id, String newStatus) async {
    setState(() => _isLoading = true);
    final token = await StorageService().getToken();
    if (token == null) return;

    final res = await ApiService().updateReservationStatus(id, newStatus, token);
    if (res['statusCode'] == 200) {
      _chargerDashboard();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['body']['message'] ?? 'Erreur')),
        );
      }
      setState(() => _isLoading = false);
    }
  }


  void _logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Déconnexion"),
        content: const Text("Voulez-vous quitter ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Non"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text("Oui"),
          ),
        ],
      ),
    );
  }
}