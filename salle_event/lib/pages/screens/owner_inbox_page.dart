import 'package:flutter/material.dart';
import '../../../../core/colors.dart';
import 'chat_page.dart';

class OwnerInboxPage extends StatelessWidget {
  const OwnerInboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("Messages"),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          _messageTile(
            context,
            "Marie Dubois",
            "Salle Royale Akwa",
            "La salle est-elle disponible ?",
          ),

          _messageTile(
            context,
            "Paul Kamga",
            "Salle Royale Akwa",
            "Je veux réserver pour samedi",
          ),
        ],
      ),
    );
  }

  Widget _messageTile(
    BuildContext context,
    String client,
    String salle,
    String lastMessage,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatPage(
              salleName: salle,
              ownerName: client,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [

            CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(.1),
              child: Icon(
                Icons.person,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Text(
                    client,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    salle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}