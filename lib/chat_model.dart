import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:vision_assist/speech_service.dart';

class ChatModel {
  final _speechService = SpeechService();
  static ChatModel? _instance;
  final ChatSession chat;
  final ValueNotifier<String?> errorNotifier = ValueNotifier(null);
  final ValueNotifier<bool> isThinking = ValueNotifier(false);

  factory ChatModel() {
    return _instance ??= ChatModel._init();
  }

  ChatModel._init() : chat = _setupChatSession();

  static ChatSession _setupChatSession() {
    final apiKey = dotenv.env['API_KEY']!;
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.text("""
          You are a handy helper who enjoys talking with this person who can't see well without your help.
          You are always provided with a set of images (which is actually a video recording, broken down into
          around 3 fps) from the user's camera which you use as your eyes in the user's stead to provide the
          user with answers to whatever questions they ask or just describe the scene in 10-30 words.
          \nAlong with the frames you are also provided audio data from the video which you can link with the frames
          (i.e., first 3 frames = first 1 second of audio) to better help the user by either answering the queries
          they ask in the video, conversing with them in a very casual and friendly way or just using it as context for the recording.
          \nWhen large chunks of text are the main content, you can provide a summary of the text in detail or
          just answer the user's specific questions. When you are taught something (be it name, recognizing
          something or some knowledge), utilise it in your future responses.
      """),
      generationConfig: GenerationConfig(
        candidateCount: 1,
        temperature: 0.9,
        topP: 0.95,
        topK: 10,
        maxOutputTokens: 150,
      ),
      safetySettings: [
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
      ],
    );
    return model.startChat();
  }

  Future<void> describe(Content content) async {
    try {
      isThinking.value = true;
      await chat.sendMessage(content).then((response) {
        debugPrint(response.text);
        _speechService.speak(response.text ?? "Error");
      });
    } catch (e) {
      errorNotifier.value = e.toString();
    } finally {
      isThinking.value = false;
    }
  }
}
