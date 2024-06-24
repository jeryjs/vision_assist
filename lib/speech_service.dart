import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SpeechService {
  FlutterTts flutterTts;
  final ValueNotifier<bool> isSpeaking = ValueNotifier(false);

  SpeechService._internal() : flutterTts = FlutterTts() {
    flutterTts.setLanguage("en-US");
    flutterTts.setPitch(1.0);
    flutterTts.setSpeechRate(0.6);

    flutterTts.setStartHandler(() {
      isSpeaking.value = true;
    });

    flutterTts.setCompletionHandler(() {
      isSpeaking.value = false;
    });

    flutterTts.setErrorHandler((msg) {
      debugPrint(msg);
      isSpeaking.value = false;
    });
  }

  static final SpeechService _instance = SpeechService._internal();

  factory SpeechService() {
    return _instance;
  }

  Future<void> speak(String text) async {
    if (isSpeaking.value) {
      await flutterTts.stop();
    }
    await flutterTts.speak(text);
  }

  Future<void> stop() async {
    await flutterTts.stop();
    isSpeaking.value = false;
  }
}
