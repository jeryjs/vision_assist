# Vision Assist

Vision Assist is a groundbreaking Flutter application that brings video understanding and assistive technology to the forefront—pioneering a space where even major LLMs like ChatGPT had yet to venture in 2023. This project served as a proof-of-concept mobile application for AI Video understanding through progressive image streams.

## 🚀 Project Vision

In 2023, mainstream AI models could barely process static images, let alone comprehend video. Vision Assist set out to change that—delivering real-time video understanding and assistive feedback for users who need it most. This project demonstrates how emerging AI tools and mobile development can merge to solve critical accessibility challenges, years ahead of the curve.

## 📱 Preview
> Here in this screenshot, vision assist is describing the live video feed to the user in real time. Specifically, it said “You are seeing a keypad on a laptop and the number 5 is being pressed”
<img width="403" height="895" alt="image" src="https://github.com/user-attachments/assets/dd1012fd-9ffe-4097-9429-15cd000c10d4" />

## 🧑‍💻 Core Features

- **Real-Time Video Analysis**: Leverages the device camera for live video interpretation.
- **Speech Feedback**: Converts AI-generated insights into spoken audio using text-to-speech.
- **Audio Cues**: Integrates audio playback for enhanced multisensory feedback.
- **Generative AI Integration**: Uses Google Generative AI to interpret and synthesize video context.
- **Rich UI/UX**: Animation support via Lottie and Material Design for an intuitive, modern experience.
- **Environment Config**: Securely manages environment variables for flexible deployments.

## 🏗️ Technical Overview

Vision Assist is primarily written in Dart using the Flutter framework, ensuring cross-platform compatibility and rapid development. Key technical components include:

- **Camera & Video Processing**: Utilizes the `camera` and `flutter_ffmpeg` packages for capturing and processing real-time video streams.
- **AI Integration**: The `google_generative_ai` package enables advanced understanding of visual input, pushing the boundaries of what was possible on mobile at the time.
- **Audio & Speech**: Combines `assets_audio_player` for audio cues and `flutter_tts` for converting AI output to speech.
- **Configuration**: Employs `flutter_dotenv` for environment management, ensuring sensitive settings are handled securely.
- **Testing**: Includes a test suite for widget-level validation (`test/widget_test.dart`).

## 📂 Project Structure

- `lib/` — Core application logic and UI.
- `android/` — Android platform-specific code.
- `assets/` — Audio, image, and data assets.
- `test/` — Automated tests.
- `pubspec.yaml` — Project metadata and dependency management.

## ✨ Why Vision Assist Stands Out

This project was among the first to demonstrate the feasibility of real-time video understanding on consumer hardware, with an accessible, open approach. It’s not just an app—it’s a blueprint for innovation in AI-driven assistive technology.
