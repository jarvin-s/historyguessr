import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

class ImageStorageService {
  ImageStorageService(this._client);

  final SupabaseClient _client;
  final _random = Random();

  static const bucket = 'images';
  static const stageCount = 6;
  static const randomPathPrefix = 'random';

  static String randomImagePath(String folderKey, int stage) {
    assert(stage >= 1 && stage <= stageCount, 'Stage must be between 1 and $stageCount');
    return '$randomPathPrefix/$folderKey/$stage.png';
  }

  Future<List<String>> listRandomFigureKeys() async {
    final result = await _client.storage.from(bucket).list(path: randomPathPrefix);

    return result
        .map((item) => item.name)
        .where((name) => !name.contains('.'))
        .toList();
  }

  Future<String> pickRandomFigureKey({String? exclude}) async {
    final keys = await listRandomFigureKeys();
    var available = keys;

    if (exclude != null) {
      available = keys.where((key) => key != exclude).toList();
      if (available.isEmpty) {
        available = keys;
      }
    }

    if (available.isEmpty) {
      throw StateError('No random figures found in storage at $randomPathPrefix/.');
    }

    return available[_random.nextInt(available.length)];
  }

  Future<String> fetchRandomImageUrl(String folderKey, int stage) {
    return _fetchUrl(randomImagePath(folderKey, stage));
  }

  Future<String> _fetchUrl(String path) async {
    try {
      return await _client.storage.from(bucket).createSignedUrl(path, 3600);
    } catch (_) {
      return _client.storage.from(bucket).getPublicUrl(path);
    }
  }
}
