import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:viet_braille_core/viet_braille_core.dart';
import 'braille_semantics.dart';

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

  void _selectOption(int index) {
    if (_answered || index < 0 || index >= _options.length) return;
    _checkAnswer(_options[index]);
  }

  void _nextQuestion() {
    if (!_answered) return;
    setState(_generateQuestion);
  }

  @override
  Widget build(BuildContext context) {
    final shortcuts = <ShortcutActivator, VoidCallback>{
      const SingleActivator(LogicalKeyboardKey.digit1): () => _selectOption(0),
      const SingleActivator(LogicalKeyboardKey.digit2): () => _selectOption(1),
      const SingleActivator(LogicalKeyboardKey.digit3): () => _selectOption(2),
      const SingleActivator(LogicalKeyboardKey.digit4): () => _selectOption(3),
      const SingleActivator(LogicalKeyboardKey.keyN): _nextQuestion,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Braille'), centerTitle: true),
      body: CallbackShortcuts(
        bindings: shortcuts,
        child: Focus(
          autofocus: true,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Semantics(
                liveRegion: true,
                label: 'Điểm số: $_score trên $_total câu',
                child: ExcludeSemantics(
                  child: Text(
                    'Điểm: $_score / $_total',
                    style: const TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Semantics(
                header: true,
                child: Text(
                  'Chuyển đổi chữ "$_currentQuestion" sang Braille:',
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Dùng phím 1 đến 4 để chọn đáp án.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ..._options.indexed.map((entry) {
                final (index, option) = entry;
                final optionNumber = index + 1;
                final isCorrect = option == _currentAnswer;
                final isSelected = option == _selectedAnswer;
                final status = !_answered
                    ? ''
                    : isCorrect
                    ? ', đáp án đúng'
                    : isSelected
                    ? ', đã chọn, chưa đúng'
                    : ', không được chọn';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: SizedBox(
                    width: double.infinity,
                    child: Semantics(
                      label:
                          'Đáp án $optionNumber: ${describeBraille(option)}$status',
                      button: true,
                      enabled: !_answered,
                      selected: isSelected,
                      onTap: _answered ? null : () => _checkAnswer(option),
                      child: ExcludeSemantics(
                        child: ElevatedButton(
                          onPressed: _answered
                              ? null
                              : () => _checkAnswer(option),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _answered
                                ? (isCorrect
                                      ? Colors.green
                                      : (isSelected ? Colors.red : null))
                                : null,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            '$optionNumber. $option',
                            style: const TextStyle(
                              fontFamily: 'NotoSansSymbols2',
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
              if (_answered) ...[
                Semantics(
                  liveRegion: true,
                  label: _selectedAnswer == _currentAnswer
                      ? 'Chính xác'
                      : 'Chưa đúng. Đáp án đúng là ${describeBraille(_currentAnswer)}',
                  child: ExcludeSemantics(
                    child: Text(
                      _selectedAnswer == _currentAnswer
                          ? 'Chính xác!'
                          : 'Chưa đúng. Đáp án đúng: $_currentAnswer',
                      style: const TextStyle(
                        fontFamily: 'NotoSansSymbols2',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Semantics(
                  button: true,
                  label: 'Câu tiếp theo, phím N',
                  onTap: _nextQuestion,
                  child: ExcludeSemantics(
                    child: ElevatedButton(
                      onPressed: _nextQuestion,
                      child: const Text('Câu tiếp theo'),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
