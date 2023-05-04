import 'dart:io';

class DownloadedTrack {
  final File track;
  final String name;

  const DownloadedTrack({
    required this.track,
    required this.name,
  });
}
