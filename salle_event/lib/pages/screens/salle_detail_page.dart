import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../screens/reservation_page.dart';


class SalleDetailPage extends StatelessWidget {
  final String name;
  final String city;
  final double rating;
  final int capacity;
  final int price;
  final String image;
  final List<String> tags;

  const SalleDetailPage({
    super.key,
    required this.name,
    required this.city,
    required this.rating,
    required this.capacity,
    required this.price,
    required this.image,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _imageHeader(context),
                  _content(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
            _reserveButton(context),
          ],
        ),
      ),
    );
  }


  Widget _imageHeader(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          image,
          height: 260,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
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


  Widget _content() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.star, color: Colors.orange, size: 18),
              Text(rating.toString()),
            ],
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(city, style: const TextStyle(color: Colors.grey)),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              _infoItem(Icons.people, '$capacity personnes'),
              const Spacer(),
              _infoItem(Icons.monetization_on, '$price FCFA / jour'),
            ],
          ),

          const SizedBox(height: 20),

          const Text(
            'Description',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text(
            'Une salle élégante et spacieuse idéale pour vos mariages et événements prestigieux.',
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 16),

          const Text(
            'Types d’événements',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: const [
              Chip(label: Text('Mariage')),
              Chip(label: Text('Gala')),
              Chip(label: Text('Anniversaire')),
            ],
          ),

          const SizedBox(height: 16),

          const Text(
            'Équipements',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: const [
              Chip(label: Text('Climatisation')),
              Chip(label: Text('Parking')),
              Chip(label: Text('Traiteur')),
              Chip(label: Text('Sonorisation')),
              Chip(label: Text('Éclairage')),
            ],
          ),

          const SizedBox(height: 20),

          const Text(
            'Propriétaire',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: const Text('Martin Kamga'),
            subtitle: const Text('+237 699 123 456'),
            trailing: const Icon(Icons.call),
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


 Widget _reserveButton(BuildContext context) {
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
                name: name,
                city: city,
                price: price,
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