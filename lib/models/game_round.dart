class GameRound {
  const GameRound({
    required this.folderKey,
    required this.answer,
  });

  final String folderKey;
  final String answer;

  bool matchesGuess(String guess) {
    return answer.trim().toLowerCase() == guess.trim().toLowerCase();
  }
}

class RoundSummary {
  const RoundSummary({
    required this.guesses,
    required this.isWon,
    required this.answer,
    this.imageUrl,
  });

  final List<String> guesses;
  final bool isWon;
  final String answer;
  final String? imageUrl;
}
