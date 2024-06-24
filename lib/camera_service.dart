import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class CameraService {
  CameraController? _cameraController;
  final ValueNotifier<bool> isRecording = ValueNotifier(false);
  File? lastRecordedVideo;
  final Completer<void> _initializationCompleter = Completer<void>();

  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw CameraException(
            'No cameras available', 'No cameras found on the device');
      }
      _cameraController = CameraController(
          cameras.first, ResolutionPreset.medium,
          enableAudio: true);
      await _cameraController?.initialize();
      await _cameraController?.prepareForVideoRecording();
      _initializationCompleter.complete();
    } catch (e) {
      _initializationCompleter.completeError('Error initializing camera: $e');
    }
  }

  Future<void> startVideoRecording() async {
    await _initializationCompleter.future;
    if (_cameraController!.value.isRecordingVideo) {
      return;
    }
    try {
      await _cameraController!.startVideoRecording();
      isRecording.value = true;
    } catch (e) {
      throw CameraException('Error starting video recording', e.toString());
    }
  }

  Future<File?> stopVideoRecording() async {
    await _initializationCompleter.future;
    if (!_cameraController!.value.isRecordingVideo) {
      return null;
    }
    try {
      XFile video = await _cameraController!.stopVideoRecording();
      final filePath = "${File(video.path).parent.path}/recording.mp4";
      await video.saveTo(filePath);
      lastRecordedVideo = File(filePath);
      // Delete the original video file
      if (File(video.path).existsSync()) {
        File(video.path).deleteSync(recursive: true);
      }
      return lastRecordedVideo;
    } catch (e) {
      throw CameraException('Error stopping video recording', e.toString());
    } finally {
      isRecording.value = false;
    }
  }

  Future<void> toggleCameraLens() async {
    await _initializationCompleter.future;

    final cameras = await availableCameras();
    final lensDirection = _cameraController!.description.lensDirection;

    // Find the camera with the opposite lens direction
    CameraDescription? newCamera;
    if (lensDirection == CameraLensDirection.back) {
      newCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );
    } else {
      newCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );
    }

    // If a new camera was found, initialize it
    _cameraController = CameraController(
      newCamera,
      ResolutionPreset.medium,
      enableAudio: true,
    );
    await _cameraController!.initialize();
    await _cameraController!.prepareForVideoRecording();
    }

  Future<void> toggleFlash() async {
    await _initializationCompleter.future;
    await _cameraController?.setFlashMode(
      _cameraController?.value.flashMode != FlashMode.off
          ? FlashMode.off
          : FlashMode.torch,
    );
  }

  CameraController? get cameraController => _cameraController;

  void dispose() {
    _cameraController?.dispose();
    lastRecordedVideo?.deleteSync();
  }
}
