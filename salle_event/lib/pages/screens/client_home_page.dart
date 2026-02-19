import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/salle_card.dart';
import '../screens/my_reservations_page.dart';
import '../screens/favorites_page.dart';
import '../screens/login.dart';

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

  
  final List<Map<String, dynamic>> salles = [
    {
      'name': 'Salle Royale',
      'city': 'Akwa, Douala',
      'rating': 4.8,
      'capacity': 500,
      'price': 250000,
      'image': 'assets/salle de banquet.jpg',
      'tags': ['Climatisation', 'Parking', 'Traiteur'],
    },
    {
      'name': 'Centre des Congrès',
      'city': 'Bonanjo, Douala',
      'rating': 4.5,
      'capacity': 350,
      'price': 200000,
      'image': 'assets/salle de conference.jpg',
      'tags': ['Décoration', 'Parking', 'Climatisation'],
    },
    {
      'name': 'BK Hotel',
      'city': 'Bonaberi, Douala',
      'rating': 3.9,
      'capacity': 250,
      'price': 180000,
      'image': 'assets/salle de banquet.jpg',
      'tags': ['Décoration', 'Parking'],
    },
    {
      'name': 'PLACE SAINT BENOIT',
      'city': 'Bonaprisp, Douala',
      'rating': 4.9,
      'capacity': 300,
      'price': 400000,
      'image': 'assets/salle mariage.jpg',
      'tags': ['Décoration', 'Parking','climatisation','traiteur','annimation'],
    },
    {
      'name': 'SALLE DE FETE ARENA',
      'city': 'Bali, Douala',
      'rating': 3.9,
      'capacity': 500,
      'price': 600000,
      'image': 'assets/salle de conference.jpg',
      'tags': ['Décoration', 'Parking','climatisation','securite','annimation'],
    },
    {
      'name': 'SALLE SAPHIR',
      'city': 'AKWA, Douala',
      'rating': 4.1,
      'capacity': 600,
      'price': 800000,
      'image': 'assets/salle mariage.jpg',
      'tags': ['Décoration', 'Parking'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          if (showSearch) _searchBar(context),
          const SizedBox(height: 6),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: salles.length,
              itemBuilder: (context, index) {
                final salle = salles[index];
                return SalleCard(
                  name: salle['name'],
                  city: salle['city'],
                  rating: salle['rating'],
                  capacity: salle['capacity'],
                  price: salle['price'],
                  image: salle['image'],
                  tags: List<String>.from(salle['tags']),
                );
              },
            ),
          ),
        ],
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
            style: TextStyle(
              fontSize: 25,
              color: Colors.white70,
            ),
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
            _menuItem('reservations', Icons.calendar_month, 'Mes réservations'),
            _menuItem('favorites', Icons.favorite_border, 'Favoris (0)'),
            _menuItem('logout', Icons.logout, 'Déconnexion'),
          ],
        ),
      ],
    );
  }

  PopupMenuItem<String> _menuItem(
    String value,
    IconData icon,
    String text,
  ) {
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
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
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
