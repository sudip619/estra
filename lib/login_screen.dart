import 'package:flutter/material.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'mood_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isInitializing = false;

  Future<void> connectToSpotify(BuildContext context) async {
    setState(() => _isInitializing = true);

    try {
      var authenticationToken = await SpotifySdk.getAccessToken(
        clientId: "62dd287d83ff42819807f7413d4c2e83",
        redirectUrl: "estrallis://callback",
        scope: "app-remote-control, user-modify-playback-state, playlist-read-private",
      );

      await Future.delayed(const Duration(seconds: 1));

      // MANDATORY: Connect the remote to allow control and state listening
      await SpotifySdk.connectToSpotifyRemote(
        clientId: "62dd287d83ff42819807f7413d4c2e83",
        redirectUrl: "estrallis://callback",
      );

      debugPrint("Remote Connected successfully!");

      if (authenticationToken.isNotEmpty) {
        if (context.mounted) {
          Provider.of<MoodProvider>(context, listen: false).login(authenticationToken);
        }
      }
    } catch (e) {
      debugPrint("Error connecting to Spotify: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isInitializing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- THE SMART UI TOGGLE ---
    // If the name is "Awaiting Connection...", we know the user pressed "Switch Account"
    final isSwitchingAccount = Provider.of<MoodProvider>(context).userName == "Awaiting Connection...";

    if (!isSwitchingAccount) {
      // =========================================================
      // STATE 1: ORIGINAL PURE BLACK MINIMAL SCREEN (App Launch)
      // =========================================================
      return Material(
        color: const Color(0xFF050505),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "ESTRALLIS",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w200,
                letterSpacing: 8,
                color: Colors.white,
                shadows: [Shadow(color: Colors.deepPurpleAccent.withOpacity(0.5), blurRadius: 20)],
              ),
            ),
            const SizedBox(height: 10),
            const Text("Enter the Nebula", style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: _isInitializing ? null : () => connectToSpotify(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: _isInitializing
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                  : const Text("INITIALIZE", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ),
          ],
        ),
      );
    } else {
      // =========================================================
      // STATE 2: GLASSMORPHIC CARD (Switching Accounts)
      // =========================================================
      return Material(
        color: Colors.transparent,
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: const Color(0xFF050505).withOpacity(0.85),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.deepPurpleAccent.withOpacity(0.1),
                        boxShadow: [
                          BoxShadow(color: Colors.deepPurpleAccent.withOpacity(0.2), blurRadius: 40, spreadRadius: 10)
                        ]
                    ),
                    child: const Icon(Icons.psychology_alt_rounded, color: Colors.deepPurpleAccent, size: 60),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "ESTRALLIS",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 10,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.deepPurpleAccent.withOpacity(0.5), blurRadius: 20)],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text("PREDICTIVE AFFECTIVE TOXICOLOGY", style: TextStyle(color: Colors.white54, letterSpacing: 2, fontSize: 10)),

                  const SizedBox(height: 80),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.lock_outline_rounded, color: Colors.white54, size: 30),
                              const SizedBox(height: 15),
                              const Text(
                                "SECURE HANDSHAKE",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "ESTRALLIS connects directly to your device's native Spotify app. To link a different account, switch profiles in your Spotify app first.",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5),
                              ),
                              const SizedBox(height: 25),

                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: _isInitializing ? null : () => connectToSpotify(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    elevation: 10,
                                    shadowColor: Colors.white24,
                                  ),
                                  child: _isInitializing
                                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                                      : const Text("INITIALIZE SYSTEM", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                                ),
                              ),
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
        ),
      );
    }
  }
}