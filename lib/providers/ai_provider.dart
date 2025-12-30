import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

// Model untuk menampung pesan chat
class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

// State untuk mengelola daftar pesan dan status loading
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;

  ChatState({required this.messages, this.isLoading = false});

  ChatState copyWith({List<ChatMessage>? messages, bool? isLoading}) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AiNotifier extends StateNotifier<ChatState> {
  AiNotifier() : super(ChatState(messages: [])) {
    _initModel();
  }

  late GenerativeModel _model;

  void _initModel() {
    // Pastikan di file .env kamu menulisnya: GEMINI_API_KEY=AIza...
    final apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      state = state.copyWith(
        messages: [
          ChatMessage(
            text: "Error: API Key tidak ditemukan di .env",
            isUser: false,
          ),
        ],
      );
      return;
    }

    // Inisialisasi model dengan instruksi khusus Informatika
    _model = GenerativeModel(
      model: 'gemini-3-flash-preview',
      apiKey: apiKey,
      systemInstruction: Content.system(
        "Kamu adalah IT-Terms Translator. Tugasmu menjelaskan istilah Informatika "
        "yang sulit menjadi sangat sederhana dalam bahasa Indonesia.",
      ),
    );
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Tambahkan pesan user ke layar dan set loading true
    state = state.copyWith(
      messages: [...state.messages, ChatMessage(text: text, isUser: true)],
      isLoading: true,
    );

    try {
      final response = await _model.generateContent([Content.text(text)]);

      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(
            text: response.text ?? 'Maaf, saya tidak menemukan penjelasan itu.',
            isUser: false,
          ),
        ],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(
            text: 'Error: Pastikan koneksi internet stabil.',
            isUser: false,
          ),
        ],
        isLoading: false,
      );
    }
  }
}

// Provider yang akan digunakan oleh UI
final aiProvider = StateNotifierProvider<AiNotifier, ChatState>((ref) {
  return AiNotifier();
});
