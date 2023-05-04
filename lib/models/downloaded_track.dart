import 'dart:io';

class DownloadedTrack {
  final File track;
  final String artist;
  final String title;

  const DownloadedTrack({
    required this.track,
    required this.artist,
    required this.title,
  });
}
