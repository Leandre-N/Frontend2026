import 'package:flutter/material.dart';
import 'package:salle_event/service/storage_service.dart';
import '../../../../core/colors.dart';
import 'package:salle_event/service/api_service.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/salle_card.dart';
import '../screens/my_reservations_page.dart';
import '../screens/favorites_page.dart';
import '../screens/login.dart';
import '../screens/inbox_page.dart'; // ✅ AJOUT

class ClientHomePage extends StatefulWidget {
  final String fullName;

  const ClientHomePage({
    super.key,
    required this.fullName,
  });

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  bool showSearch = true;
  bool _isLoading = true;
  List<Map<String, dynamic>> _allSalles = [];
  List<Map<String, dynamic>> _filteredSalles = [];
  String? _error;
  List _notifications = [];

  final TextEditingController _searchCtrl = TextEditingController();

  static const String baseUrl = ApiService.baseUrl;

  @override
  void initState() {
    super.initState();
    _chargerSalles();
    _checkNotifications();
  }

  Future<void> _checkNotifications() async {
    final token = await StorageService().getToken();
    if (token == null) return;

    final result = await ApiService().getNotifications(token);
    if (result['statusCode'] == 200) {
      final notifs = result['body'] as List;
      final unreadNotifs = notifs.where((n) => n['lu'] == false).toList();

      if (unreadNotifs.isNotEmpty && mounted) {
        final lastNotif = unreadNotifs.first;
        ScaffoldMessenger.of(context).showMaterialBanner(
          MaterialBanner(
            content: Text(lastNotif['message']),
            leading: const Icon(Icons.notifications_active, color: Colors.orange),
            backgroundColor: Colors.white,
            actions: [
              TextButton(
                onPressed: () async {
                  await ApiService().markNotificationsAsRead(token);
                  if (mounted) {
                    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                  }
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      
      if (mounted) {
        setState(() {
          _notifications = notifs;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _chargerSalles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await ApiService().getSalles();
    final statusCode = result['statusCode'];

    if (statusCode == 200) {
      final data = result['body'] as List;
      setState(() {
        _allSalles = data.map((s) => Map<String, dynamic>.from(s)).toList();
        _filteredSalles = List.from(_allSalles);
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = 'Impossible de charger les salles';
        _isLoading = false;
      });
    }
  }

  void _filterSalles(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSalles = List.from(_allSalles);
      } else {
        final lowercaseQuery = query.toLowerCase();
        _filteredSalles = _allSalles.where((salle) {
          final nom = (salle['nom'] ?? '').toString().toLowerCase();
          final ville = (salle['ville'] ?? '').toString().toLowerCase();
          return nom.contains(lowercaseQuery) || ville.contains(lowercaseQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          if (showSearch) _searchBar(context),
          const SizedBox(height: 6),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }


  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _chargerSalles,
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
      );
    }

    if (_filteredSalles.isEmpty) {
      return const Center(
        child: Text(
          'Aucune salle trouvée',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _chargerSalles();
        await _checkNotifications();
      },
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredSalles.length,
        itemBuilder: (context, index) {
          final salle = _filteredSalles[index];

          final imageUrl = salle['image'] != null
              ? '$baseUrl/${salle['image']}'
              : null;

          return SalleCard(
            id: salle['id'],
            ownerId: salle['proprietaire_id'], // ✅ AJOUT
            name: salle['nom'] ?? 'Sans nom',
            city: '${salle['adresse'] ?? ''}, ${salle['ville'] ?? ''}',
            rating: double.tryParse(salle['rating']?.toString() ?? '0') ?? 0.0,
            capacity: salle['capacite'] ?? 0,
            price: (salle['prix'] ?? 0).toInt(),
            imageUrl: imageUrl,
            tags: const [],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.primary,
      elevation: 0,
      toolbarHeight: 90,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bonjour,',
            style: TextStyle(fontSize: 25, color: Colors.white70),
          ),
          Text(
            widget.fullName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.menu, color: Colors.white),
          onSelected: (value) {
            if (value == 'search') {
              setState(() => showSearch = !showSearch);
            } else if (value == 'reservations') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyReservationsPage()),
              );
            } else if (value == 'favorites') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesPage()),
              );
            } else if (value == 'logout') {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (_) => false,
              );
            }
          },
          itemBuilder: (context) => [
            _menuItem('search', Icons.search, 'Recherche'),
            _menuItem('messages', Icons.message, 'Mes messages'), // ✅ AJOUT
            _menuItem('reservations', Icons.calendar_month, 'Mes réservations'),
            _menuItem('favorites', Icons.favorite_border, 'Favoris (0)'),
            _menuItem('logout', Icons.logout, 'Déconnexion'),
          ],
        ),
      ],
    );
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String text) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 10),
          Text(text),
        ],
      ),
    );
  }

  Widget _searchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.primary,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: _filterSalles,
                      decoration: const InputDecoration(
                        hintText: 'Rechercher une salle...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.tune, color: AppColors.primary),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (_) => const FilterBottomSheet(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}