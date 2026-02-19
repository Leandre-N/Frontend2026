import 'package:flutter/material.dart';
import '../../../../core/colors.dart';

class ReservationPage extends StatefulWidget {
  final String name;
  final String city;
  final int price;

  const ReservationPage({
    super.key,
    required this.name,
    required this.city,
    required this.price,
  });

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  DateTime? selectedDate;
  String paymentMethod = 'MTN';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(context),
                  const SizedBox(height: 20),
                  _summaryCard(),
                  const SizedBox(height: 20),
                  _datePicker(),
                  const SizedBox(height: 20),
                  _paymentMethods(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
            _confirmButton(),
          ],
        ),
      ),
    );
  }


  Widget _header(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Row(
            children: [
              Icon(Icons.arrow_back, size: 18),
              SizedBox(width: 6),
              Text('Retour'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Réservation',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(widget.name, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }


  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _row('Salle', widget.name),
          _row('Localisation', widget.city),
          _row('Prix / jour', '${widget.price} FCFA'),
        ],
      ),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }


  Widget _datePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Date de l’événement *'),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 8),
                Text(
                  selectedDate == null
                      ? 'Sélectionner une date'
                      : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (date != null) {
      setState(() => selectedDate = date);
    }
  }


  Widget _paymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Mode de paiement *'),
        const SizedBox(height: 10),

        _paymentTile('MTN', 'MTN Mobile Money'),
        const SizedBox(height: 10),
        _paymentTile('ORANGE', 'Orange Money'),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'Après validation, vous recevrez un SMS avec les instructions de paiement.',
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _paymentTile(String value, String label) {
    final selected = paymentMethod == value;

    return GestureDetector(
      onTap: () => setState(() => paymentMethod = value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }

  // ---------------- BUTTON ----------------
  Widget _confirmButton() {
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
            if (selectedDate == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Veuillez choisir une date')),
              );
              return;
            }
          },
          child: const Text(
            'Confirmer la réservation',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
