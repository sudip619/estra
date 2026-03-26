import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, title: const Text("PROFILE", style: TextStyle(letterSpacing: 2, fontSize: 14))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(radius: 60, backgroundColor: Colors.deepPurpleAccent.withValues(alpha: 0.5), child: const Icon(Icons.person, size: 60, color: Colors.white)),
            const SizedBox(height: 20),
            const Text("Subject 001", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Spotify Account Linked", style: TextStyle(color: Colors.greenAccent)),
            const SizedBox(height: 40),
            const Text("Total Scans: 42", style: TextStyle(color: Colors.white54)),
            const Text("Primary State: Radiant", style: TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}

class SimplePlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  const SimplePlaceholderScreen({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, title: Text(title.toUpperCase(), style: const TextStyle(letterSpacing: 2, fontSize: 14))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.white24),
            const SizedBox(height: 20),
            Text("$title Data Empty", style: const TextStyle(color: Colors.white54, fontSize: 18)),
          ],
        ),
      ),
    );
  }
}