import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../screens/salle_detail_page.dart';
import '../screens/reservation_page.dart';

class SalleCard extends StatefulWidget {
  final String name;
  final String city;
  final double rating;
  final int capacity;
  final int price;
  final String image;
  final List<String> tags;

  const SalleCard({
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
  State<SalleCard> createState() => _SalleCardState();
}

class _SalleCardState extends State<SalleCard> {

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _imageSection(),
          _contentSection(context),
        ],
      ),
    );
  }

  // ---------------- IMAGE ----------------
  Widget _imageSection() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          child: Image.asset(
            widget.image, // ← on utilise maintenant widget.image
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 180,
              color: Colors.grey.shade300,
              child: const Icon(Icons.image_not_supported, size: 40),
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite_border, size: 18),
          ),
        ),
      ],
    );
  }

  // ---------------- CONTENT ----------------
  Widget _contentSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.star, size: 16, color: Colors.orange),
              Text(widget.rating.toString()),
            ],
          ),

          const SizedBox(height: 4),

          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                widget.city,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              const Icon(Icons.people, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text('${widget.capacity} pers.',
                  style: const TextStyle(fontSize: 12)),
              const Spacer(),
              Text(
                '${widget.price} FCFA',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Wrap(
            spacing: 6,
            children: widget.tags
                .map(
                  (e) => Chip(
                    label: Text(e, style: const TextStyle(fontSize: 11)),
                    backgroundColor: Colors.grey.shade100,
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SalleDetailPage(
                          name: widget.name,
                          city: widget.city,
                          rating: widget.rating,
                          capacity: widget.capacity,
                          price: widget.price,
                          image: widget.image,
                          tags: widget.tags,
                        ),
                      ),
                    );
                  },
                  child: const Text('Détails'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReservationPage(
                          name: widget.name,
                          city: widget.city,
                          price: widget.price,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Réserver',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
