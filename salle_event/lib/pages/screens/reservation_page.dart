import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import '../../service/api_service.dart';
import '../../service/storage_service.dart';
import 'chat_page.dart';

class ReservationPage extends StatefulWidget {
  final int id; // Added ID to call API
  final int ownerId; // ✅ AJOUT
  final String name;
  final String city;
  final int price;

  const ReservationPage({
    super.key,
    required this.id,
    required this.ownerId, // ✅ AJOUT
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
  bool isPaymentStep = false;
  bool isLoading = false;
  final TextEditingController phoneController = TextEditingController();
  List<String> blockedDates = [];

  @override
  void initState() {
    super.initState();
    _fetchBlockedDates();
  }

  Future<void> _fetchBlockedDates() async {
    try {
      final res = await ApiService().getBlockedDates(widget.id);
      if (res['statusCode'] == 200) {
        setState(() {
          blockedDates = List<String>.from(res['body']);
        });
      }
    } catch (e) {
      print('Erreur lors de la récupération des dates bloquées: $e');
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

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
                  if (!isPaymentStep) ...[
                    _datePicker(),
                    const SizedBox(height: 20),
                    _paymentMethods(),
                  ] else ...[
                    _paymentDetailsForm(),
                  ],
                  const SizedBox(height: 120),
                ],
              ),
            ),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
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
          onTap: () {
            if (isPaymentStep) {
              setState(() => isPaymentStep = false);
            } else {
              Navigator.pop(context);
            }
          },
          child: const Row(
            children: [
              Icon(Icons.arrow_back, size: 18),
              SizedBox(width: 6),
              Text('Retour'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          isPaymentStep ? 'Paiement' : 'Réservation',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          widget.name,
          style: const TextStyle(color: Colors.grey),
        ),
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
          if (selectedDate != null)
            _row('Date',
                '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'),
          if (isPaymentStep) _row('Mode choisi', paymentMethod),
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
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CustomCalendarBottomSheet(
        blockedDates: blockedDates,
        onDateSelected: (date) {
          setState(() => selectedDate = date);
        },
      ),
    );
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
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatPage(
                  salleId: widget.id, // ✅ AJOUT
                  ownerId: widget.ownerId, // ✅ AJOUT
                  salleName: widget.name,
                  ownerName: "Propriétaire",
                ),
              ),
            );
          },
          icon: Icon(
            Icons.chat_bubble_outline,
            color: AppColors.primary,
          ),
          label: Text(
            "Écrire au propriétaire",
            style: TextStyle(color: AppColors.primary),
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            side: BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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

  Widget _paymentDetailsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Numéro de téléphone pour le retrait *'),
        const SizedBox(height: 10),
        TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: 'Ex: 6xx xxx xxx',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Le mode de paiement choisi est $paymentMethod. Veuillez entrer le numéro associé.',
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
      ],
    );
  }

  Future<void> _handlePayment() async {
    if (phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer votre numéro')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final token = await StorageService().getToken();
      if (token == null) return;

      final res = await ApiService().creerReservation(
        salleId: widget.id,
        date: selectedDate!.toIso8601String().split('T')[0],
        creneau: 'JOUR', // Default for now
        montantTotal: widget.price.toDouble(),
        numTel: phoneController.text.trim(),
        modePaiement: paymentMethod,
        token: token,
      );

      print('DEBUG: creerReservation status: ${res['statusCode']}');
      print('DEBUG: creerReservation body: ${res['body']}');

      if (res['statusCode'] == 201) {
        // Simulation d'un temps de traitement de 10 secondes
        await Future.delayed(const Duration(seconds: 10));
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Paiement effectué avec succès !'),
              backgroundColor: Colors.green,
            ),
          );
          // Retour à l'accueil (qui est maintenant la racine grâce au pushAndRemoveUntil du login)
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        if (mounted) {
          final errorMsg = res['body']['message'] ?? res['body']['error'] ?? 'Erreur inconnue';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget _confirmButton() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: SizedBox(
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            if (isPaymentStep) {
              _handlePayment();
            } else {
              if (selectedDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Veuillez choisir une date')),
                );
                return;
              }
              setState(() => isPaymentStep = true);
            }
          },
          child: Text(
            isPaymentStep ? 'Payer' : 'Confirmer la réservation',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _CustomCalendarBottomSheet extends StatefulWidget {
  final List<String> blockedDates;
  final Function(DateTime) onDateSelected;

  const _CustomCalendarBottomSheet({
    required this.blockedDates,
    required this.onDateSelected,
  });

  @override
  State<_CustomCalendarBottomSheet> createState() => _CustomCalendarBottomSheetState();
}

class _CustomCalendarBottomSheetState extends State<_CustomCalendarBottomSheet> {
  DateTime _viewDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(_viewDate.year, _viewDate.month);
    final firstDayOfMonth = DateTime(_viewDate.year, _viewDate.month, 1);
    final firstDayOffset = (firstDayOfMonth.weekday - 1) % 7;
    
    final months = ["", "Janvier", "Février", "Mars", "Avril", "Mai", "Juin", "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"];

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${months[_viewDate.month]} ${_viewDate.year}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => setState(() => _viewDate = DateTime(_viewDate.year, _viewDate.month - 1))),
                  IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => setState(() => _viewDate = DateTime(_viewDate.year, _viewDate.month + 1))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const ["LU", "MA", "ME", "JE", "VE", "SA", "DI"].map((d) => Text(d, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12))).toList(),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              itemCount: daysInMonth + firstDayOffset,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
              itemBuilder: (context, index) {
                if (index < firstDayOffset) return const SizedBox();
                final day = index - firstDayOffset + 1;
                final date = DateTime(_viewDate.year, _viewDate.month, day);
                final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                final isBlocked = widget.blockedDates.contains(dateStr);
                final isPast = date.isBefore(DateTime.now().subtract(const Duration(days: 1)));

                return GestureDetector(
                  onTap: (isBlocked || isPast) ? null : () {
                    widget.onDateSelected(date);
                    Navigator.pop(context);
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isBlocked)
                        Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.red, width: 2)),
                        ),
                      Text(
                        "$day",
                        style: TextStyle(
                          color: isBlocked ? Colors.red : (isPast ? Colors.grey.shade300 : Colors.black),
                          fontWeight: isBlocked ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          _legend(),
        ],
      ),
    );
  }

  Widget _legend() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.red, width: 2))),
          const SizedBox(width: 8),
          const Text("Indisponible", style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(width: 20),
          Container(width: 12, height: 12, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.transparent)),
          const SizedBox(width: 8),
          const Text("Disponible", style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
