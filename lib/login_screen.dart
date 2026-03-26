import 'package:flutter/material.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:provider/provider.dart';
import 'mood_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> connectToSpotify(BuildContext context) async {
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
            content: Text('Failed to connect to Spotify: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
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
            onPressed: () => connectToSpotify(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text("INITIALIZE"),
          ),
        ],
      ),
    );
  }
}