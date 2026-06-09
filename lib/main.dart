import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import 'config/supabase_config.dart';
import 'screens/game_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SemanticsBinding.instance.ensureSemantics();

  await SupabaseConfig.initialize();

  runApp(const HistoryGuessrApp());
}

class HistoryGuessrApp extends StatelessWidget {
  const HistoryGuessrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HistoryGuessr',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFDF0E0),
        fontFamily: 'Roboto',
      ),
      home: const GameScreen(),
    );
  }
}
