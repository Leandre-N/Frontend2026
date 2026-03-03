import 'package:flutter/material.dart';
import '../screens/login.dart';
import 'add_salle_page.dart';
import 'owner_inbox_page.dart'; // ✅ inbox messages

class OwnerHomePage extends StatefulWidget {
  const OwnerHomePage({super.key});

  @override
  State<OwnerHomePage> createState() => _OwnerHomePageState();
}

class _OwnerHomePageState extends State<OwnerHomePage> {
  bool showReservations = false;

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (!showReservations) _addSalleButton(),
                    const SizedBox(height: 12),
                    showReservations
                        ? _reservationList()
                        : _salleList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================

  Widget _header() {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8A2BE2), Color(0xFF6A1B9A)],
        ),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Espace Propriétaire",
            style:
                TextStyle(color: Colors.white, fontSize: 18),
          ),
          Row(
            children: [
              const Icon(Icons.notifications,
                  color: Colors.white),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _logout,
                child:
                    const Icon(Icons.logout, color: Colors.white),
              ),
            ],
          )
        ],
      ),
    );
  }

  // ================= STATS =================

  Widget _statsSection() {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceEvenly,
        children: [

          _statCard(
              "1", "Salles", Icons.apartment, null),

          _statCard(
              "2",
              "Réservations",
              Icons.calendar_month,
              null),

          _statCard(
              "350k",
              "Revenus",
              Icons.trending_up,
              null),

          // ✅ NOUVELLE CARD MESSAGE
          _statCard(
            "3",
            "Messages",
            Icons.message_outlined,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const OwnerInboxPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _statCard(
      String value,
      String label,
      IconData icon,
      VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 85,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon,
                color: Colors.deepPurple),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                  fontWeight:
                      FontWeight.bold),
            ),
            Text(
              label,
              style:
                  const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  // ================= TABS =================

  Widget _tabs() {
    return Container(
      margin:
          const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _tabButton(
              "Mes Salles", !showReservations),
          _tabButton(
              "Réservations", showReservations),
        ],
      ),
    );
  }

  Widget _tabButton(String title, bool active) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() =>
              showReservations =
                  title == "Réservations");
        },
        child: Container(
          padding:
              const EdgeInsets.symmetric(
                  vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? Colors.deepPurple
                : Colors.transparent,
            borderRadius:
                BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: active
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= ADD SALLE =================

  Widget _addSalleButton() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const AddSallePage(),
            ),
          );
        },
        child: Container(
          height: 55,
          decoration: BoxDecoration(
            gradient:
                const LinearGradient(
              colors: [
                Color(0xFF6A11CB),
                Color(0xFF9C27B0),
              ],
            ),
            borderRadius:
                BorderRadius.circular(30),
          ),
          child: const Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(Icons.add,
                  color: Colors.white),
              SizedBox(width: 8),
              Text(
                "Ajouter une salle",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= SALLES =================

  Widget _salleList() {
    return _salleCard();
  }

  Widget _salleCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color:
                  Colors.black.withOpacity(.05),
              blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(
                    top:
                        Radius.circular(14)),
            child: Image.asset(
              "assets/salle de banquet.jpg",
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,
              children: const [
                Text(
                  "Salle Royale Akwa",
                  style: TextStyle(
                      fontWeight:
                          FontWeight.bold),
                ),
                Text(
                  "350000 FCFA",
                  style: TextStyle(
                      color:
                          Colors.deepPurple),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= RESERVATIONS =================

  Widget _reservationList() {
    return Column(
      children: [
        _reservationCard(
            "Marie Dubois",
            "+237 677889900",
            "mercredi 15 janvier 2025",
            "350000 FCFA",
            true),
        const SizedBox(height: 12),
        _reservationCard(
            "Paul Kamga",
            "+237 655443322",
            "lundi 20 janvier 2025",
            "350000 FCFA",
            false),
      ],
    );
  }

  Widget _reservationCard(
      String name,
      String phone,
      String date,
      String price,
      bool pending) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color:
                  Colors.black.withOpacity(.05),
              blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
            children: [
              const Text(
                "Salle Royale Akwa",
                style: TextStyle(
                    fontWeight:
                        FontWeight.bold),
              ),
              Text(price,
                  style:
                      const TextStyle(
                          color: Colors
                              .deepPurple)),
            ],
          ),
          const SizedBox(height: 6),
          Text(name),
          Text(phone,
              style: const TextStyle(
                  color: Colors.grey)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                  Icons.calendar_month,
                  size: 16),
              const SizedBox(width: 6),
              Text(date),
            ],
          ),
          if (pending) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child:
                      ElevatedButton(
                    style: ElevatedButton
                        .styleFrom(
                            backgroundColor:
                                Colors.green),
                    onPressed: () {},
                    child: const Text(
                        "Accepter"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child:
                      ElevatedButton(
                    style: ElevatedButton
                        .styleFrom(
                            backgroundColor:
                                Colors.red),
                    onPressed: () {},
                    child:
                        const Text("Refuser"),
                  ),
                ),
              ],
            )
          ]
        ],
      ),
    );
  }

  // ================= LOGOUT =================

  void _logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Déconnexion"),
        content:
            const Text("Voulez-vous quitter ?"),
        actions: [
          TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text("Non")),
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        const LoginPage()),
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