import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; // Import ini wajib
import '../providers/ai_provider.dart';

class AiScreen extends ConsumerWidget {
  const AiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(aiProvider);
    final chatNotifier = ref.read(aiProvider.notifier);
    final controller = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'IT-Terms Translator',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo[900],
        centerTitle: true,
      ),
      body: Column(
        children: [
          // List Chat
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: chatState.messages.length,
              itemBuilder: (context, index) {
                final message = chatState.messages[index];
                return ChatBubble(message: message);
              },
            ),
          ),

          // Loading Indicator
          if (chatState.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: CircularProgressIndicator(color: Colors.indigo),
              ),
            ),

          // FITUR TAMBAHAN: Suggestion Chips
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildChip("Apa itu Middleware?", chatNotifier),
                _buildChip("Jelaskan API", chatNotifier),
                _buildChip("Apa itu OOP?", chatNotifier),
                _buildChip("Apa itu Git?", chatNotifier),
              ],
            ),
          ),

          // Input field
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Ketik istilah IT...',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Colors.indigo[900],
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        chatNotifier.sendMessage(controller.text);
                        controller.clear();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, AiNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        onPressed: () => notifier.sendMessage(label),
        backgroundColor: Colors.indigo[50],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(context).size.width *
              0.85, // Diperlebar sedikit agar nyaman dibaca
        ),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.indigo[700] : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isUser ? 16 : 0),
            bottomRight: Radius.circular(message.isUser ? 0 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        // Bagian Markdown untuk merapikan simbol ### dan **
        child:
            message.isUser
                ? Text(
                  message.text,
                  style: const TextStyle(color: Colors.white),
                )
                : MarkdownBody(
                  data: message.text,
                  selectable: true, // User bisa copas teks jawaban AI
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(
                      color: Colors.black87,
                      height: 1.5,
                      fontSize: 15,
                    ),
                    h3: const TextStyle(
                      color: Colors.indigo,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    strong: const TextStyle(fontWeight: FontWeight.bold),
                    listBullet: const TextStyle(color: Colors.indigo),
                  ),
                ),
      ),
    );
  }
}
