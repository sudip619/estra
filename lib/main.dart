import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'mood_provider.dart';
import 'root_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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