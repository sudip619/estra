import 'aux_screens.dart'; // Add this near your other imports
import 'telemetry_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'mood_provider.dart';
import 'login_screen.dart';
import 'player_screen.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final moodData = Provider.of<MoodProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      // --- THE SLIDING PROFILE DRAWER ---
      drawer: const EstrallisProfileDrawer(),

      body: Stack(
        children: [
          // 1. The Breathing Aura Orb (Bottom Layer)
          const Positioned.fill(
            child: Center(child: StarGlowWidget()),
          ),

          // 2. The Music Player Screen (Middle Layer)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
            top: moodData.isLoggedIn ? 0 : screenHeight,
            left: 0,
            right: 0,
            height: screenHeight,
            child: const PlayerScreen(),
          ),

          // 3. The Hamburger Menu Button (Top Layer, above the Player)
          // We only show this if the user is logged in so it doesn't float over the login screen
          if (moodData.isLoggedIn)
            Positioned(
              top: 50,
              left: 20,
              child: Builder(
                  builder: (context) {
                    return IconButton(
                      icon: const Icon(Icons.menu_rounded, color: Colors.white70, size: 30),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    );
                  }
              ),
            ),

          // 4. The Login Screen (Slides Away)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
            top: moodData.isLoggedIn ? -screenHeight : 0,
            left: 0,
            right: 0,
            height: screenHeight,
            child: const LoginScreen(),
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
    return Drawer(
      backgroundColor: Colors.transparent,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          color: const Color(0xFF050505).withValues(alpha:0.7),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // User Header (Make it clickable to go to profile)
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
                  accountName: const Text("Subject 001", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                  accountEmail: Text(
                      Provider.of<MoodProvider>(context).isLoggedIn
                          ? "Spotify: Connected Active"
                          : "Spotify: Disconnected",
                      style: TextStyle(
                          color: Provider.of<MoodProvider>(context).isLoggedIn
                              ? Colors.greenAccent
                              : Colors.white54
                      )
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.deepPurpleAccent.withValues(alpha:.5),
                    child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 40),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Navigation Options
              _buildDrawerTile(Icons.library_music_rounded, "My Journeys", onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SimplePlaceholderScreen(title: "My Journeys", icon: Icons.library_music_rounded)));
              }),

              // --- WIRED UP NAVIGATION HERE ---
              _buildDrawerTile(
                  Icons.analytics_rounded,
                  "Orbit Patterns",
                  onTap: () {
                    Navigator.pop(context); // Close the drawer first
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TelemetryScreen()),
                    );
                  }
              ),
              // --------------------------------

              _buildDrawerTile(Icons.health_and_safety_rounded, "Safety Valve Settings", onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SimplePlaceholderScreen(title: "Safety Settings", icon: Icons.health_and_safety_rounded)));
              }),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Divider(color: Colors.white24),
              ),

              _buildDrawerTile(Icons.cable_rounded, "Connect Spotify Account", isHighlight: true),

              _buildDrawerTile(Icons.settings_rounded, "System Preferences", onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SimplePlaceholderScreen(title: "Preferences", icon: Icons.settings_rounded)));
              }),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGET ---
  Widget _buildDrawerTile(IconData icon, String title, {bool isHighlight = false, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: isHighlight ? Colors.greenAccent : Colors.white70),
      title: Text(
          title,
          style: TextStyle(
              color: isHighlight ? Colors.greenAccent : Colors.white,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal
          )
      ),
      onTap: onTap,
    );
  }
}

// --- PHYSICS ENGINE ---
class StarGlowWidget extends StatefulWidget {
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
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
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
    if (moodData.mood == "Radiant") {
      breathSpeedMs = 800;
    } else if (moodData.mood == "Chill") {
      breathSpeedMs = 2000;
    } else if (moodData.mood == "Neutral") {
      breathSpeedMs = 3000;
    } else if (moodData.mood == "Focused") {
      breathSpeedMs = 4000;
    } else if (moodData.mood == "Melancholic") {
      breathSpeedMs = 6000;
    }

    if (_controller.duration?.inMilliseconds != breathSpeedMs) {
      _controller.duration = Duration(milliseconds: breathSpeedMs);
      if (_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 450,
            height: 450,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  moodData.starColor.withValues(alpha:0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}