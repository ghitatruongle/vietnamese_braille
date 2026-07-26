import 'package:flutter/material.dart';

import 'package:viet_braille_core/viet_braille_core.dart';
import 'braille_grid_widget.dart';

/// Màn hình học chữ Braille tương tác.
class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  String _currentChar = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Học chữ Braille'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Chạm vào các điểm để tạo ký tự Braille',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            BrailleGridWidget(
              onCharacterDecoded: (char) {
                setState(() => _currentChar = char);
              },
            ),
            const SizedBox(height: 24),
            if (_currentChar.isNotEmpty) ...[
              Text(
                'Ký tự Braille: $_currentChar',
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 8),
              Text(
                'Unicode: U+${_currentChar.codeUnitAt(0).toRadixString(16).toUpperCase().padLeft(4, '0')}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Bảng chữ cái Braille tiếng Việt',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildAlphabetGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildAlphabetGrid() {
    final mapping = BrailleMappingImpl();
    final letters = 'aăâbcdđeêghiklmnoôơpqrstuvxy';

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: letters.split('').map((letter) {
        final braille = mapping.mapChar(letter) ?? '?';
        return Chip(label: Text('$letter $braille'));
      }).toList(),
    );
  }
}
