import 'package:assets_audio_player/assets_audio_player.dart';

Future<void> playBeepSound(Beep beep) async {
  AssetsAudioPlayer player = AssetsAudioPlayer();
  switch (beep) {
    case Beep.start:
      player.open(
        Audio("assets/bixby_start.wav")
      );
      break;
    case Beep.end:
      player.open(
        Audio("assets/bixby_end.wav")
      );
      break;
  }
}

enum Beep {
  start,
  end,
}
