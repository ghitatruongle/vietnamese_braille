import 'dart:math';

import 'package:flutter/material.dart';

import '../core/braille_mapping.dart';
import '../domain/braille_converter.dart';

/// Màn hình quiz Braille — chọn đáp án đúng.
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late BrailleMapping _mapping;
  late BrailleConverter _converter;

  int _score = 0;
  int _total = 0;
  String _currentQuestion = '';
  String _currentAnswer = '';
  List<String> _options = [];
  String? _selectedAnswer;
  bool _answered = false;

  static const _letters = 'aăâbcdđeêghiklmnoôơpqrstuvxy';
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _mapping = BrailleMappingImpl();
    _converter = BrailleConverterImpl(_mapping);
    _generateQuestion();
  }

  void _generateQuestion() {
    final letter = _letters[_random.nextInt(_letters.length)];

    _currentQuestion = letter;
    _currentAnswer = _converter.convert(letter);

    // Generate 4 options (1 correct + 3 wrong)
    _options = [_currentAnswer];
    int attempts = 0;
    const maxAttempts = 100;
    while (_options.length < 4 && attempts < maxAttempts) {
      final wrongLetter = _letters[_random.nextInt(_letters.length)];
      final wrongBraille = _converter.convert(wrongLetter);
      if (!_options.contains(wrongBraille)) {
        _options.add(wrongBraille);
      }
      attempts++;
    }
    _options.shuffle();

    _selectedAnswer = null;
    _answered = false;
  }

  void _checkAnswer(String answer) {
    setState(() {
      _selectedAnswer = answer;
      _answered = true;
      _total++;
      if (answer == _currentAnswer) _score++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Braille'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Điểm: $_score / $_total',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 32),
            Text(
              'Chuyển đổi chữ "$_currentQuestion" sang Braille:',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ..._options.map(
              (option) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _answered ? null : () => _checkAnswer(option),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _answered
                          ? (option == _currentAnswer
                                ? Colors.green
                                : (option == _selectedAnswer
                                      ? Colors.red
                                      : null))
                          : null,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(option, style: const TextStyle(fontSize: 24)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_answered)
              ElevatedButton(
                onPressed: () => setState(() => _generateQuestion()),
                child: const Text('Câu tiếp theo'),
              ),
          ],
        ),
      ),
    );
  }
}
