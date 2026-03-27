import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'mood_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Hook into the brain of the app
    final moodData = Provider.of<MoodProvider>(context);

    // 2. Calculate the "Dominant State" dynamically for the demo
    String dominantMood = "Neutral";
    Duration maxDuration = Duration.zero;

    List<String> allMoods = ["Radiant", "Chill", "Neutral", "Focused", "Melancholic"];
    for (String m in allMoods) {
      if (moodData.getTimeSpent(m) > maxDuration) {
        maxDuration = moodData.getTimeSpent(m);
        dominantMood = m;
      }
    }

    // Fallback if the session just started
    if (maxDuration == Duration.zero) dominantMood = moodData.mood;

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("PROFILE", style: TextStyle(letterSpacing: 2, fontSize: 14)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- DYNAMIC AVATAR ---
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.deepPurpleAccent.withValues(alpha: 0.5),
              backgroundImage: moodData.userAvatar.isNotEmpty ? NetworkImage(moodData.userAvatar) : null,
              child: moodData.userAvatar.isEmpty
                  ? const Icon(Icons.person, size: 60, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 20),

            // --- DYNAMIC NAME ---
            Text(
                moodData.userName,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 10),

            // --- SPOTIFY STATUS ---
            Text(
                moodData.isLoggedIn ? "Spotify Account Linked" : "Spotify Disconnected",
                style: TextStyle(color: moodData.isLoggedIn ? Colors.greenAccent : Colors.redAccent)
            ),

            const SizedBox(height: 40),

            // --- DYNAMIC TELEMETRY ---
            // Note: Make sure you added the `int _totalScans = 0;` logic to mood_provider.dart like we discussed!
            Text("Total Scans: ${moodData.totalScans}", style: const TextStyle(color: Colors.white54, fontSize: 16)),
            const SizedBox(height: 8),
            Text("Dominant State: $dominantMood", style: const TextStyle(color: Colors.white54, fontSize: 16)),
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(title.toUpperCase(), style: const TextStyle(letterSpacing: 2, fontSize: 14)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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