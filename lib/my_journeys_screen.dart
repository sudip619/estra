import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'mood_provider.dart';

class MyJourneysScreen extends StatefulWidget {
  const MyJourneysScreen({super.key});

  @override
  State<MyJourneysScreen> createState() => _MyJourneysScreenState();
}

class _MyJourneysScreenState extends State<MyJourneysScreen> {
  bool _isExporting = false;

  // --- THE B2B DATA EXPORT ENGINE ---
  Future<void> _generateCSVReport(MoodProvider moodData) async {
    setState(() => _isExporting = true);

    // Simulate backend compilation time for the demo
    await Future.delayed(const Duration(milliseconds: 1500));

    // 1. Build the CSV Header
    StringBuffer csvString = StringBuffer();
    csvString.writeln("Date,Time,Affective_State,Toxic_Loops_Averted,Media_Track");

    // 2. Inject Live Telemetry Data
    if (moodData.sessionLogs.isEmpty) {
      csvString.writeln("Today,Live,${moodData.mood},${moodData.toxicLoopsAverted},Active Stream");
    } else {
      for (var log in moodData.sessionLogs) {
        csvString.writeln("Today,${log['time']},${log['mood']},${moodData.toxicLoopsAverted},${log['track']}");
      }
    }

    // 3. Inject Historical (Mocked) Data
    csvString.writeln("Yesterday,09:15 AM,Focused,0,Deep Focus Playlist");
    csvString.writeln("Yesterday,02:30 PM,Neutral,0,Indie Mix");
    csvString.writeln("Mar 25,11:00 AM,Melancholic,2,Acoustic Sad");
    csvString.writeln("Mar 24,08:45 PM,Radiant,0,Pop Mix");

    setState(() => _isExporting = false);

    // 4. Show the Judges the Raw Data
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.greenAccent)),
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline_rounded, color: Colors.greenAccent),
              SizedBox(width: 10),
              Text("B2B Data Exported", style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Raw CSV payload generated successfully. Ready for enterprise API transit.", style: TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 15),
              Container(
                height: 150,
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white24),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    csvString.toString(),
                    style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace', fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CLOSE", style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final moodData = Provider.of<MoodProvider>(context);

    String dominantMood = "Neutral";
    Duration maxDuration = Duration.zero;
    List<String> allMoods = ["Radiant", "Chill", "Neutral", "Focused", "Melancholic"];
    for (String m in allMoods) {
      if (moodData.getTimeSpent(m) > maxDuration) {
        maxDuration = moodData.getTimeSpent(m);
        dominantMood = m;
      }
    }
    if (maxDuration == Duration.zero) dominantMood = moodData.mood;

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
          "MY JOURNEYS",
          style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 3, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [

            // --- THE B2B CSV EXPORT BUTTON ---
            GestureDetector(
              onTap: _isExporting ? null : () => _generateCSVReport(moodData),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 55,
                decoration: BoxDecoration(
                  color: _isExporting ? Colors.white.withOpacity(0.1) : Colors.greenAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: _isExporting ? Colors.white24 : Colors.greenAccent.withOpacity(0.5)),
                  boxShadow: _isExporting ? [] : [
                    BoxShadow(color: Colors.greenAccent.withOpacity(0.2), blurRadius: 15, spreadRadius: 1)
                  ],
                ),
                child: Center(
                  child: _isExporting
                      ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2)),
                      SizedBox(width: 15),
                      Text("COMPILING SECURE PAYLOAD...", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ],
                  )
                      : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.download_rounded, color: Colors.greenAccent),
                      SizedBox(width: 10),
                      Text("GENERATE B2B CSV REPORT", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
            const Text("LONGITUDINAL ARCHIVE", style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 2)),
            const SizedBox(height: 20),

            // --- LIVE DATA: TODAY ---
            _buildJourneyCard(
              date: "TODAY",
              isLive: true,
              dominantMood: dominantMood,
              toxicLoops: moodData.toxicLoopsAverted.toString(),
              scans: moodData.totalScans.toString(),
              accentColor: moodData.starColor,
            ),

            const SizedBox(height: 15),

            // --- MOCKED DATA: PAST DAYS ---
            _buildJourneyCard(
              date: "YESTERDAY",
              dominantMood: "Focused",
              toxicLoops: "0",
              scans: "12",
              accentColor: Colors.deepPurpleAccent,
            ),
            const SizedBox(height: 15),
            _buildJourneyCard(
              date: "MARCH 25",
              dominantMood: "Chill",
              toxicLoops: "1",
              scans: "8",
              accentColor: Colors.tealAccent,
            ),
            const SizedBox(height: 15),
            _buildJourneyCard(
              date: "MARCH 24",
              dominantMood: "Melancholic",
              toxicLoops: "3",
              scans: "15",
              accentColor: Colors.blueGrey,
            ),
          ],
        ),
      ),
    );
  }

  // --- UI HELPER FOR THE CARDS ---
  Widget _buildJourneyCard({
    required String date,
    required String dominantMood,
    required String toxicLoops,
    required String scans,
    required Color accentColor,
    bool isLive = false,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isLive ? accentColor.withOpacity(0.5) : Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(date, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  if (isLive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: accentColor.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                      child: Text("LIVE SYNC", style: TextStyle(color: accentColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    )
                ],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("DOMINANT STATE", style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1)),
                      const SizedBox(height: 4),
                      Text(dominantMood, style: TextStyle(color: accentColor, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("TOXIC LOOPS AVERTED", style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1)),
                      const SizedBox(height: 4),
                      Text(toxicLoops, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}