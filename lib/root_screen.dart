import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import 'mood_provider.dart';
import 'login_screen.dart';
import 'player_screen.dart';
import 'intervention_screen.dart';
import 'aux_screens.dart';
import 'telemetry_screen.dart';
import 'my_journeys_screen.dart';
import 'safety_valve_screen.dart';
import 'premium_paywall_screen.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final moodData = Provider.of<MoodProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      drawer: const EstrallisProfileDrawer(),
      body: Stack(
        children: [
          const Positioned.fill(
            child: Center(child: StarGlowWidget()),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
            top: moodData.isLoggedIn ? 0 : screenHeight,
            left: 0, right: 0, height: screenHeight,
            child: const PlayerScreen(),
          ),
          if (moodData.isLoggedIn)
            Positioned(
              top: 50, left: 20,
              child: Builder(
                  builder: (context) {
                    return IconButton(
                      icon: const Icon(Icons.menu_rounded, color: Colors.white70, size: 30),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    );
                  }
              ),
            ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
            top: moodData.isLoggedIn ? -screenHeight : 0,
            left: 0, right: 0, height: screenHeight,
            child: const LoginScreen(),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 900),
            curve: Curves.fastOutSlowIn,
            top: moodData.isIntervening ? 0 : screenHeight,
            left: 0, right: 0, height: screenHeight,
            child: const InterventionScreen(),
          ),
        ],
      ),
    );
  }
}

// --- THE DRAWER WIDGET ---
class EstrallisProfileDrawer extends StatelessWidget {
  const EstrallisProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final moodData = Provider.of<MoodProvider>(context);

    return Drawer(
      backgroundColor: Colors.transparent,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          color: const Color(0xFF050505).withValues(alpha:0.7),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                },
                child: UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:0.05),
                    border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha:0.1))),
                  ),
                  accountName: Text(moodData.userName, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                  accountEmail: Text(
                      moodData.isLoggedIn ? "Spotify: Connected Active" : "Spotify: Disconnected",
                      style: TextStyle(color: moodData.isLoggedIn ? Colors.greenAccent : Colors.white54)
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.deepPurpleAccent.withValues(alpha:.5),
                    backgroundImage: moodData.userAvatar.isNotEmpty ? NetworkImage(moodData.userAvatar) : null,
                    child: moodData.userAvatar.isEmpty
                        ? const Icon(Icons.person_outline_rounded, color: Colors.white, size: 40)
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              _buildDrawerTile(Icons.library_music_rounded, "My Journeys", onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MyJourneysScreen()));
              }),
              _buildDrawerTile(Icons.analytics_rounded, "Orbit Patterns", onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const TelemetryScreen()));
              }),
              _buildDrawerTile(Icons.health_and_safety_rounded, "Safety Valve Settings", onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SafetyValveScreen()));
              }),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Divider(color: Colors.white24),
              ),

              // --- THE DYNAMIC SPOTIFY TOGGLE ---
              _buildDrawerTile(
                  moodData.isLoggedIn ? Icons.link_off_rounded : Icons.cable_rounded, // <-- FIXED THIS LINE
                  moodData.isLoggedIn ? "Switch Spotify Account" : "Connect Spotify",
                  isHighlight: true,
                  highlightColor: moodData.isLoggedIn ? Colors.redAccent : Colors.greenAccent,
                  onTap: () {
                    if (moodData.isLoggedIn) {
                      moodData.switchSpotifyAccount();
                      Navigator.pop(context);
                    } else {
                      Navigator.pop(context);
                    }
                  }
              ),

              // --- THE UPGRADE BUTTON ---
              _buildDrawerTile(
                  Icons.workspace_premium_rounded,
                  "Upgrade to NEURAL+",
                  isHighlight: true,
                  highlightColor: Colors.amberAccent,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PremiumPaywallScreen()));
                  }
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- UPGRADED HELPER WIDGET ---
  Widget _buildDrawerTile(IconData icon, String title, {bool isHighlight = false, Color highlightColor = Colors.greenAccent, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: isHighlight ? highlightColor : Colors.white70),
      title: Text(
          title,
          style: TextStyle(
              color: isHighlight ? highlightColor : Colors.white,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal
          )
      ),
      onTap: onTap,
    );
  }
}

// --- PHYSICS ENGINE ---
class StarGlowWidget extends StatefulWidget   {
  const StarGlowWidget({super.key});

  @override
  State<StarGlowWidget> createState() => _StarGlowWidgetState();
}

class _StarGlowWidgetState extends State<StarGlowWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000));
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moodData = Provider.of<MoodProvider>(context);

    int breathSpeedMs = 3000;
    if (moodData.mood == "Radiant") breathSpeedMs = 800;
    else if (moodData.mood == "Chill") breathSpeedMs = 2000;
    else if (moodData.mood == "Neutral") breathSpeedMs = 3000;
    else if (moodData.mood == "Focused") breathSpeedMs = 4000;
    else if (moodData.mood == "Melancholic") breathSpeedMs = 6000;

    if (_controller.duration?.inMilliseconds != breathSpeedMs) {
      _controller.duration = Duration(milliseconds: breathSpeedMs);
      if (_controller.isAnimating) _controller.repeat(reverse: true);
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 450, height: 450,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [moodData.starColor.withValues(alpha:0.5), Colors.transparent]),
            ),
          ),
        );
      },
    );
  }
}