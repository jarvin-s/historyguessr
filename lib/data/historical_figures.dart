abstract final class HistoricalFigures {
  static final names = [
    'Abraham Lincoln',
    'Ada Lovelace',
    'Albert Einstein',
    'Alexander the Great',
    'Amelia Earhart',
    'Anne Frank',
    'Archimedes',
    'Aristotle',
    'Benjamin Franklin',
    'Catherine the Great',
    'Charlemagne',
    'Charles Darwin',
    'Cleopatra',
    'Confucius',
    'Frida Kahlo',
    'Galileo Galilei',
    'Genghis Khan',
    'George Washington',
    'Harriet Tubman',
    'Henry VIII',
    'Hippocrates',
    'Isaac Newton',
    'Jane Austen',
    'Joan of Arc',
    'Johann Sebastian Bach',
    'John F. Kennedy',
    'Julius Caesar',
    'Leonardo da Vinci',
    'Louis XIV',
    'Mahatma Gandhi',
    'Marie Curie',
    'Martin Luther King Jr.',
    'Michelangelo',
    'Muhammad Ali',
    'Napoleon Bonaparte',
    'Nelson Mandela',
    'Nikola Tesla',
    'Plato',
    'Queen Elizabeth I',
    'Queen Victoria',
    'Rosa Parks',
    'Sigmund Freud',
    'Socrates',
    'Thomas Edison',
    'Vincent van Gogh',
    'Voltaire',
    'Winston Churchill',
    'Wolfgang Amadeus Mozart',
  ]..sort();

  static List<String> search(
    String query, {
    Iterable<String> exclude = const [],
  }) {
    final excluded = _normalizedExcludeSet(exclude);
    final available =
        names.where((name) => !excluded.contains(name.toLowerCase()));

    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return available.toList();
    }

    return available
        .where((name) => name.toLowerCase().contains(normalized))
        .toList();
  }

  static String? resolveExact(String input) {
    final normalized = input.trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }

    for (final name in names) {
      if (name.toLowerCase() == normalized) {
        return name;
      }
    }

    return null;
  }

  static bool canSubmit(
    String input, {
    Iterable<String> exclude = const [],
  }) {
    final resolved = resolveExact(input);
    if (resolved == null) {
      return false;
    }

    return !_normalizedExcludeSet(exclude).contains(resolved.toLowerCase());
  }

  static String? answerForFolderKey(String folderKey) {
    final key = folderKey.trim().toUpperCase();
    if (key.isEmpty) {
      return null;
    }

    for (final name in names) {
      final words = name.split(RegExp(r'\s+'));
      if (words.any((word) => word.toUpperCase() == key)) {
        return name;
      }

      final compact = name.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
      if (compact == key || compact.endsWith(key)) {
        return name;
      }
    }

    return null;
  }

  static Set<String> _normalizedExcludeSet(Iterable<String> exclude) {
    return exclude
        .map((name) => name.trim().toLowerCase())
        .where((name) => name.isNotEmpty)
        .toSet();
  }
}
