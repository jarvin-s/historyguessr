import 'package:supabase_flutter/supabase_flutter.dart';

class ImageStorageService {
  ImageStorageService(this._client);

  final SupabaseClient _client;

  static const bucket = 'images';
  static const stageCount = 6;
  static const dailyPathPrefix = 'daily/';

  static const _imagePaths = [
    'images/einstein.png',
    'einstein.png',
  ];

  Future<String> fetchImageUrl() async {
    for (final path in _imagePaths) {
      try {
        return await _fetchUrl(path);
      } catch (_) {
        continue;
      }
    }

    return _client.storage.from(bucket).getPublicUrl(_imagePaths.first);
  }

  static String dailyImagePath(DateTime date, int stage) {
    assert(stage >= 1 && stage <= stageCount, 'Stage must be between 1 and $stageCount');
    return '$dailyPathPrefix${_formatDate(date)}/$stage.png';
  }

  Future<String> fetchDailyImageUrl(DateTime date, int stage) {
    return _fetchUrl(dailyImagePath(date, stage));
  }

  Future<List<String>> fetchDailyImageUrls(DateTime date) {
    return Future.wait(
      List.generate(
        stageCount,
        (index) => fetchDailyImageUrl(date, index + 1),
      ),
    );
  }

  Future<String> _fetchUrl(String path) async {
    try {
      return await _client.storage.from(bucket).createSignedUrl(path, 3600);
    } catch (_) {
      return _client.storage.from(bucket).getPublicUrl(path);
    }
  }

  static String _formatDate(DateTime date) {
    final utc = date.toUtc();
    final year = utc.year.toString().padLeft(4, '0');
    final month = utc.month.toString().padLeft(2, '0');
    final day = utc.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
