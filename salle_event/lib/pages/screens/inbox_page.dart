import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/colors.dart';
import '../../service/api_service.dart';
import 'chat_page.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  List<dynamic> conversations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final res = await ApiService().getInbox(token);
    if (res['statusCode'] == 200) {
      setState(() {
        conversations = res['body'];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Messages"),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchConversations,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : conversations.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  itemCount: conversations.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final conv = conversations[index];
                    final otherUser = conv['other_user'];
                    final lastMsg = conv['last_message'];
                    final salle = conv['salle'];

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(
                          otherUser['nom']?[0].toUpperCase() ?? '?',
                          style: const TextStyle(color: AppColors.primary),
                        ),
                      ),
                      title: Text(otherUser['nom'] ?? 'Utilisateur'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (salle != null)
                            Text(
                              "Salle: ${salle['nom']}",
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          Text(
                            lastMsg['content'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatPage(
                              salleId: lastMsg['salle_id'] ?? 0,
                              ownerId: otherUser['id'],
                              salleName: salle?['nom'] ?? "Discussion",
                              ownerName: otherUser['nom'] ?? "Utilisateur",
                            ),
                          ),
                        ).then((_) => _fetchConversations());
                      },
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.message_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            "Aucune conversation pour le moment",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
