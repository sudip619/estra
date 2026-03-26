import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'mood_provider.dart';

class MoodControls extends StatelessWidget {
  const MoodControls({super.key});

  @override
  Widget build(BuildContext context) {
    final moodData = Provider.of<MoodProvider>(context);

    return Column(
      children: [
        // --- THE NEW VAULT / DISCOVER TOGGLE ---
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Discover", style: TextStyle(color: !moodData.isVaultMode ? Colors.white : Colors.white38, fontWeight: FontWeight.bold)),
            Switch(
              value: moodData.isVaultMode,
              activeColor: Colors.greenAccent,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.white24,
              onChanged: (val) => moodData.toggleVaultMode(val),
            ),
            Text("Your Library", style: TextStyle(color: moodData.isVaultMode ? Colors.greenAccent : Colors.white38, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 15),

        const Text("AFFECTIVE STATE OVERRIDE", style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 2)),
        const SizedBox(height: 15),

        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 10,
          children: [
            _buildMoodBtn("Melancholic", Colors.blueGrey, Icons.water_drop_rounded, moodData),
            _buildMoodBtn("Focused", Colors.deepPurpleAccent, Icons.center_focus_strong_rounded, moodData),
            _buildMoodBtn("Neutral", Colors.white54, Icons.horizontal_rule_rounded, moodData),
            _buildMoodBtn("Chill", Colors.tealAccent, Icons.waves_rounded, moodData),
            _buildMoodBtn("Radiant", Colors.amberAccent, Icons.wb_sunny_rounded, moodData),
          ],
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 65,
          child: moodData.isAnalyzing
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : ElevatedButton.icon(
            onPressed: () => moodData.scanVibe(),
            icon: const Icon(Icons.camera_alt_rounded, color: Colors.black),
            label: const Text("SCAN MY VIBE", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 10,
              shadowColor: moodData.starColor.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoodBtn(String moodName, Color color, IconData icon, MoodProvider moodData) {
    final isSelected = moodData.mood == moodName;
    return GestureDetector(
      onTap: () => moodData.updateMood(moodName),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
          border: Border.all(color: isSelected ? color : Colors.transparent, width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(icon, color: isSelected ? color : Colors.white54, size: 28),
      ),
    );
  }
}