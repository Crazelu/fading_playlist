import 'package:fading_playlist/core/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart' as audio;

class AudioPlayer {
  late final _player = audio.AudioPlayer();

  late final _logger = Logger(AudioPlayer);

  late final ValueNotifier<int> _refreshNotifier = ValueNotifier(0);
  ValueNotifier<int> get refreshNotifier => _refreshNotifier;

  bool get playing => _player.playing;

  Duration? get duration => _player.duration;

  void refresh() {
    _refreshNotifier.value = DateTime.now().millisecondsSinceEpoch;
  }

  Future<Duration?> load(String filePath) async {
    try {
      await _player.setFilePath(filePath);
      return await _player.load();
    } catch (e) {
      _logger.log(e);
    }
    return null;
  }

  Future<void> playAudio(String path) async {
    try {
      await pauseAudio();
      await _player.setFilePath(path);
      await _player.play();
    } catch (e) {
      _logger.log(e);
    }
  }

  Future<void> pauseAudio() async {
    try {
      await _player.pause();
    } catch (e) {
      _logger.log(e);
    }
  }

  Future<void> seek(int seconds) async {
    try {
      await _player.seek(Duration(seconds: seconds));
    } catch (e) {
      _logger.log(e);
    }
  }

  Future<void> stopAudio() async {
    try {
      if (_player.playing) await _player.stop();
    } catch (e) {
      _logger.log(e);
    }
  }

  Stream<int> playingElapsedTimeStream() {
    return _player.positionStream.map((event) => event.inSeconds);
  }

  Stream<bool> playingStateStream() {
    return _player.playingStream;
  }

  Future<void> play() async {
    if (!_player.playing) await _player.play();
  }

  Future<void> setVolume(double volume) async {
    _player.setVolume(volume);
  }

  Future<void> dispose() {
    return _player.dispose();
  }
}
