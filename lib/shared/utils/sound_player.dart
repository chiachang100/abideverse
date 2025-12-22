import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

class RandomSoundPlayer {
  final AudioPlayer _player = AudioPlayer();
  final Random _random = Random();

  final List<String> _sounds = [
    'sounds/laughs/woman-laugh-6421.mp3',
    'sounds/laughs/girl-laugh-6689.mp3',
    'sounds/laughs/male-laugh-242216.mp3',
    'sounds/laughs/villain-laugh-431491.mp3',
    'sounds/laughs/kids-laugh-45357.mp3',
    'sounds/laughs/laugh-105488.mp3',
    'sounds/laughs/possessed-laugh-94851.mp3',
  ];

  Future<void> playRandomSound() async {
    final String sound = _sounds[_random.nextInt(_sounds.length)];

    await _player.play(AssetSource(sound));
  }
}
