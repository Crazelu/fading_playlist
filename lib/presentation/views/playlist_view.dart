import 'package:fading_playlist/core/playlist_controller.dart';
import 'package:fading_playlist/models/downloaded_track.dart';
import 'package:fading_playlist/models/track.dart';
import 'package:fading_playlist/presentation/widgets/music_track_player_widget.dart';
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
      appBar: AppBar(
        title: const Text("Fading Playlist Transition Demo"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ValueListenableBuilder<List<DownloadedTrack>>(
            valueListenable: PlaylistController.downloadedTracksNotifer,
            builder: (_, tracks, __) {
              if (tracks.isEmpty) return const SizedBox();

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < tracks.length; i++)
                    MusicTrackPlayerWidget(
                      file: tracks[i].track,
                      index: i,
                      trackName: tracks[i].name,
                    ),
                ],
              );
            }),
      ),
    );
  }
}
