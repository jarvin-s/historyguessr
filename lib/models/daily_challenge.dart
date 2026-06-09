class DailyChallenge {
  const DailyChallenge({
    required this.id,
    required this.challengeDate,
    required this.answer,
    required this.acceptedAliases,
  });

  final String id;
  final DateTime challengeDate;
  final String answer;
  final List<String> acceptedAliases;

  bool matchesGuess(String guess) {
    final normalized = guess.trim().toLowerCase();
    if (normalized.isEmpty) {
      return false;
    }

    if (answer.trim().toLowerCase() == normalized) {
      return true;
    }

    return acceptedAliases.any(
      (alias) => alias.trim().toLowerCase() == normalized,
    );
  }

  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    final dateStr = json['challenge_date'] as String;
    final parts = dateStr.split('-').map(int.parse).toList();

    return DailyChallenge(
      id: json['id'] as String,
      challengeDate: DateTime.utc(parts[0], parts[1], parts[2]),
      answer: json['answer'] as String,
      acceptedAliases: (json['accepted_aliases'] as List<dynamic>?)
              ?.map((alias) => alias as String)
              .toList() ??
          const [],
    );
  }
}
