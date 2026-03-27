import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'mood_provider.dart';

class SafetyValveScreen extends StatefulWidget {
  const SafetyValveScreen({super.key});

  @override
  State<SafetyValveScreen> createState() => _SafetyValveScreenState();
}

class _SafetyValveScreenState extends State<SafetyValveScreen> {
  // Local state variables for the demo UI
  double _strikeThreshold = 3.0;
  bool _emdrEnabled = true;
  bool _wearableSync = false;
  bool _autoPlayTherapy = true;

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
          "SAFETY VALVE",
          style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 3, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text("INTERVENTION THRESHOLDS", style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 2)),
            const SizedBox(height: 20),

            // --- THE THRESHOLD SLIDER ---
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Toxic Loop Tolerance", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          Text("${_strikeThreshold.toInt()} Strikes", style: const TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text("The number of consecutive negative biometrics required before the system intercepts audio playback.", style: TextStyle(color: Colors.white54, fontSize: 12)),
                      const SizedBox(height: 15),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.redAccent,
                          inactiveTrackColor: Colors.white10,
                          thumbColor: Colors.white,
                          overlayColor: Colors.redAccent.withOpacity(0.2),
                          trackHeight: 4.0,
                        ),
                        child: Slider(
                          value: _strikeThreshold,
                          min: 1,
                          max: 5,
                          divisions: 4,
                          onChanged: (val) => setState(() => _strikeThreshold = val),
                        ),
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Aggressive (1)", style: TextStyle(color: Colors.white38, fontSize: 10)),
                          Text("Lenient (5)", style: TextStyle(color: Colors.white38, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
            const Text("SYSTEM PROTOCOLS", style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 2)),
            const SizedBox(height: 20),

            // --- PROTOCOL TOGGLES ---
            _buildSettingsToggle(
              title: "Strict EMDR Grounding",
              subtitle: "Forces visual grounding exercises during an intervention.",
              value: _emdrEnabled,
              onChanged: (val) => setState(() => _emdrEnabled = val),
              accentColor: Colors.amberAccent,
            ),
            const SizedBox(height: 15),
            _buildSettingsToggle(
              title: "Auto-Play Therapeutic Audio",
              subtitle: "Automatically shifts Spotify queue to binaural beats upon interception.",
              value: _autoPlayTherapy,
              onChanged: (val) => setState(() => _autoPlayTherapy = val),
              accentColor: Colors.tealAccent,
            ),
            const SizedBox(height: 15),
            _buildSettingsToggle(
              title: "Wearable Biometric Sync",
              subtitle: "Import live HRV and BPM data from Apple HealthKit / Google Fit.",
              value: _wearableSync,
              onChanged: (val) => setState(() => _wearableSync = val),
              accentColor: Colors.greenAccent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsToggle({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required Color accentColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: SwitchListTile(
            title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ),
            value: value,
            activeColor: accentColor,
            inactiveThumbColor: Colors.white54,
            inactiveTrackColor: Colors.white10,
            onChanged: onChanged,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
        ),
      ),
    );
  }
}