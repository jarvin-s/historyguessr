import 'package:supabase_flutter/supabase_flutter.dart';

class ImageStorageService {
  ImageStorageService(this._client);

  final SupabaseClient _client;

  static const bucket = 'images';

  static const _imagePaths = [
    'images/einstein.png',
    'einstein.png',
  ];

  Future<String> fetchImageUrl() async {
    for (final path in _imagePaths) {
      try {
        return await _client.storage.from(bucket).createSignedUrl(path, 3600);
      } catch (_) {
        continue;
      }
    }

    return _client.storage.from(bucket).getPublicUrl(_imagePaths.first);
  }
}
