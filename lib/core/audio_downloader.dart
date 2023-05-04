import 'dart:io';
import 'package:dart_downloader/dart_downloader.dart';
import 'package:fading_playlist/core/audio_cache.dart';
import 'package:fading_playlist/core/logger.dart';
import 'package:fading_playlist/models/track.dart';

class AudioDownloader {
  AudioDownloader._();

  static final _logger = Logger(AudioDownloader);

  static String _getFileName(String url) {
    return url.split("/").last;
  }

  static Future<void> download({
    required Track track,
    required Function(Track, File) onDownloadSuccess,
  }) async {
    try {
      final fileName = _getFileName(track.url);
      final cachedFile = await AudioCache.getFile(fileName: fileName);

      if (cachedFile != null) {
        _logger.log("Retrieved $fileName from cache");
        onDownloadSuccess(track, cachedFile);
        return;
      }

      final downloader = DartDownloader();

      final file = await downloader.download(
        url: track.url,
        deleteIfDownloadedFilePathExists: true,
      );
      if (file != null) {
        await AudioCache.save(fileName);
        onDownloadSuccess(track, file);
      }
    } catch (e) {
      _logger.log("download -> $e");
    }
  }
}
