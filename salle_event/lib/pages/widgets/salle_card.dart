import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../screens/salle_detail_page.dart';
import '../screens/reservation_page.dart';

class SalleCard extends StatefulWidget {
  final int id;
  final String name;
  final String city;
  final double rating;
  final int capacity;
  final int price;
  final String? imageUrl;
  final List<String> tags;

  const SalleCard({
    super.key,
    required this.id,
    required this.name,
    required this.city,
    required this.rating,
    required this.capacity,
    required this.price,
    this.imageUrl,
    required this.tags,
  });

  @override
  State<SalleCard> createState() => _SalleCardState();
}

class _SalleCardState extends State<SalleCard> {
  bool isFavorite = false;

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
          child: widget.imageUrl != null
              ? Image.network(
                  widget.imageUrl!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 180,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => _imagePlaceholder(),
                )
              : _imagePlaceholder(),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: GestureDetector(
            onTap: () => setState(() => isFavorite = !isFavorite),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                size: 18,
                color: isFavorite ? Colors.red : Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      color: Colors.deepPurple.shade100,
      child: const Center(
        child: Icon(Icons.apartment, size: 60, color: Colors.deepPurple),
      ),
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
              Text(widget.rating.toStringAsFixed(1)),
            ],
          ),

          const SizedBox(height: 4),

          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.city,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              const Icon(Icons.people, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '${widget.capacity} pers.',
                style: const TextStyle(fontSize: 12),
              ),
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

          if (widget.tags.isNotEmpty)
            Wrap(
              spacing: 6,
              children: widget.tags
                  .take(3)
                  .map(
                    (e) => Chip(
                      label: Text(e, style: const TextStyle(fontSize: 11)),
                      backgroundColor: Colors.grey.shade100,
                      padding: EdgeInsets.zero,
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
                    // ✅ On passe uniquement l'id
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SalleDetailPage(salleId: widget.id),
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
                          id: widget.id,
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