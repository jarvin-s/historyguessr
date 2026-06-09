import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';

class SupabaseService {
  SupabaseClient get client => SupabaseConfig.client;
}
