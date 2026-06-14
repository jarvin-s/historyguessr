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
    this.fact,
    this.isFactLoading = false,
  });

  final List<String> guesses;
  final bool isWon;
  final String answer;
  final String? imageUrl;
  final String? fact;
  final bool isFactLoading;

  RoundSummary copyWith({
    String? fact,
    bool? isFactLoading,
  }) {
    return RoundSummary(
      guesses: guesses,
      isWon: isWon,
      answer: answer,
      imageUrl: imageUrl,
      fact: fact ?? this.fact,
      isFactLoading: isFactLoading ?? this.isFactLoading,
    );
  }
}
