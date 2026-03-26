import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'mood_provider.dart';

class TelemetryScreen extends StatelessWidget {
  const TelemetryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final moodData = Provider.of<MoodProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "ORBIT PATTERNS",
          style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 3, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. THE STATUS HEADER ---
              Text("SESSION OVERVIEW", style: TextStyle(color: moodData.starColor, fontSize: 12, letterSpacing: 2)),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildStatCard("Current State", moodData.mood, Icons.psychology_rounded, moodData.starColor)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildStatCard("Affective Slope", "+0.15", Icons.trending_up_rounded, Colors.greenAccent)),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildStatCard("Toxic Loops Averted", "2", Icons.health_and_safety_rounded, Colors.cyanAccent)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildStatCard("Session Duration", "42m", Icons.timer_outlined, Colors.white54)),
                ],
              ),

              const SizedBox(height: 40),

              // --- 2. THE SESSION LOG (Mock Data for now) ---
              const Text("BIOMETRIC LOG", style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 2)),
              const SizedBox(height: 15),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: ListView(
                        children: [
                          _buildLogEntry("10:42 AM", "Melancholic", "Space Song - Beach House", Colors.blueGrey),
                          _buildLogEntry("10:45 AM", "Focused", "Weightless - Marconi Union", Colors.deepPurpleAccent),
                          _buildLogEntry("10:51 AM", "Neutral", "Daydream - Tycho", Colors.white54),
                          _buildLogEntry("11:03 AM", "Chill", "Sunset Lover - Petit Biscuit", Colors.tealAccent),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // UI Helper for the Grid Cards

  // UI Helper for the Grid Cards
  Widget _buildStatCard(String title, String value, IconData icon, Color accentColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          // Reduced padding from 20 to 16 to give the text more horizontal space
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accentColor.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: accentColor, size: 28),
              const SizedBox(height: 12),

              // --- THE FIX: FittedBox prevents the text from wrapping ---
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                    value,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)
                ),
              ),

              const SizedBox(height: 5),
              Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  // UI Helper for the List Items
  Widget _buildLogEntry(String time, String mood, String track, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color, boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 5)]),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(mood, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                    Text(time, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(track, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}