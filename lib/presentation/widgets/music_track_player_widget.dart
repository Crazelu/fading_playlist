import 'dart:async';
import 'dart:io';
import 'package:fading_playlist/core/audio_playback_context_manager.dart';
import 'package:fading_playlist/core/logger.dart';
import 'package:fading_playlist/core/playlist_controller.dart';
import 'package:fading_playlist/presentation/widgets/custom_text.dart';
import 'package:flutter/material.dart';

class MusicTrackPlayerWidget extends StatefulWidget {
  const MusicTrackPlayerWidget({
    Key? key,
    required this.file,
    required this.index,
    required this.trackName,
  }) : super(key: key);

  final File file;
  final int index;
  final String trackName;

  @override
  State<MusicTrackPlayerWidget> createState() => _MusicTrackPlayerWidgetState();
}

class _MusicTrackPlayerWidgetState extends State<MusicTrackPlayerWidget> {
  late final _logger = Logger(_MusicTrackPlayerWidgetState);

  StreamSubscription? _elapsedTimeSubscription;
  StreamSubscription? _playingStateSubscription;

  File get file => widget.file;
  int get index => widget.index;

  bool _isPlaying = false;
  bool _isPaused = false;

  double _sliderValue = 0;

  Duration? _duration;

  Future<void> _loadDuration() async {
    try {
      _duration = PlaylistController.getDuration(index);

      setState(() {});
      _listenToPlaybackStream();
    } catch (e) {
      _logger.log("ERROR -> $e");
    }
  }

  void _listenToPlaybackStream() {
    _elapsedTimeSubscription =
        PlaylistController.playingElapsedTimeStream(index).listen((seconds) {
      setState(() {
        _sliderValue = seconds.toDouble();
      });

      if (_sliderValue == _duration?.inSeconds) {
        PlaylistController.seek(index, 0);
        PlaylistController.stopAudio(index);
        setState(() {
          _isPlaying = false;
          _isPaused = false;
        });
      }
    });
    _playingStateSubscription =
        PlaylistController.playingStateStream(index).listen((isPlaying) {
      if (isPlaying) {
        AudioPlaybackContextManager.registerPauseAudioCallback(() {
          PlaylistController.pause(index);
        });
      }
      setState(() {
        _isPlaying = isPlaying;
        _isPaused = !_isPlaying;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadDuration());
  }

  @override
  void dispose() {
    PlaylistController.dispose();
    _elapsedTimeSubscription?.cancel();
    _playingStateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _duration == null ? 49 : null,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: _duration == null
          ? const _LoadingIndicator()
          : Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: CustomText(
                          softWrap: true,
                          text: widget.trackName,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 16,
                        child: Slider(
                          value: _sliderValue,
                          inactiveColor: const Color(0xffD9D9D9),
                          activeColor:
                              Theme.of(context).primaryColor.withOpacity(.85),
                          max: (_duration?.inSeconds ?? 0).toDouble(),
                          onChanged: (seconds) {
                            PlaylistController.seek(index, seconds.toInt());
                          },
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _MusicControlIcon(
                  onTap: () {
                    if (_isPaused) {
                      AudioPlaybackContextManager.onPlaybackStarted();
                      PlaylistController.play(index);
                      _isPaused = false;
                      _isPlaying = true;
                      setState(() {});
                      return;
                    }
                    if (_isPlaying) {
                      PlaylistController.pause(index);
                    } else {
                      AudioPlaybackContextManager.onPlaybackStarted();
                      PlaylistController.play(index);
                    }
                  },
                  isPlaying: _isPlaying,
                ),
                const SizedBox(width: 8),
              ],
            ),
    );
  }
}

class _MusicControlIcon extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTap;
  const _MusicControlIcon({
    Key? key,
    required this.onTap,
    this.isPlaying = false,
  }) : super(key: key);

  BorderSide _borderSide(BuildContext context) => BorderSide(
        color: Theme.of(context).primaryColor.withOpacity(.7),
        width: 1,
      );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 21,
        width: 21,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border(
            top: _borderSide(context),
            bottom: _borderSide(context),
            left: _borderSide(context),
            right: _borderSide(context),
          ),
        ),
        child: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
          color: Theme.of(context).primaryColor.withOpacity(.8),
          size: 16,
        ),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _GreyContainer(
          height: 10,
          width: 70,
        ),
        SizedBox(width: 16),
        _GreyContainer(
          height: 10,
          width: 79 * 2.5,
        ),
        Spacer(),
        _GreyContainer(
          height: 20,
          width: 30,
          shape: BoxShape.circle,
        ),
      ],
    );
  }
}

class _GreyContainer extends StatelessWidget {
  final double height;
  final double width;
  final BoxShape shape;

  const _GreyContainer({
    Key? key,
    required this.height,
    required this.width,
    this.shape = BoxShape.rectangle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        shape: shape,
        color: const Color(0xffE6E8EC),
      ),
    );
  }
}
