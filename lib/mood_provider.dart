import 'package:supabase_flutter/supabase_flutter.dart';
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

  // --- USER IDENTITY STATE (For Drawer & Profile UI) ---
  String _userName = "Subject 001";
  String _userAvatar = "";
  String get userName => _userName;
  String get userAvatar => _userAvatar;

  // --- THE NEW SMART IDENTITY TOGGLE ---
  bool _isVaultMode = false; // false = Discover, true = Your Library
  bool get isVaultMode => _isVaultMode;

  // --- DIGITAL THERAPIST MEMORY ---
  int _melancholicCount = 0;
  bool _isIntervening = false;
  int _totalScans = 0;
  int get totalScans => _totalScans;
  int get melancholicCount => _melancholicCount;
  bool get isIntervening => _isIntervening;
  String get currentToken => _spotifyToken;
  Color get starColor => _starColor;
  String get mood => _mood;
  bool get isLoggedIn => _isLoggedIn;
  bool get isAnalyzing => _isAnalyzing;

  // --- TELEMETRY & BLACK BOX DATA ---
  int _toxicLoopsAverted = 0;
  final DateTime _sessionStartTime = DateTime.now();
  DateTime _lastMoodChangeTime = DateTime.now();

  final List<Map<String, dynamic>> _sessionLogs = [];
  final Map<String, Duration> _timeSpent = {
    "Radiant": Duration.zero,
    "Chill": Duration.zero,
    "Neutral": Duration.zero,
    "Focused": Duration.zero,
    "Melancholic": Duration.zero,
  };

  int get toxicLoopsAverted => _toxicLoopsAverted;
  DateTime get sessionStartTime => _sessionStartTime;
  List<Map<String, dynamic>> get sessionLogs => _sessionLogs;

  Duration getTimeSpent(String forMood) {
    Duration total = _timeSpent[forMood] ?? Duration.zero;
    if (_mood == forMood) {
      total += DateTime.now().difference(_lastMoodChangeTime);
    }
    return total;
  }

  final ImagePicker _picker = ImagePicker();
  late final FaceDetector _faceDetector;

  MoodProvider() {
    _faceDetector = FaceDetector(options: FaceDetectorOptions(enableClassification: true));
  }

  String _spotifyToken = "";
  String get spotifyToken => _spotifyToken;

  // --- UPGRADED LOGIN PROTOCOL ---
  Future<void> login(String token) async {
    _spotifyToken = token;

    try {
      final Uri profileUri = Uri.https('api.spotify.com', '/v1/me');
      final response = await http.get(profileUri, headers: {'Authorization': 'Bearer $_spotifyToken'});

      if (response.statusCode == 200) {
        final profileData = jsonDecode(response.body);

        _userName = profileData['display_name'] ?? "Unknown Subject";
        if (profileData['images'] != null && profileData['images'].isNotEmpty) {
          _userAvatar = profileData['images'][0]['url'];
        }

        await _syncUserWithSupabase(profileData);
      }
    } catch (e) {
      debugPrint("ESTRALLIS ERROR: Failed to fetch Spotify Profile: $e");
    }

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
    _totalScans++;
    // --- 1. THE INTERCEPT LOGIC (Must happen FIRST) ---
    if (newMood == "Melancholic") {
      _melancholicCount++;
      debugPrint("Melancholic Strike: $_melancholicCount/3");

      if (_melancholicCount >= 3) {
        _triggerIntervention();
        return; // Halt the normal flow
      }
    } else {
      _melancholicCount = 0; // Reset counter if any other mood is detected
    }

    // --- 2. PREVENT REDUNDANT UPDATES ---
    // If the mood hasn't actually changed, we don't need to log it again or restart the song.
    if (_mood == newMood) {
      notifyListeners(); // We still notify listeners so the 33% -> 66% progress bar updates!
      return;
    }

    // --- 3. SAVE PREVIOUS MOOD TIME ---
    if (_timeSpent.containsKey(_mood)) {
      _timeSpent[_mood] = (_timeSpent[_mood] ?? Duration.zero) + DateTime.now().difference(_lastMoodChangeTime);
    }

    _mood = newMood;
    _lastMoodChangeTime = DateTime.now(); // Reset the stopwatch for the new mood

    if (newMood == "Radiant") _starColor = Colors.amberAccent;
    else if (newMood == "Chill") _starColor = Colors.tealAccent;
    else if (newMood == "Neutral") _starColor = Colors.white54;
    else if (newMood == "Focused") _starColor = Colors.deepPurpleAccent;
    else if (newMood == "Melancholic") _starColor = Colors.blueGrey;
    else _starColor = Colors.grey;

    // --- 4. LOG THE EVENT ---
    String timeString = "${DateTime.now().hour > 12 ? DateTime.now().hour - 12 : (DateTime.now().hour == 0 ? 12 : DateTime.now().hour)}:${DateTime.now().minute.toString().padLeft(2, '0')} ${DateTime.now().hour >= 12 ? 'PM' : 'AM'}";
    _sessionLogs.insert(0, {
      "mood": newMood,
      "time": timeString,
      "color": _starColor,
      "track": "Spotify Audio Stream"
    });

    _playMoodMusic(newMood);
    notifyListeners();
  }

  // --- DIGITAL THERAPIST PROTOCOLS ---
  void _triggerIntervention() async {
    _isIntervening = true;
    _toxicLoopsAverted++; // Permanently increment the averted counter
    notifyListeners();
    debugPrint("TOXIC STATE DETECTED. Triggering Intervention.");

    if (_spotifyToken.isNotEmpty) {
      try {
        await SpotifySdk.pause();
      } catch (e) {
        debugPrint("Could not pause Spotify: $e");
      }
    }
  }

  void endIntervention(String targetMood) {
    _melancholicCount = 0;
    _isIntervening = false;

    if (targetMood == "Stay") {
      notifyListeners();
    } else {
      updateMood(targetMood);
    }
  }

  // --- SERVICE DECOUPLING PROTOCOL ---
  Future<void> switchSpotifyAccount() async {
    try {
      // 1. Sever the connection with the current Spotify account
      await SpotifySdk.disconnect();
      debugPrint("ESTRALLIS: Spotify Module Disconnected.");
    } catch (e) {
      debugPrint("ESTRALLIS ERROR: Failed to disconnect Spotify: $e");
    }

    // 2. Clear ONLY the Spotify-specific credentials
    _spotifyToken = "";
    _isLoggedIn = false; // This will slide the Login Screen back down
    _userName = "Awaiting Connection...";
    _userAvatar = "";

    // 3. CRITICAL: Do NOT wipe the telemetry!
    // _totalScans, _toxicLoopsAverted, _sessionLogs, and _timeSpent
    // all remain perfectly intact because they belong to the ESTRALLIS user, not Spotify.

    notifyListeners();
  }

  Future<void> _playMoodMusic(String mood) async {
    if (_spotifyToken.isEmpty) return;

    try {
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
      } else {
        if (mood == "Radiant") {
          debugPrint("ESTRALLIS API: Bypassing search, launching Official Pop Mix directly...");
          await SpotifySdk.play(spotifyUri: 'spotify:playlist:37i9dQZF1EQncLwOalG3K7');
          return;
        }

        if (mood == "Chill") {
          debugPrint("ESTRALLIS API: Bypassing search, launching Official Chill Mix directly...");
          await SpotifySdk.play(spotifyUri: 'spotify:playlist:37i9dQZF1EVHGWrwldPRtj');
          return;
        }

        if (mood == "Focused") {
          debugPrint("ESTRALLIS API: Bypassing search, launching Official Deep Focus directly...");
          await SpotifySdk.play(spotifyUri: 'spotify:playlist:37i9dQZF1DWZeKCadgRdKQ');
          return;
        }

        String searchQuery = "";
        switch (mood) {
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
          final validItems = items.where((item) => item != null && item['uri'] != null).toList();

          if (validItems.isNotEmpty) {
            final selectedTrack = validItems[Random().nextInt(validItems.length)];
            await SpotifySdk.play(spotifyUri: selectedTrack['uri']);
          }
        }
      }
    } catch (e) {
      debugPrint("ESTRALLIS SYSTEM ERROR: Audio fetch failed. $e");
    }
  }

  Future<void> scanVibe() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera, preferredCameraDevice: CameraDevice.front);
      if (image == null) return;
      _isAnalyzing = true; notifyListeners();
      //_totalScans++; // Increment the scan counter!
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

  Future<void> _syncUserWithSupabase(Map<String, dynamic> spotifyProfile) async {
    try {
      final supabase = Supabase.instance.client;

      String avatarUrl = 'default_subject.png';
      if (spotifyProfile['images'] != null && spotifyProfile['images'].isNotEmpty) {
        avatarUrl = spotifyProfile['images'][0]['url'];
      }

      await supabase.from('users').upsert({
        'spotify_id': spotifyProfile['id'],
        'display_name': spotifyProfile['display_name'] ?? 'Unknown Subject',
        'avatar_url': avatarUrl,
      }, onConflict: 'spotify_id');

      debugPrint("SUPABASE SYNC SUCCESS: User ${spotifyProfile['display_name']} is in the vault.");

    } catch (error) {
      debugPrint("SUPABASE SYNC FAILED: $error");
    }
  }

  @override
  void dispose() { _faceDetector.close(); super.dispose(); }
}