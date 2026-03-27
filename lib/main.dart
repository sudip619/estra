import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'mood_provider.dart';
import 'root_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- WAKE UP THE CLOUD VAULT ---
  await Supabase.initialize(
    url: 'https://cnnkihzcjgxdugowydqe.supabase.co',
    anonKey: 'sb_publishable_19l0JVk19Nzyz8DGrzasxw_I_D7kIw3',
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => MoodProvider(),
      child: const EstrallisApp(),
    ),
  );
}

class EstrallisApp extends StatelessWidget {
  const EstrallisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const RootScreen(),
    );
  }
}