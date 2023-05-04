import 'dart:async';
import 'package:dart_downloader/dart_downloader.dart';
import 'package:fading_playlist/core/audio_player.dart';
import 'package:fading_playlist/core/logger.dart';
import 'package:fading_playlist/models/downloaded_track.dart';
import 'package:fading_playlist/models/track.dart';
import 'package:flutter/foundation.dart';

class PlaylistController {
  PlaylistController._();

  static final _logger = Logger(PlaylistController);

  static int _currentPlayerIndex = 0;
  static final List<AudioPlayer> _players = [];
  static Duration? _currentSongDuration;
  static AudioPlayer get _currentPlayer => _players[_currentPlayerIndex];

  static final ValueNotifier<List<DownloadedTrack>> _downloadedTracksNotifer =
      ValueNotifier([]);
  static ValueNotifier<List<DownloadedTrack>> get downloadedTracksNotifer =>
      _downloadedTracksNotifer;

  static ValueNotifier<int> getRefreshNotifier(int index) =>
      _players[index].refreshNotifier;

  static StreamSubscription<int>? _streamSubscription;

  static int get trackCount => _players.length;

  static Duration? getDuration(int index) {
    return _players[index].duration;
  }

  static void _subscribeToStream() {
    try {
      _streamSubscription?.cancel();

      AudioPlayer nextPlayer;

      _streamSubscription = _currentPlayer.playingElapsedTimeStream().listen(
        (seconds) {
          if (_currentSongDuration == null) return;

          int nextIndex = _currentPlayerIndex + 1;

          if (nextIndex > _players.length - 1) {
            nextIndex = 0;
          }
          nextPlayer = _players[nextIndex];

          final secondsLeft = _currentSongDuration!.inSeconds - seconds;

          if (secondsLeft > 10 && nextPlayer.playing) {
            nextPlayer.stopAudio();
            nextPlayer.seek(0);
            nextPlayer.refresh();
          }

          //once it's 10 seconds (or less) left for the song to end,
          //reduce the volume of the current player
          //start playing the next player at a slightly lower volume
          //which increases until the current track has finished playing

          switch (secondsLeft) {
            case 10:
              _currentPlayer.setVolume(0.9);
              nextPlayer.setVolume(0.1);
              nextPlayer.play();
              break;
            case 9:
              _currentPlayer.setVolume(0.8);
              nextPlayer.setVolume(0.2);
              nextPlayer.play();
              break;
            case 8:
              _currentPlayer.setVolume(0.7);
              nextPlayer.setVolume(0.3);
              nextPlayer.play();
              break;
            case 7:
              _currentPlayer.setVolume(0.6);
              nextPlayer.setVolume(0.4);
              nextPlayer.play();
              break;
            case 6:
              _currentPlayer.setVolume(0.5);
              nextPlayer.setVolume(0.5);
              nextPlayer.play();
              break;
            case 5:
              _currentPlayer.setVolume(0.4);
              nextPlayer.setVolume(0.6);
              nextPlayer.play();
              break;
            case 4:
              _currentPlayer.setVolume(0.3);
              nextPlayer.setVolume(0.7);
              nextPlayer.play();
              break;
            case 3:
              _currentPlayer.setVolume(0.2);
              nextPlayer.setVolume(0.8);
              nextPlayer.play();
              break;
            case 2:
              _currentPlayer.setVolume(0.1);
              nextPlayer.setVolume(0.9);
              nextPlayer.play();
              break;

            case 0:
              _currentPlayer.stopAudio();
              nextPlayer.setVolume(1);
              _currentPlayerIndex = nextIndex;
              _currentSongDuration = _currentPlayer.duration;
              nextPlayer.play();
              _subscribeToStream();
              break;
            default:
          }
        },
      );
    } catch (e) {
      _logger.log("_subscribeToStream -> $e");
    }
  }

  static Future<void> loadPlaylist(List<Track> tracks) async {
    try {
      //download all tracks and load their players

      await Future.forEach(
        tracks,
        (track) async {
          try {
            final downloader = DartDownloader();
            final file = await downloader.download(
              url: track.url,
              deleteIfDownloadedFilePathExists: true,
            );
            if (file != null) {
              final player = AudioPlayer();
              _players.add(player);
              await player.load(file.path);

              final downloadedTracks = [..._downloadedTracksNotifer.value];
              downloadedTracks.add(
                DownloadedTrack(
                  track: file,
                  title: track.title,
                  artist: track.artist,
                ),
              );
              _downloadedTracksNotifer.value = downloadedTracks;
            }
          } catch (e) {
            _logger.log("loadPlaylist Future -> $e");
          }
        },
      );
    } catch (e) {
      _logger.log("loadPlaylist -> $e");
    }
  }

  static Future<void> play(int index) async {
    try {
      _currentPlayerIndex = index;

      _currentSongDuration = _currentPlayer.duration;
      _currentPlayer.setVolume(1);
      _currentPlayer.play();
      _subscribeToStream();

      for (int i = 0; i < _players.length; i++) {
        if (i != _currentPlayerIndex) {
          _players[i].stopAudio();
          _players[i].seek(0);
          _players[i].refresh();
        }
      }
    } catch (e) {
      _logger.log("play -> $e");
    }
  }

  static Future<void> pause(int index) async {
    try {
      return _players[index].pauseAudio();
    } catch (e) {
      _logger.log("pause -> $e");
    }
  }

  static Future<void> seek(int index, int seconds) async {
    try {
      await _players[index].seek(seconds);
    } catch (e) {
      _logger.log("seek -> e");
    }
  }

  static Future<void> stopAudio(int index) async {
    try {
      await _players[index].stopAudio();
    } catch (e) {
      _logger.log("stopAudio -> $e");
    }
  }

  static Stream<int> playingElapsedTimeStream(int index) {
    return _players[index].playingElapsedTimeStream();
  }

  static Stream<bool> playingStateStream(int index) {
    return _players[index].playingStateStream();
  }

  static void dispose() {
    _streamSubscription?.cancel();
    for (final player in _players) {
      player.dispose();
    }
  }
}
