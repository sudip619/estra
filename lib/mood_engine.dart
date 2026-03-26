import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter/foundation.dart';
import 'mood_provider.dart';

class CameraMoodEngine extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraMoodEngine({super.key, required this.cameras});

  @override
  State<CameraMoodEngine> createState() => _CameraMoodEngineState();
}

class _CameraMoodEngineState extends State<CameraMoodEngine> {
  CameraController? _controller;
  late FaceDetector _faceDetector;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(enableClassification: true),
    );

    // Wakes up the camera immediately if we are already logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final moodProvider = Provider.of<MoodProvider>(context, listen: false);
      if (moodProvider.isDetecting && _controller == null) {
        _initCamera();
      }
    });
  }

  Future<void> _initCamera() async {
    if (widget.cameras.isEmpty) return;

    final frontCamera = widget.cameras.firstWhere(
          (cam) => cam.lensDirection == CameraLensDirection.front,
      orElse: () => widget.cameras.first,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420, // Most stable for Android 15
    );

    try {
      await _controller!.initialize();
      if (!mounted) return;
      _controller!.startImageStream(_processImage);
    } catch (e) {
      debugPrint("Camera Init Error: $e");
    }
  }

  void _processImage(CameraImage image) async {
    final moodProvider = Provider.of<MoodProvider>(context, listen: false);
    if (_isBusy || !moodProvider.isDetecting) return;
    _isBusy = true;

    try {
      final inputImage = _buildInputImage(image);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        final smile = faces.first.smilingProbability ?? 0.0;

        // CORRECTION: Speak the same language as MoodProvider
        if (smile > 0.7) {
          moodProvider.updateMood("Radiant"); // Was "Energized"
        } else if (smile > 0.4) {
          moodProvider.updateMood("Chill");
        } else if (smile < 0.1) {
          moodProvider.updateMood("Melancholic"); // Was "Calm"
        } else {
          moodProvider.updateMood("Neutral");
        }

        moodProvider.setDetecting(false);
      }
    } catch (e) {
      debugPrint("AI Processing Error: $e");
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      _isBusy = false;
    }
  }

  InputImage _buildInputImage(CameraImage image) {
    final bytes = _concatenatePlanes(image.planes);
    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: InputImageRotation.rotation270deg,
      format: InputImageFormat.nv21,
      bytesPerRow: image.planes[0].bytesPerRow,
    );
    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  Future<void> _disposeCamera() async {
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }
  }

  @override
  void didUpdateWidget(CameraMoodEngine oldWidget) {
    super.didUpdateWidget(oldWidget);
    final isDetecting = Provider.of<MoodProvider>(context, listen: false).isDetecting;
    if (isDetecting && _controller == null) {
      _initCamera();
    } else if (!isDetecting && _controller != null) {
      _disposeCamera();
    }
  }

  @override
  void dispose() {
    _disposeCamera();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}