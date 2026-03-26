import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:spotify_sdk/models/image_uri.dart'; // --- THE FIX: Imported the exact Spotify type ---

class SmartAlbumArt extends StatefulWidget {
  final ImageUri? imageUri; // --- THE FIX: Changed from String? to ImageUri? ---
  final Color glowColor;

  const SmartAlbumArt({super.key, this.imageUri, required this.glowColor});

  @override
  State<SmartAlbumArt> createState() => _SmartAlbumArtState();
}

class _SmartAlbumArtState extends State<SmartAlbumArt> {
  Future<Uint8List?>? _imageFuture;

  @override
  void initState() {
    super.initState();
    _fetchImage(widget.imageUri);
  }

  @override
  void didUpdateWidget(SmartAlbumArt oldWidget) {
    super.didUpdateWidget(oldWidget);
    // We check the raw string value of the URI to see if the song actually changed
    if (widget.imageUri?.raw != oldWidget.imageUri?.raw) {
      _fetchImage(widget.imageUri);
    }
  }

  void _fetchImage(ImageUri? uri) { // --- THE FIX: Changed from String? to ImageUri? ---
    if (uri != null) {
      _imageFuture = SpotifySdk.getImage(
        imageUri: uri,
        dimension: ImageDimension.large,
      );
    } else {
      _imageFuture = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.glowColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: widget.glowColor.withValues(alpha: 0.2),
            blurRadius: 30,
            spreadRadius: 5,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: _imageFuture == null
            ? Icon(Icons.music_note_rounded, size: 70, color: widget.glowColor.withValues(alpha: 0.8))
            : FutureBuilder<Uint8List?>(
          future: _imageFuture,
          builder: (context, snapshot) {
            // Premium UI Fix: Smooth crossfade instead of loading spinners
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: (snapshot.hasData && snapshot.data != null)
                  ? Image.memory(
                snapshot.data!,
                key: ValueKey(widget.imageUri?.raw ?? 'none'), // Updated key
                fit: BoxFit.cover,
                width: 160,
                height: 160,
              )
                  : Icon(
                Icons.music_note_rounded,
                key: const ValueKey('placeholder'),
                size: 70,
                color: widget.glowColor.withValues(alpha: 0.8),
              ),
            );
          },
        ),
      ),
    );
  }
}