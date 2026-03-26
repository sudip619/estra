import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class MoodProvider extends ChangeNotifier {
  Color _starColor = Colors.white54;
  String _mood = "Neutral";
  bool _isLoggedIn = false;
  bool _isAnalyzing = false;
  bool isDetecting = false;

  // --- THE NEW SMART IDENTITY TOGGLE ---
  bool _isVaultMode = false; // false = Discover, true = Your Library
  bool get isVaultMode => _isVaultMode;

  String get currentToken => _spotifyToken;
  Color get starColor => _starColor;
  String get mood => _mood;
  bool get isLoggedIn => _isLoggedIn;
  bool get isAnalyzing => _isAnalyzing;

  final ImagePicker _picker = ImagePicker();
  late final FaceDetector _faceDetector;

  MoodProvider() {
    _faceDetector = FaceDetector(options: FaceDetectorOptions(enableClassification: true));
  }

  String _spotifyToken = "";
  String get spotifyToken => _spotifyToken;

  void login(String token) {
    _spotifyToken = token;
    _isLoggedIn = true;
    notifyListeners();
  }

  // --- TOGGLE METHOD FOR UI ---
  void toggleVaultMode(bool value) {
    _isVaultMode = value;
    notifyListeners();
    debugPrint("Mode Switched. Your Library Mode: $_isVaultMode");
  }

  void updateMood(String newMood) {
    _mood = newMood;

    if (newMood == "Radiant") _starColor = Colors.amberAccent;
    else if (newMood == "Chill") _starColor = Colors.tealAccent;
    else if (newMood == "Neutral") _starColor = Colors.white54;
    else if (newMood == "Focused") _starColor = Colors.deepPurpleAccent;
    else if (newMood == "Melancholic") _starColor = Colors.blueGrey;
    else _starColor = Colors.grey;

    _playMoodMusic(newMood);
    notifyListeners();
  }

  Future<void> _playMoodMusic(String mood) async {
    if (_spotifyToken.isEmpty) return;

    try {
      // ==========================================
      // MODE 1: "YOUR LIBRARY" (Saved Tracks)
      // ==========================================
      if (_isVaultMode) {
        debugPrint("ESTRALLIS API: Pulling from YOUR LIBRARY...");

        final Uri libraryUri = Uri.https('api.spotify.com', '/v1/me/tracks');
        final response = await http.get(libraryUri, headers: {'Authorization': 'Bearer $_spotifyToken'});

        if (response.statusCode == 200) {
          final items = json.decode(response.body)['items'] as List;
          if (items.isNotEmpty) {
            final selectedTrack = items[Random().nextInt(items.length)]['track'];
            await SpotifySdk.play(spotifyUri: selectedTrack['uri']);
            return;
          }
        }
      }

      // ==========================================
      // MODE 2: "DISCOVER" (Smart Identity Logic)
      // ==========================================
      else {

        // --- THE CHILL MIX PROTOCOL (HARDCODED) ---
        if (mood == "Chill") {
          debugPrint("ESTRALLIS API: Bypassing search, launching Official Chill Mix directly...");
          // This is the universal static URI for Spotify's algorithmic Chill Mix
          await SpotifySdk.play(spotifyUri: 'spotify:playlist:37i9dQZF1EVHGWrwldPRtj');
          return;
        }

        // --- THE DEEP FOCUS PROTOCOL (HARDCODED) ---
        if (mood == "Focused") {
          debugPrint("ESTRALLIS API: Bypassing search, launching Official Deep Focus directly...");
          // This is the exact URI for Spotify's official Deep Focus playlist
          await SpotifySdk.play(spotifyUri: 'spotify:playlist:37i9dQZF1DWZeKCadgRdKQ');
          return;
        }

        // --- STANDARD TRACK QUERIES (Radiant, Melancholic, Neutral) ---
        String searchQuery = "";
        switch (mood) {
          case "Radiant":
            searchQuery = "pop upbeat michael jackson justin bieber";
            break;
          case "Melancholic":
            searchQuery = "indian sad acoustic emotional";
            break;
          default:
            searchQuery = "indian indie pop";
        }

        debugPrint("ESTRALLIS API: Discovering '$searchQuery'...");
        final Uri searchUri = Uri.https('api.spotify.com', '/v1/search', {'q': searchQuery, 'type': 'track'});
        final response = await http.get(searchUri, headers: {'Authorization': 'Bearer $_spotifyToken'});

        if (response.statusCode == 200) {
          final items = json.decode(response.body)['tracks']['items'] as List;
          // Clean out any null tracks
          final validItems = items.where((item) => item != null && item['uri'] != null).toList();

          if (validItems.isNotEmpty) {
            final selectedTrack = validItems[Random().nextInt(validItems.length)];
            await SpotifySdk.play(spotifyUri: selectedTrack['uri']);
          }
        } else {
          debugPrint("API Error: ${response.statusCode} - ${response.body}");
        }
      }
    } catch (e) {
      debugPrint("ESTRALLIS SYSTEM ERROR: Audio fetch failed. $e");
    }
  }

  // ... (Keep your existing scanVibe, setDetecting, and dispose methods here)
  Future<void> scanVibe() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera, preferredCameraDevice: CameraDevice.front);
      if (image == null) return;
      _isAnalyzing = true; notifyListeners();
      final inputImage = InputImage.fromFilePath(image.path);
      final faces = await _faceDetector.processImage(inputImage);
      if (faces.isNotEmpty) {
        final smileProb = faces.first.smilingProbability ?? 0.0;
        if (smileProb >= 0.70) updateMood("Radiant");
        else if (smileProb >= 0.40) updateMood("Chill");
        else if (smileProb >= 0.20) updateMood("Neutral");
        else if (smileProb > 0.05) updateMood("Focused");
        else updateMood("Melancholic");
      } else updateMood("Neutral");
    } catch (e) { debugPrint("AI Scan Failed: $e"); }
    finally { _isAnalyzing = false; notifyListeners(); }
  }

  void setDetecting(bool val) { isDetecting = val; notifyListeners(); }

  @override
  void dispose() { _faceDetector.close(); super.dispose(); }
}