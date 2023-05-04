import 'dart:async';
import 'package:fading_playlist/core/audio_player.dart';
import 'package:fading_playlist/core/audio_downloader.dart';
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

  static final ValueNotifier<int> _currentPlayerIndexNotifier =
      ValueNotifier(0);

  static ValueNotifier<int> get currentPlayerIndexNotifier =>
      _currentPlayerIndexNotifier;

  ///Notifier attached to [AudioPlayer] at [index] to notify
  ///listeners of internal state changes so they can resubscribe to necessary streams.
  static ValueNotifier<int> getRefreshNotifier(int index) =>
      _players[index].refreshNotifier;

  static StreamSubscription<int>? _streamSubscription;

  ///Number of tracks in the playlist.
  static int get trackCount => _players.length;

  ///Returns duration of track at [index].
  static Duration? getDuration(int index) {
    return _players[index].duration;
  }

  ///Sets [_currentPlayerIndex] state
  static void _setCurrentPlayerIndex(int index) {
    _currentPlayerIndex = index;
    _currentPlayerIndexNotifier.value = index;
  }

  ///Attaches a listener to [_currentPlayer]'s [playingElapsedTimeStream].
  ///Current track begins to fade out once there are 10 seconds or less left
  ///in the playback and the next track begins to fade in.
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
              _setCurrentPlayerIndex(nextIndex);
              _currentSongDuration = _currentPlayer.duration;
              nextPlayer.refresh();
              nextPlayer.play();
              _onNext(nextIndex);
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

  ///Download [tracks] and load [AudioPlayer] for each of them.
  static Future<void> loadPlaylist(List<Track> tracks) async {
    try {
      //download all tracks and load their players

      for (var track in tracks) {
        AudioDownloader.download(
          track: track,
          onDownloadSuccess: (downloadedTrack, file) async {
            try {
              final player = AudioPlayer();
              await player.load(file.path);
              _players.add(player);

              final downloadedTracks = [..._downloadedTracksNotifer.value];
              downloadedTracks.add(
                DownloadedTrack.withTrack(file, downloadedTrack),
              );
              _downloadedTracksNotifer.value = downloadedTracks;
            } catch (e) {
              _logger.log(
                "loadPlaylist AudioDownloader.download for ${track.title} -> $e",
              );
            }
          },
        );
      }
    } catch (e) {
      _logger.log("loadPlaylist -> $e");
    }
  }

  static void _onNext(int index) async {
    int prevIndex = index - 1;
    if (prevIndex < 0) prevIndex = trackCount - 1;

    final oldPlayer = _players[prevIndex];

    final newPlayer = AudioPlayer();
    oldPlayer.stopAudio();
    oldPlayer.seek(0);

    await newPlayer.load(_downloadedTracksNotifer.value[prevIndex].track.path);
    _players[prevIndex] = newPlayer;
    _players[prevIndex].refresh();
    oldPlayer.dispose();
  }

  ///Play a track at [index].
  ///If [next] (skip forward) or [previous] (skip backward) is true,
  ///the current [AudioPlayer] is disposed and a new one created in it's place.
  static Future<void> play(
    int index, {
    bool next = false,
    bool previous = false,
  }) async {
    try {
      _setCurrentPlayerIndex(index);

      _currentSongDuration = _currentPlayer.duration;
      _currentPlayer.setVolume(1);
      _currentPlayer.play();
      _currentPlayer.refresh();

      _subscribeToStream();

      if (next) {
        _onNext(index);
      }

      if (previous) {
        int nextIndex = index + 1;
        if (nextIndex > trackCount + 1) nextIndex = 0;

        final oldPlayer = _players[nextIndex];

        final newPlayer = AudioPlayer();
        oldPlayer.stopAudio();
        oldPlayer.seek(0);

        await newPlayer
            .load(_downloadedTracksNotifer.value[nextIndex].track.path);
        _players[nextIndex] = newPlayer;
        _players[nextIndex].refresh();
        oldPlayer.dispose();
      }

      for (int i = 0; i < _players.length; i++) {
        if (i != _currentPlayerIndex && _players[i].playing) {
          final newPlayer = AudioPlayer();
          final oldPlayer = _players[i];
          oldPlayer.stopAudio();
          oldPlayer.seek(0);

          await newPlayer.load(_downloadedTracksNotifer.value[i].track.path);
          _players[i] = newPlayer;
          _players[i].refresh();

          oldPlayer.dispose();
          break;
        }
      }
    } catch (e) {
      _logger.log("play -> $e");
    }
  }

  ///Skips forward in the playlist.
  static Future<void> playNext() async {
    _currentPlayer.stopAudio();
    _currentPlayer.refresh();

    int nextIndex = _currentPlayerIndex + 1;

    if (nextIndex > _players.length - 1) {
      nextIndex = 0;
    }

    play(nextIndex, next: true);
  }

  ///Skips backward in the playlist.
  static Future<void> playPrevious() async {
    _currentPlayer.stopAudio();
    _currentPlayer.refresh();

    int prevIndex = _currentPlayerIndex - 1;

    if (prevIndex < 0) {
      prevIndex = 0;
    }

    play(prevIndex, previous: true);
  }

  ///Pauses audio playback for track at [index].
  static Future<void> pause(int index) async {
    try {
      return _players[index].pauseAudio();
    } catch (e) {
      _logger.log("pause -> $e");
    }
  }

  ///Seeks to [seconds] for track at [index].
  static Future<void> seek(int index, int seconds) async {
    try {
      await _players[index].seek(seconds);
    } catch (e) {
      _logger.log("seek -> e");
    }
  }

  ///Stops audio playback for track at [index].
  static Future<void> stopAudio(int index) async {
    try {
      await _players[index].stopAudio();
    } catch (e) {
      _logger.log("stopAudio -> $e");
    }
  }

  ///Stream of playback time elapsed in seconds for track at [index].
  static Stream<int> playingElapsedTimeStream(int index) {
    return _players[index].playingElapsedTimeStream();
  }

  ///Stream of playing state for track at [index].
  static Stream<bool> playingStateStream(int index) {
    return _players[index].playingStateStream();
  }

  ///Release resources.
  static void dispose() {
    _streamSubscription?.cancel();
    for (final player in _players) {
      player.dispose();
    }
  }
}
