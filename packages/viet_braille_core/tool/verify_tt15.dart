import 'dart:convert';
import 'dart:io';

import 'package:viet_braille_core/viet_braille_core.dart';

void main() {
  final packageRoot = File.fromUri(Platform.script).parent.parent;
  final repositoryRoot = packageRoot.parent.parent;
  final fixture = File(
    '${repositoryRoot.path}${Platform.pathSeparator}tools'
    '${Platform.pathSeparator}data'
    '${Platform.pathSeparator}tt15_rules.json',
  );

  if (!fixture.existsSync()) {
    stderr.writeln('Missing independent TT15 fixture: ${fixture.path}');
    exitCode = 2;
    return;
  }

  final rules = jsonDecode(fixture.readAsStringSync()) as Map<String, dynamic>;
  final mapping = BrailleMappingImpl();
  final converter = BrailleConverterImpl(mapping);
  final failures = <String>[];
  var checks = 0;

  String dotsToUnicode(Object? value) {
    final dots = value as List<dynamic>;
    if (dots.isNotEmpty && dots.first is List<dynamic>) {
      return dots.map(dotsToUnicode).join();
    }
    var mask = 0;
    for (final dot in dots.cast<int>()) {
      mask |= 1 << (dot - 1);
    }
    return String.fromCharCode(0x2800 + mask);
  }

  void check(String label, Object? actual, Object? expected) {
    checks++;
    if (actual != expected) {
      failures.add('$label: expected "$expected", got "$actual"');
    }
  }

  for (final category in ['alphabet', 'extended']) {
    final entries = rules[category] as Map<String, dynamic>;
    for (final entry in entries.entries) {
      final info = entry.value as Map<String, dynamic>;
      final expected = dotsToUnicode(info['dots']);
      check('$category.${entry.key}.fixture', info['unicode'], expected);
      check('$category.${entry.key}', mapping.mapChar(entry.key), expected);
    }
  }

  const toneSamples = <String, String>{
    'huyền': 'à',
    'sắc': 'á',
    'hỏi': 'ả',
    'ngã': 'ã',
    'nặng': 'ạ',
  };
  final tones = rules['tones'] as Map<String, dynamic>;
  for (final entry in toneSamples.entries) {
    final info = tones[entry.key] as Map<String, dynamic>;
    final expected = dotsToUnicode(info['dots']);
    check('tones.${entry.key}.fixture', info['unicode'], expected);
    final mapped = mapping.mapChar(entry.value);
    check('tones.${entry.key}', mapped?.substring(0, 1), expected);
  }

  final symbols = rules['symbols'] as Map<String, dynamic>;
  check(
    'symbols.capital_indicator',
    mapping.capitalIndicator,
    (symbols['capital_indicator'] as Map<String, dynamic>)['unicode'],
  );
  check(
    'symbols.capital_phrase',
    mapping.allCapsPhrase,
    (symbols['capital_phrase'] as Map<String, dynamic>)['unicode'],
  );
  check(
    'symbols.number_indicator',
    mapping.numberIndicator,
    (symbols['number_indicator'] as Map<String, dynamic>)['unicode'],
  );

  for (final ruleName in ['qu_rule', 'gi_rule']) {
    final rule = rules[ruleName] as Map<String, dynamic>;
    final examples = (rule['examples'] as List<dynamic>).cast<String>();
    for (final example in examples) {
      final result = converter.convertWithDetails(example);
      checks++;
      if (result.hasWarnings || result.brailleText.isEmpty) {
        failures.add(
          '$ruleName.$example: conversion failed or had warnings '
          '${result.unmappedCharacters}',
        );
      }
    }
  }

  if (failures.isNotEmpty) {
    stderr.writeln('TT15 verification failed (${failures.length}/$checks):');
    for (final failure in failures) {
      stderr.writeln('  - $failure');
    }
    exitCode = 1;
    return;
  }

  stdout.writeln('TT15 verification passed: $checks independent checks.');
}
