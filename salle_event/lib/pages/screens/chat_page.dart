import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/colors.dart';
import '../../../service/api_service.dart';

class ChatPage extends StatefulWidget {
  final int salleId;
  final int ownerId;
  final String salleName;
  final String ownerName;

  const ChatPage({
    super.key,
    required this.salleId,
    required this.ownerId,
    required this.salleName,
    required this.ownerName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageController = TextEditingController();
  final List<Map<String, dynamic>> messages = [];
  bool isLoading = true;
  String? token;
  int? myId;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    myId = prefs.getInt('userId'); // Assurez-vous d'avoir stocké l'ID lors du login
    
    if (token != null) {
      await _fetchMessages();
    }
    setState(() => isLoading = false);
  }

  Future<void> _fetchMessages() async {
    final res = await ApiService().getConversation(
      otherUserId: widget.ownerId,
      salleId: widget.salleId,
      token: token!,
    );

    if (res['statusCode'] == 200) {
      final List data = res['body'];
      setState(() {
        messages.clear();
        for (var msg in data) {
          messages.add({
            "text": msg['content'],
            "isMe": msg['sender_id'] == myId,
            "time": msg['createdAt'],
          });
        }
      });
    }
  }

  Future<void> sendMessage() async {
    final content = messageController.text.trim();
    if (content.isEmpty || token == null) return;

    final originalText = content;
    messageController.clear();

    // Optimiste : voir le message de suite
    setState(() {
      messages.add({"text": originalText, "isMe": true});
    });

    final res = await ApiService().sendMessage(
      receiverId: widget.ownerId,
      content: originalText,
      salleId: widget.salleId,
      token: token!,
    );

    if (res['statusCode'] != 201) {
      // Revenir en arrière ou afficher erreur
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Échec de l'envoi du message")),
      );
    } else {
      _fetchMessages(); // Re-fetch pour avoir l'ID et l'heure correcte
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.ownerName),
            Text(
              widget.salleName,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchMessages(),
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: messages.isEmpty
                      ? const Center(child: Text("Aucun message. Dites bonjour !"))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final bool isMe = message["isMe"];

                            return Align(
                              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.all(12),
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                                ),
                                decoration: BoxDecoration(
                                  color: isMe ? AppColors.primary : Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(12),
                                    topRight: const Radius.circular(12),
                                    bottomLeft: Radius.circular(isMe ? 12 : 0),
                                    bottomRight: Radius.circular(isMe ? 0 : 12),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 5,
                                    )
                                  ],
                                ),
                                child: Text(
                                  message["text"],
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey, width: 0.2))),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          decoration: InputDecoration(
                            hintText: "Écrire au propriétaire...",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: sendMessage,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}