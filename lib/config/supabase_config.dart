import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract final class SupabaseConfig {
  static Future<void> initialize() async {
    await dotenv.load(fileName: 'env.example');

    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (url == null ||
        url.isEmpty ||
        anonKey == null ||
        anonKey.isEmpty ||
        url.contains('your-project') ||
        anonKey == 'your-anon-key') {
      throw StateError(
        'Set SUPABASE_URL and SUPABASE_ANON_KEY in env.example '
        '(copy env.example to .env locally, or run scripts/ensure_env.sh before building).',
      );
    }

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
