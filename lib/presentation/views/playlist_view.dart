import 'package:fading_playlist/core/playlist_controller.dart';
import 'package:fading_playlist/models/downloaded_track.dart';
import 'package:fading_playlist/models/track.dart';
import 'package:fading_playlist/presentation/widgets/custom_text.dart';
import 'package:fading_playlist/presentation/widgets/now_playing_widget.dart';
import 'package:flutter/material.dart';

class PlaylistView extends StatefulWidget {
  const PlaylistView({super.key});

  @override
  State<PlaylistView> createState() => _PlaylistViewState();
}

class _PlaylistViewState extends State<PlaylistView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      PlaylistController.loadPlaylist(Track.tracks);
    });
  }

  @override
  void dispose() {
    PlaylistController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.music_note_outlined),
            Text("Musik"),
          ],
        ),
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: PlaylistController.currentPlayerIndexNotifier,
        builder: (_, currentPlayingIndex, __) {
          return ValueListenableBuilder<List<DownloadedTrack>>(
            valueListenable: PlaylistController.downloadedTracksNotifer,
            builder: (_, tracks, __) {
              if (tracks.isEmpty) {
                return const Center(
                  child: CustomText(text: "Downloading your playlist..."),
                );
              }

              return NowPlaying(
                index: currentPlayingIndex,
                track: tracks[currentPlayingIndex],
              );
            },
          );
        },
      ),
    );
  }
}
