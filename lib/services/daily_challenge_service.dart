import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/daily_challenge.dart';

class DailyChallengeService {
  DailyChallengeService(this._client);

  final SupabaseClient _client;

  static const _table = 'daily_challenges';

  Future<DailyChallenge?> fetchByDate(DateTime date) async {
    final dateStr = _formatDate(date);

    final response = await _client
        .from(_table)
        .select()
        .eq('challenge_date', dateStr)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return DailyChallenge.fromJson(response);
  }

  Future<DailyChallenge?> fetchToday() {
    final now = DateTime.now().toUtc();
    final today = DateTime.utc(now.year, now.month, now.day);
    return fetchByDate(today);
  }

  static String _formatDate(DateTime date) {
    final utc = date.toUtc();
    final year = utc.year.toString().padLeft(4, '0');
    final month = utc.month.toString().padLeft(2, '0');
    final day = utc.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
