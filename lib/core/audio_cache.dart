import 'dart:convert';
import 'dart:io';
import 'package:fading_playlist/core/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioCache {
  static const _key = "audio_cache_key";
  static const String mediaDirectory = "cacheDirectory";
  static final _logger = Logger(AudioCache);

  static SharedPreferences? _cache;

  AudioCache._();

  static Future<void> _init() async {
    _cache ??= await SharedPreferences.getInstance();
  }

  static Future<void> delete(String fileName) async {
    try {
      await _init();

      final dir = await getApplicationDocumentsDirectory();
      String fileDirectory =
          "${dir.path}/${AudioCache.mediaDirectory}/$fileName";
      final file = File(fileDirectory);
      if (await file.exists()) {
        await file.delete();
      }

      await _cache?.remove(_key);
    } catch (e) {
      _logger.log("$e");
    }
  }

  static Future<void> deleteExpiredEntries(Duration maxDuration) async {
    final entries = await getEntries();
    List<String> filesToDelete = [];

    final currentTimeStamp = DateTime.now();

    for (var key in entries.keys) {
      final cachePeriod = DateTime.parse(entries[key]!);
      if (currentTimeStamp.difference(cachePeriod) >= maxDuration) {
        filesToDelete.add(key);
      }
    }

    await Future.forEach<String>(
      filesToDelete,
      (fileName) async => await delete(fileName),
    ).onError((error, stackTrace) =>
        _logger.log("Batch cached item deletion error -> $error"));
  }

  static Future<void> save(String fileName) async {
    try {
      await _init();
      final entries = await getEntries();
      entries.addAll({fileName: DateTime.now().toIso8601String()});
      await _cache?.setString(_key, jsonEncode(entries));
    } catch (e) {
      _logger.log(e);
    }
  }

  static Future<Map<String, String>> getEntries() async {
    await _init();
    return Map<String, String>.from(
        jsonDecode(_cache?.getString(_key) ?? '{}'));
  }

  static Future<File?> getFile({
    required String fileName,
    String directory = AudioCache.mediaDirectory,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileDirectory = "${dir.path}/$directory/$fileName";

      final file = File(fileDirectory);
      if (await file.exists()) return file;
    } catch (e) {
      _logger.log(e);
    }
    return null;
  }
}
