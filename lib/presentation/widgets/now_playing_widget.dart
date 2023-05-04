import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fading_playlist/core/audio_playback_context_manager.dart';
import 'package:fading_playlist/core/logger.dart';
import 'package:fading_playlist/core/playlist_controller.dart';
import 'package:fading_playlist/models/downloaded_track.dart';
import 'package:fading_playlist/presentation/widgets/control_icon.dart';
import 'package:fading_playlist/presentation/widgets/custom_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NowPlaying extends StatefulWidget {
  const NowPlaying({
    Key? key,
    required this.index,
    required this.track,
  }) : super(key: key);

  final int index;
  final DownloadedTrack track;

  @override
  State<NowPlaying> createState() => _NowPlayingState();
}

class _NowPlayingState extends State<NowPlaying> {
  late final _logger = Logger(_NowPlayingState);

  StreamSubscription? _elapsedTimeSubscription;
  StreamSubscription? _playingStateSubscription;

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
    PlaylistController.getRefreshNotifier(index)
        .addListener(_listenToPlaybackStream);
  }

  @override
  void didUpdateWidget(covariant NowPlaying oldWidget) {
    if (oldWidget.index != widget.index) {
      _elapsedTimeSubscription?.cancel();
      _playingStateSubscription?.cancel();
      PlaylistController.getRefreshNotifier(oldWidget.index)
          .removeListener(_listenToPlaybackStream);

      _loadDuration();

      PlaylistController.getRefreshNotifier(index)
          .addListener(_listenToPlaybackStream);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    PlaylistController.dispose();
    _elapsedTimeSubscription?.cancel();
    _playingStateSubscription?.cancel();
    PlaylistController.getRefreshNotifier(index)
        .removeListener(_listenToPlaybackStream);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Container(
      height: height,
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorDark,
      ),
      child: _duration == null
          ? const SizedBox()
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                SizedBox(
                  height: height * .4,
                  width: width,
                  child: CachedNetworkImage(
                    imageUrl: widget.track.coverImage,
                    imageBuilder: (context, imageProvider) {
                      return Container(
                        height: height * .4,
                        width: width,
                        decoration: BoxDecoration(
                          image: DecorationImage(image: imageProvider),
                        ),
                      );
                    },
                    placeholder: (context, url) {
                      return Container(
                        height: height * .4,
                        width: width,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .primaryColorDark
                              .withOpacity(.4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: CupertinoActivityIndicator(
                            color: Theme.of(context).primaryColorLight,
                          ),
                        ),
                      );
                    },
                    errorWidget: (context, url, error) {
                      return Container(
                        height: height * .4,
                        width: width,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .primaryColorDark
                              .withOpacity(.4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: CustomText(
                    text: widget.track.title,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: CustomText(
                    text: widget.track.artist,
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                    color: Theme.of(context).primaryColorLight.withOpacity(.8),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 16,
                  child: Slider(
                    value: _sliderValue,
                    inactiveColor:
                        Theme.of(context).primaryColorLight.withOpacity(.5),
                    activeColor:
                        Theme.of(context).primaryColor.withOpacity(.85),
                    max: (_duration?.inSeconds ?? 0).toDouble(),
                    onChanged: (seconds) {
                      PlaylistController.seek(index, seconds.toInt());
                    },
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ControlIcon(
                      onTap: () {
                        if (widget.index > 0) PlaylistController.playPrevious();
                      },
                      icon: Icons.skip_previous_outlined,
                      color: widget.index > 0
                          ? Theme.of(context).primaryColorLight
                          : Colors.grey,
                    ),
                    const SizedBox(width: 24),
                    ControlIcon(
                      height: 66,
                      width: 66,
                      iconSize: 44,
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
                    const SizedBox(width: 24),
                    ControlIcon(
                      onTap: () {
                        if (widget.index < PlaylistController.trackCount - 1) {
                          PlaylistController.playNext();
                        }
                      },
                      icon: Icons.skip_next_outlined,
                      color: widget.index < PlaylistController.trackCount - 1
                          ? Theme.of(context).primaryColorLight
                          : Colors.grey,
                    ),
                  ],
                )
              ],
            ),
    );
  }
}
