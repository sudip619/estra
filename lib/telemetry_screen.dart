import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'mood_provider.dart';

class TelemetryScreen extends StatefulWidget {
  const TelemetryScreen({super.key});

  @override
  State<TelemetryScreen> createState() => _TelemetryScreenState();
}

class _TelemetryScreenState extends State<TelemetryScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final moodData = Provider.of<MoodProvider>(context);

    // Dynamic Calculations
    double loadPercentage = (moodData.melancholicCount / 3).clamp(0.0, 1.0);
    Color loadColor = loadPercentage < 0.4 ? Colors.greenAccent : loadPercentage < 0.7 ? Colors.orangeAccent : Colors.redAccent;

    // Real Session Time
    Duration sessionDuration = DateTime.now().difference(moodData.sessionStartTime);
    String formattedSessionTime = "${sessionDuration.inMinutes}m ${sessionDuration.inSeconds % 60}s";

    // Dynamic Affective Slope (Formula: Base + (Radiant Time - Melancholic Time) + Loop Bonus)
    double radiantSecs = moodData.getTimeSpent("Radiant").inSeconds.toDouble();
    double sadSecs = moodData.getTimeSpent("Melancholic").inSeconds.toDouble();
    double dynamicSlope = 0.10 + ((radiantSecs - sadSecs) * 0.001) + (moodData.toxicLoopsAverted * 0.25);
    String slopeText = (dynamicSlope >= 0 ? "+" : "") + dynamicSlope.toStringAsFixed(2);
    Color slopeColor = dynamicSlope >= 0 ? Colors.greenAccent : Colors.redAccent;

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70), onPressed: () => Navigator.pop(context)),
        title: const Text("ORBIT PATTERNS", style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 3, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("SESSION OVERVIEW", style: TextStyle(color: moodData.starColor, fontSize: 12, letterSpacing: 2)),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildStatCard("Current State", moodData.mood, Icons.psychology_rounded, moodData.starColor)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildStatCard("Affective Slope", slopeText, Icons.trending_up_rounded, slopeColor)),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildStatCard("Toxic Loops", moodData.toxicLoopsAverted.toString(), Icons.health_and_safety_rounded, Colors.cyanAccent)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildStatCard("Session Time", formattedSessionTime, Icons.timer_outlined, Colors.white54)),
                ],
              ),

              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("CUMULATIVE AFFECTIVE LOAD", style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 2)),
                  Text("${(loadPercentage * 100).toInt()}%", style: TextStyle(color: loadColor, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                height: 12, width: double.infinity,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white.withOpacity(0.1))),
                child: LayoutBuilder(builder: (context, constraints) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedContainer(duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic, width: constraints.maxWidth * loadPercentage, decoration: BoxDecoration(color: loadColor, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: loadColor.withOpacity(0.5), blurRadius: 10, spreadRadius: 1)])),
                  );
                }),
              ),

              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15)),
                child: Row(
                  children: [
                    Expanded(child: _buildTabButton(0, "BIOMETRIC LOG", Icons.list_rounded)),
                    Expanded(child: _buildTabButton(1, "TIME SPENT", Icons.pie_chart_rounded)),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.08))),
                      child: _selectedTabIndex == 0 ? _buildBiometricLogView(moodData) : _buildTimeSpentView(moodData),
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

  Widget _buildTabButton(int index, String title, IconData icon) {
    bool isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300), padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent, borderRadius: BorderRadius.circular(15)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.white38),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.white38, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ],
        ),
      ),
    );
  }

  // --- VIEW 1: DYNAMIC BIOMETRIC LOG ---
  Widget _buildBiometricLogView(MoodProvider moodData) {
    if (moodData.sessionLogs.isEmpty) {
      return const Center(child: Text("Awaiting biometrics...", style: TextStyle(color: Colors.white38, fontStyle: FontStyle.italic)));
    }
    return ListView.builder(
      itemCount: moodData.sessionLogs.length,
      itemBuilder: (context, index) {
        final log = moodData.sessionLogs[index];
        return _buildLogEntry(log['time'], log['mood'], log['track'], log['color']);
      },
    );
  }

  // --- VIEW 2: DYNAMIC TIME SPENT ---
  Widget _buildTimeSpentView(MoodProvider moodData) {
    // We calculate total time to figure out the bar percentages
    double totalSeconds = DateTime.now().difference(moodData.sessionStartTime).inSeconds.toDouble();
    if (totalSeconds == 0) totalSeconds = 1; // Prevent division by zero

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTimeRow("Radiant", moodData.getTimeSpent("Radiant"), Colors.amberAccent, totalSeconds),
        const SizedBox(height: 12),
        _buildTimeRow("Neutral", moodData.getTimeSpent("Neutral"), Colors.white54, totalSeconds),
        const SizedBox(height: 12),
        _buildTimeRow("Focused", moodData.getTimeSpent("Focused"), Colors.deepPurpleAccent, totalSeconds),
        const SizedBox(height: 12),
        _buildTimeRow("Chill", moodData.getTimeSpent("Chill"), Colors.tealAccent, totalSeconds),
        const SizedBox(height: 12),
        _buildTimeRow("Melancholic", moodData.getTimeSpent("Melancholic"), Colors.blueGrey, totalSeconds),
      ],
    );
  }

  Widget _buildTimeRow(String mood, Duration time, Color color, double totalSeconds) {
    double percentage = (time.inSeconds / totalSeconds).clamp(0.0, 1.0);
    String formattedTime = "${time.inMinutes}m ${time.inSeconds % 60}s";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(mood, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            Text(formattedTime, style: const TextStyle(color: Colors.white70)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6, width: double.infinity,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(3)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
          ),
        ),
      ],
    );
  }

  // --- EXISTING HELPERS ---
  Widget _buildStatCard(String title, String value, IconData icon, Color accentColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: accentColor.withOpacity(0.3))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: accentColor, size: 28),
              const SizedBox(height: 12),
              FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
              const SizedBox(height: 5),
              Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogEntry(String time, String mood, String track, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: color, boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 5)])),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(mood, style: TextStyle(color: color, fontWeight: FontWeight.bold)), Text(time, style: const TextStyle(color: Colors.white38, fontSize: 12))]),
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