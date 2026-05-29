import 'dart:async';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

class VisionService {
  CameraController? cameraController;
  ObjectDetector? _objectDetector;
  bool _isProcessing = false;
  bool isCameraInitialized = false;

  final _detectedObjectsController = StreamController<List<DetectedObject>>.broadcast();
  Stream<List<DetectedObject>> get detectedObjectsStream => _detectedObjectsController.stream;

  // Initialize Camera and ML Kit Object Detector
  Future<void> init() async {
    try {
      // 1. Initialize ML Kit Object Detector.
      // Try to load a custom trained local TFLite model first, with graceful fallback to the default detector.
      try {
        final options = LocalObjectDetectorOptions(
          modelPath: 'assets/ml/custom_detector.tflite',
          mode: DetectionMode.stream,
          classifyObjects: true,
          multipleObjects: true,
        );
        _objectDetector = ObjectDetector(options: options);
      } catch (e) {
        final options = ObjectDetectorOptions(
          mode: DetectionMode.stream,
          classifyObjects: true,
          multipleObjects: true,
        );
        _objectDetector = ObjectDetector(options: options);
      }

      // 2. Initialize Camera (use first available camera)
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        cameraController = CameraController(
          cameras.first,
          ResolutionPreset.medium,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.yuv420,
        );

        await cameraController!.initialize();
        isCameraInitialized = true;
      }
    } catch (e) {
      isCameraInitialized = false;
    }
  }

  // Start processing camera stream frames
  void startDetection() {
    final controller = cameraController;
    if (controller == null || !isCameraInitialized) return;

    controller.startImageStream((CameraImage image) {
      if (_isProcessing) return;
      _isProcessing = true;

      _processCameraImage(image).then((objects) {
        if (!_detectedObjectsController.isClosed) {
          _detectedObjectsController.add(objects);
        }
        _isProcessing = false;
      }).catchError((e) {
        _isProcessing = false;
      });
    });
  }

  // Stop camera stream
  Future<void> stopDetection() async {
    if (cameraController != null && cameraController!.value.isStreamingImages) {
      await cameraController!.stopImageStream();
    }
  }

  // Process a single CameraImage frame
  Future<List<DetectedObject>> _processCameraImage(CameraImage image) async {
    final detector = _objectDetector;
    if (detector == null) return [];

    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) return [];

    return await detector.processImage(inputImage);
  }

  // Convert CameraImage to InputImage for ML Kit using the correct InputImageMetadata API
  InputImage? _inputImageFromCameraImage(CameraImage image) {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
      const InputImageRotation imageRotation = InputImageRotation.rotation0deg;
      const InputImageFormat inputImageFormat = InputImageFormat.nv21; // Standard format for Android YUV

      final metadata = InputImageMetadata(
        size: imageSize,
        rotation: imageRotation,
        format: inputImageFormat,
        bytesPerRow: image.planes[0].bytesPerRow,
      );

      return InputImage.fromBytes(bytes: bytes, metadata: metadata);
    } catch (e) {
      return null;
    }
  }

  // Close and dispose resources
  Future<void> dispose() async {
    await stopDetection();
    await cameraController?.dispose();
    await _objectDetector?.close();
    await _detectedObjectsController.close();
  }
}
