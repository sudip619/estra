//player_screen

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:marquee/marquee.dart';

import 'mood_provider.dart';
import 'smart_album_art.dart';
import 'mood_controls.dart';
import 'search_screen.dart'; // --- NEW: Import the search screen ---

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final moodData = Provider.of<MoodProvider>(context);

    return StreamBuilder<PlayerState>(
        stream: SpotifySdk.subscribePlayerState(),
        builder: (context, snapshot) {
          var track = snapshot.data?.track;
          String songTitle = track?.name ?? "No Track Playing";
          String artist = track?.artist.name ?? "Connect to Spotify";
          bool isPaused = snapshot.data?.isPaused ?? true;

          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [

                          // --- NEW: Safe floating Search Icon ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.search_rounded, color: Colors.white, size: 30),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const SearchScreen()),
                                  );
                                },
                              ),
                            ],
                          ),

                          // --- NEW: Safe spacer instead of Spacer() ---
                          const SizedBox(height: 40),

                          // --- THE MUSIC PLAYER CARD ---
                          ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                              child: Container(
                                padding: const EdgeInsets.all(25),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [

                                    SmartAlbumArt(
                                      imageUri: track?.imageUri,
                                      glowColor: moodData.starColor,
                                    ),
                                    const SizedBox(height: 25),

                                    SizedBox(
                                      height: 35,
                                      child: songTitle.length > 20
                                          ? Marquee(
                                        text: songTitle,
                                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                                        scrollAxis: Axis.horizontal,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        blankSpace: 50.0,
                                        velocity: 30.0,
                                        pauseAfterRound: const Duration(seconds: 2),
                                      )
                                          : Center(
                                        child: Text(
                                          songTitle,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),

                                    Text(
                                      "$artist • ${moodData.mood} Sync",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 14, color: Colors.white54),
                                    ),
                                    const SizedBox(height: 25),

                                    SyncSlider(
                                      currentPosition: snapshot.data?.playbackPosition ?? 0,
                                      totalDuration: track?.duration ?? 1000,
                                      activeColor: moodData.starColor,
                                    ),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.skip_previous_rounded, size: 40, color: Colors.white),
                                          onPressed: () => SpotifySdk.skipPrevious(),
                                        ),
                                        GestureDetector(
                                          onTap: () => isPaused ? SpotifySdk.resume() : SpotifySdk.pause(),
                                          child: CircleAvatar(
                                            radius: 35,
                                            backgroundColor: moodData.starColor,
                                            child: Icon(isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, color: Colors.black, size: 40),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.skip_next_rounded, size: 40, color: Colors.white),
                                          onPressed: () => SpotifySdk.skipNext(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 65),

                          const MoodControls(),

                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        });
  }
}

// --- ISOLATED SMART SLIDER WIDGET ---
class SyncSlider extends StatefulWidget {
  final int currentPosition;
  final int totalDuration;
  final Color activeColor;

  const SyncSlider({
    super.key,
    required this.currentPosition,
    required this.totalDuration,
    required this.activeColor,
  });

  @override
  State<SyncSlider> createState() => _SyncSliderState();
}

class _SyncSliderState extends State<SyncSlider> {
  bool _isDragging = false;
  double _localValue = 0.0;

  @override
  Widget build(BuildContext context) {
    double streamValue = widget.totalDuration > 0
        ? (widget.currentPosition / widget.totalDuration).clamp(0.0, 1.0)
        : 0.0;

    return Slider(
      value: _isDragging ? _localValue : streamValue,
      activeColor: widget.activeColor,
      inactiveColor: Colors.white10,
      onChangeStart: (value) {
        setState(() {
          _isDragging = true;
          _localValue = value;
        });
      },
      onChanged: (value) {
        setState(() => _localValue = value);
      },
      onChangeEnd: (value) {
        int seekPositionMs = (value * widget.totalDuration).round();
        SpotifySdk.seekTo(positionedMilliseconds: seekPositionMs);

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) setState(() => _isDragging = false);
        });
      },
    );
  }
}