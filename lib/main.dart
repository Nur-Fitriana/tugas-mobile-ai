import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/ai_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Memuat file .env
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IT-Terms Translator',
      theme: ThemeData(
        // Menggunakan warna Indigo agar terlihat profesional (IT banget)
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const AiScreen(),
    );
  }
}
