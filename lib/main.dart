import 'package:flutter/material.dart';

import 'screens/game_screen.dart';

void main() {
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
