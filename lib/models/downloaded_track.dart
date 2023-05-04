import 'dart:io';

import 'package:fading_playlist/models/track.dart';

class DownloadedTrack {
  final File track;
  final String artist;
  final String title;
  final String coverImage;

  const DownloadedTrack({
    required this.track,
    required this.artist,
    required this.title,
    this.coverImage = "",
  });

  factory DownloadedTrack.withTrack(File file, Track track) {
    return DownloadedTrack(
      track: file,
      artist: track.artist,
      title: track.title,
      coverImage: track.coverImage,
    );
  }

  @override
  String toString() =>
      "DownloadedTrack(track: $track, artist: $artist, title: $title)";
}
