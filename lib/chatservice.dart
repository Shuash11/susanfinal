

import 'dart:math';


class ChatService {

  final List<Map<String, String>> _conversationHistory = [];

  static const Map<String, String> _mockResponses = {
    'math':
        'Great math question! 📐\n\n'
        'A quadratic equation looks like this:\n'
        '  ax² + bx + c = 0\n\n'
        'To solve it, use the quadratic formula:\n'
        '  x = (-b ± √(b² - 4ac)) / 2a\n\n'
        'Example: x² + 5x + 6 = 0\n'
        '  a=1, b=5, c=6\n'
        '  x = (-5 ± √(25-24)) / 2\n'
        '  x = -2 or x = -3 ✅',

    'english':
        'Good question about English! 📝\n\n'
        'The 8 parts of speech are:\n\n'
        '1. Noun — names a person, place, or thing\n'
        '2. Pronoun — replaces a noun (he, she, it)\n'
        '3. Verb — shows action or state (run, is)\n'
        '4. Adjective — describes a noun (big, red)\n'
        '5. Adverb — describes a verb (quickly, very)\n'
        '6. Preposition — shows relationship (in, on, under)\n'
        '7. Conjunction — connects words (and, but, or)\n'
        '8. Interjection — expresses emotion (wow!, oh!)\n\n'
        'Tip: Try to identify them in your own sentences! 😊',

    'programming':
        'Great programming question! 💻\n\n'
        'A for loop repeats a block of code a set number of times.\n\n'
        'Example in Python:\n'
        '```\n'
        'for i in range(5):\n'
        '    print(i)\n'
        '```\n'
        'Output: 0, 1, 2, 3, 4\n\n'
        'Example in Dart:\n'
        '```\n'
        'for (int i = 0; i < 5; i++) {\n'
        '  print(i);\n'
        '}\n'
        '```\n\n'
        'Use for loops when you know exactly how many times to repeat! 🔄',

    'science':
        'Great science question! 🔬\n\n'
        'Photosynthesis is how plants make their own food.\n\n'
        'Simple formula:\n'
        '  CO₂ + H₂O + Sunlight → Glucose + O₂\n\n'
        'In plain words:\n'
        '• Plants absorb carbon dioxide from the air\n'
        '• They take in water from the soil\n'
        '• Using sunlight as energy\n'
        '• They produce glucose (food) and release oxygen\n\n'
        'Fun fact: The oxygen we breathe comes from photosynthesis! 🌿',

    'default':
        'That\'s a great question! 🌟\n\n'
        'As your StudyBuddy, I\'m here to help you understand any topic.\n\n'
        'I can help you with:\n'
        '• 📐 Math — equations, formulas, problems\n'
        '• 📝 English — grammar, writing, literature\n'
        '• 💻 Programming — code, logic, algorithms\n'
        '• 🔬 Science — biology, chemistry, physics\n\n'
        'Try asking me something specific and I\'ll explain it step by step! 😊',
  };


  Future<String> sendMessage(String userMessage) async {

    _conversationHistory.add({
      'role':    'user',
      'content': userMessage,
    });

    await Future.delayed(
      Duration(milliseconds: 800 + Random().nextInt(700)),
    );

    final reply = _pickMockResponse(userMessage.toLowerCase());

    _conversationHistory.add({
      'role':    'assistant',
      'content': reply,
    });

    return reply;
  }


  String _pickMockResponse(String input) {
   
    if (_containsAny(input, ['math', 'equation', 'quadratic', 'algebra', 'solve'])) {
      return _mockResponses['math']!;
    }

    if (_containsAny(input, ['english', 'grammar', 'speech', 'noun', 'verb'])) {
      return _mockResponses['english']!;
    }

    if (_containsAny(input, ['program', 'code', 'loop', 'dart', 'python'])) {
      return _mockResponses['programming']!;
    }


    if (_containsAny(input, ['science', 'photosynthesis', 'biology', 'chemistry'])) {
      return _mockResponses['science']!;
    }

    // Nothing matched — use the default greeting/help message
    return _mockResponses['default']!;
  }

  // ── _containsAny ────────────────────────────────────────────
  // Helper: returns true if the input contains ANY of the keywords.
  // Makes _pickMockResponse much easier to read above.
  bool _containsAny(String input, List<String> keywords) {
    return keywords.any((word) => input.contains(word));
  }

  // ── clearHistory ────────────────────────────────────────────
  // Wipes the conversation history.
  // Called when the student taps "Clear Chat" on the home screen.
  void clearHistory() {
    _conversationHistory.clear();
  }


  Future<bool> isOllamaRunning() async {
    return true;
  }
}
