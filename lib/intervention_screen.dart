import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'mood_provider.dart';

class InterventionScreen extends StatefulWidget {
  const InterventionScreen({super.key});

  @override
  State<InterventionScreen> createState() => _InterventionScreenState();
}

class _InterventionScreenState extends State<InterventionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _emdrController;
  late Animation<Alignment> _emdrAnimation;

  @override
  void initState() {
    super.initState();

    // A 3.5-second sweep is optimal for calming bilateral stimulation
    _emdrController = AnimationController(vsync: this, duration: const Duration(milliseconds: 3500));

    // The orb will smoothly pan from the far left to the far right
    _emdrAnimation = AlignmentTween(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).animate(CurvedAnimation(parent: _emdrController, curve: Curves.easeInOutSine));

    _emdrController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _emdrController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MoodProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        color: Colors.black.withValues(alpha: 0.95), // The deep blackout overlay
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // --- LAYER 1: The Passive EMDR Orb (Background) ---
            AnimatedBuilder(
              animation: _emdrAnimation,
              builder: (context, child) {
                return Align(
                  alignment: _emdrAnimation.value,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.tealAccent.withValues(alpha: 0.15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.tealAccent.withValues(alpha: 0.1),
                            blurRadius: 60,
                            spreadRadius: 30,
                          )
                        ]
                    ),
                  ),
                );
              },
            ),

            // --- LAYER 2: The Autonomy Nudge Matrix (Foreground) ---
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.waves_rounded, color: Colors.white54, size: 40),
                      const SizedBox(height: 30),

                      const Text(
                        "The current acoustic environment is heavy.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 18, height: 1.5),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Let's shift the atmosphere.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),

                      const SizedBox(height: 80),

                      // Button 1: The Off-Ramp (Chill)
                      _buildNudgeButton(
                        label: "SHIFT TO CHILL",
                        icon: Icons.spa_rounded,
                        color: Colors.tealAccent,
                        onTap: () => provider.endIntervention("Chill"),
                      ),

                      const SizedBox(height: 20),

                      // Button 2: The Off-Ramp (Focused)
                      _buildNudgeButton(
                        label: "SHIFT TO FOCUSED",
                        icon: Icons.center_focus_strong_rounded,
                        color: Colors.deepPurpleAccent,
                        onTap: () => provider.endIntervention("Focused"),
                      ),

                      const SizedBox(height: 40),

                      // Button 3: The Autonomy Respect (Stay)
                      TextButton(
                        onPressed: () => provider.endIntervention("Stay"),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white54,
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                        ),
                        child: const Text(
                          "STAY IN THE VAULT",
                          style: TextStyle(letterSpacing: 2, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to keep the buttons looking unified and premium
  Widget _buildNudgeButton({required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: color, size: 20),
        label: Text(
          label,
          style: TextStyle(color: Colors.white, letterSpacing: 1.5, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          side: BorderSide(color: color.withValues(alpha: 0.5), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: color.withValues(alpha: 0.05),
        ),
      ),
    );
  }
}