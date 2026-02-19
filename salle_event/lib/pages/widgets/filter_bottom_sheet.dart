import 'package:flutter/material.dart';
import '../../../../core/colors.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? selectedEvent;
  String? selectedCity;

  final List<String> eventTypes = [
    'Mariage',
    'Anniversaire',
    'Gala',
    'Séminaire',
    'Conférence',
    'Formation',
    'Fête',
    'Cocktail',
    'Réception',
  ];

  final List<String> cities = [
    'Toutes les villes',
    'Yaoundé',
    'Douala',
    'Bafoussam',
    'Bamenda',
    'Bertoua',
    'Ebolowa',
    'Garoua',
    'Maroua',
    'Ngaoundéré',
    'Buea',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _header(context),
            const SizedBox(height: 20),

            _sectionTitle('Type d’événement'),
            _eventDropdown(),
            _hintText(
              'Choisissez le type d’événement que vous organisez',
            ),

            const SizedBox(height: 20),

            _sectionTitle('Budget approximatif (FCFA)'),
            _budgetOptions(),

            const SizedBox(height: 20),

            _sectionTitle('Ville'),
            _cityDropdown(),
            _hintText(
              'Limitez la recherche à une ville spécifique',
            ),

            const SizedBox(height: 20),

            _smartSearch(),

            const SizedBox(height: 20),

            _actions(context),
          ],
        ),
      ),
    );
  }


  Widget _header(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Filtres de recherche',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
    );
  }

  Widget _hintText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
    );
  }

  // ---------------- EVENT DROPDOWN ----------------
  Widget _eventDropdown() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 45,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: const Text('Sélectionner un type'),
          value: selectedEvent,
          isExpanded: true,
          items: eventTypes
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              selectedEvent = value;
            });
          },
        ),
      ),
    );
  }

  Widget _cityDropdown() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 45,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCity,
          hint: const Text('Toutes les villes'),
          isExpanded: true,
          items: cities
              .map(
                (c) => DropdownMenuItem(
                  value: c,
                  child: Text(c),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              selectedCity = value;
            });
          },
        ),
      ),
    );
  }

  Widget _budgetOptions() {
    final budgets = [
      'Moins de 100K',
      '100K - 150K',
      '150K - 200K',
      '200K - 250K',
      '250K - 300K',
      'Plus de 300K',
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: budgets
            .map(
              (b) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(b, style: const TextStyle(fontSize: 12)),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _smartSearch() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Recherche intelligente',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  'Les salles correspondant à au moins 60% de vos critères sont affichées par pertinence.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                selectedEvent = null;
                selectedCity = null;
              });
            },
            child: const Text('Réinitialiser'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Appliquer les filtres',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
