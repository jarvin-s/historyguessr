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

  static List<String> search(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return const [];
    }

    return names
        .where((name) => name.toLowerCase().contains(normalized))
        .toList();
  }
}
