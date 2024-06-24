import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'camera_service.dart';
import 'chat_model.dart';
import 'utils.dart';

class GestureService {
  final CameraService _cameraService;
  final FlutterFFmpeg _ffmpeg = FlutterFFmpeg();

  GestureService(this._cameraService);

  void onLongPressStart() async {
    playBeepSound(Beep.start);

    await _cameraService.startVideoRecording();
  }

  void onLongPressEnd(ChatModel chatModel) async {
    playBeepSound(Beep.end);

    final video = await _cameraService.stopVideoRecording();
    if (video != null) {
      final audio = await extractAudioData(video);
      final frames = await extractFramesData(video);
      await video.delete();

      final prompt = Content.multi([
        DataPart("audio/aac", audio),
        ...frames.map((frame) => DataPart("image/jpeg", frame)),
      ]);
      await chatModel.describe(prompt);
    }
  }

  Future<String> _getNextModelDataFolderPath() async {
    final baseDir = Directory('/sdcard/model_data');
    if (!baseDir.existsSync()) {
      baseDir.createSync();
    }

    var nextFolderIndex = 0;
    while (Directory('${baseDir.path}/$nextFolderIndex').existsSync()) {
      nextFolderIndex++;
    }

    final nextFolderPath = '${baseDir.path}/$nextFolderIndex';
    Directory(nextFolderPath).createSync();

    return nextFolderPath;
  }

  Future<Uint8List> extractAudioData(File video) async {
    // final String outputPath = "${video.parent.path}/audio.aac";
    final modelDataPath = await _getNextModelDataFolderPath();
    final String outputPath = '$modelDataPath/audio.aac';
    final File outputFile = File(outputPath);

    // if (outputFile.existsSync()) {
    //   outputFile.deleteSync();
    // }

    final String command = "-i ${video.path} -vn -acodec copy $outputPath";
    int rc = await _ffmpeg.execute(command);

    if (rc != 0) {
      throw Exception('Failed to extract audio data from video');
    }

    Uint8List bytes = outputFile.readAsBytesSync();
    // outputFile.deleteSync();

    return bytes;
  }

  Future<List<Uint8List>> extractFramesData(File video, {int fps = 3}) async {
    final modelDataPath = await _getNextModelDataFolderPath();
    final directory = '$modelDataPath/frames';
    final Directory framesDirectory = Directory(directory);

    // if (framesDirectory.existsSync()) {
    //   framesDirectory.deleteSync(recursive: true);
    // }

    framesDirectory.createSync(recursive: true);

    final command = "-i ${video.path} -vf fps=$fps $directory/out_%d.jpg";
    int rc = await _ffmpeg.execute(command);

    if (rc != 0) {
      throw Exception('Failed to extract frames from video');
    }


    // get the frames for only first 30 seconds
    final frames = <Uint8List>[];
    for (var i = 1; i <= fps*30; i++) {
      final file = File("$directory/out_$i.jpg");
      if (file.existsSync()) {
        frames.add(file.readAsBytesSync());
        // file.deleteSync();
      }
    }

    // framesDirectory.deleteSync();

    return frames;
  }
}
