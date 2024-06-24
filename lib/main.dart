import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lottie/lottie.dart';

import 'camera_service.dart';
import 'chat_model.dart';
import 'gesture_service.dart';
import 'speech_service.dart';

void main() async {
  await dotenv.load();
  runApp(const MaterialApp(home: MainApp()));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final _cameraService = CameraService();
  final _speechService = SpeechService();
  final _chatModel = ChatModel();
  GestureService? _gestureService;

  Timer? _recordingTimer;

  @override
  void initState() {
    super.initState();
    _gestureService = GestureService(_cameraService);
    _cameraService.initializeCamera().then((_) {
      setState(() {});
    });

    _chatModel.errorNotifier.addListener(() {
      if (_chatModel.errorNotifier.value != null) {
        // Handle error
        debugPrint("Error: ${_chatModel.errorNotifier.value}");
        showErrorDialog(_chatModel.errorNotifier.value!);
      }
    });

    _speechService.isSpeaking.addListener(() {
      setState(() {});
    });
  }

  void _onLongPressStart() {
    try {
      if (_speechService.isSpeaking.value) {
        _speechService.stop();
      }
      _gestureService?.onLongPressStart();
      _startRecordingTimer();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _onLongPressEnd() {
    try {
      _stopRecordingTimer();
      _gestureService?.onLongPressEnd(_chatModel);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _startRecordingTimer() {
    debugPrint("Recording timer started");
    _recordingTimer?.cancel();
    _recordingTimer = Timer(const Duration(seconds: 30), () {
      if (_cameraService.isRecording.value) {
        _onLongPressEnd();
      }
    });
  }

  void _stopRecordingTimer() {
    debugPrint("Recording timer stopped");
    _recordingTimer?.cancel();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _stopRecordingTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        brightness: Brightness.dark,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Vision Assist'),
          backgroundColor: Colors.blueGrey[900],
          actions: [
            IconButton(
              icon: const Icon(Icons.help),
              onPressed: () {
                _speechService.speak(
                    "Hello, I can help assist you by providing information about the world around you!! Just point your camera and hold the screen with your finger for a second to speak to me!!");
                showAboutDialog(
                  context: context,
                  applicationName: "Vision Assist",
                  applicationVersion: "0.1.0",
                  applicationIcon: Lottie.asset("assets/lottie_thinking.json",
                      width: 60, height: 60),
                  children: [
                    const Text(
                        "Hello, I can help assist you by providing information about the world around you¬!\nJust point your camera and hold the screen for a second with your finger to speak to me!!"),
                  ],
                );
              },
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                // Handle menu selection
              },
              itemBuilder: (BuildContext context) {
                return {'Settings'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ),
        body: GestureDetector(
          onLongPress: () => _onLongPressStart(),
          onLongPressUp: () => _onLongPressEnd(),
          child: ValueListenableBuilder<bool>(
            valueListenable: _cameraService.isRecording,
            builder: (context, isRecording, child) {
              return Stack(
                children: [
                  Positioned.fill(
                      child: _cameraService.cameraController == null
                          ? const SizedBox(
                              width: 100,
                              height: 100,
                              child: CircularProgressIndicator(),
                            )
                          : buildCameraPreview(isRecording)),
                  Positioned.directional(
                      textDirection: TextDirection.ltr,
                      bottom: 16,
                      start: 16,
                      end: 16,
                      child: buildBottomButtons()),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildCameraPreview(isRecording) {
    return CameraPreview(
      _cameraService.cameraController!,
      child: Center(
        child: ValueListenableBuilder<bool>(
          valueListenable: _chatModel.isThinking,
          builder: (context, isThinking, child) {
            if (isRecording) {
              return OverflowBox(
                  maxWidth: 700,
                  child: Lottie.asset("assets/lottie_recording.json"));
            } else if (isThinking) {
              return Lottie.asset("assets/lottie_thinking.json",
                  width: 200, height: 200);
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }

  Widget buildBottomButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        FloatingActionButton(
          onPressed: () async {
            await _cameraService.toggleCameraLens();
            setState(() {});
          },
          child: const Icon(Icons.switch_camera),
        ),
        FloatingActionButton(
          onPressed: () => _cameraService.toggleFlash(),
          child: const Icon(Icons.flash_on),
        ),
      ],
    );
  }

  Future showErrorDialog(String error) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text(error),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        });
  }
}
