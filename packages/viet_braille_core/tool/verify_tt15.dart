import 'dart:convert';
import 'dart:io';

import 'package:viet_braille_core/viet_braille_core.dart';

void main(List<String> arguments) {
  final jsonOutput = arguments.contains('--json');
  final packageRoot = File.fromUri(Platform.script).parent.parent;
  final repositoryRoot = packageRoot.parent.parent;
  final fixture = File(
    '${repositoryRoot.path}${Platform.pathSeparator}tools'
    '${Platform.pathSeparator}data'
    '${Platform.pathSeparator}tt15_rules.json',
  );

  if (!fixture.existsSync()) {
    _finish(
      jsonOutput: jsonOutput,
      checks: 0,
      failures: ['Missing TT15 fixture: ${fixture.path}'],
      unsupported: const [],
      reviewStatus: 'unknown',
      exitCodeValue: 2,
    );
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
      if (dot < 1 || dot > 6) {
        failures.add('invalid dot number: $dot');
        continue;
      }
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

  final metadata = rules['metadata'] as Map<String, dynamic>;
  final sourcePath = metadata['source_file'] as String;
  final sourceFile = File(
    '${repositoryRoot.path}${Platform.pathSeparator}'
    '${sourcePath.replaceAll('/', Platform.pathSeparator)}',
  );
  check('metadata.standard', metadata['standard'], 'Thông tư 15/2019/TT-BGDĐT');
  check('metadata.source_exists', sourceFile.existsSync(), true);
  check(
    'metadata.sha256_format',
    RegExp(r'^[0-9a-f]{64}$').hasMatch(metadata['source_sha256'] as String),
    true,
  );
  check(
    'metadata.review_status',
    [
      'pending_external',
      'externally_reviewed',
    ].contains(metadata['review_status']),
    true,
  );

  for (final category in ['alphabet', 'extended']) {
    final entries = rules[category] as Map<String, dynamic>;
    for (final entry in entries.entries) {
      final info = entry.value as Map<String, dynamic>;
      final expected = dotsToUnicode(info['dots']);
      check('$category.${entry.key}.fixture', info['unicode'], expected);
      check(
        '$category.${entry.key}.implementation',
        mapping.mapChar(entry.key),
        expected,
      );
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
    check(
      'tones.${entry.key}.implementation',
      mapped?.substring(0, 1),
      expected,
    );
  }

  final symbols = rules['symbols'] as Map<String, dynamic>;
  for (final entry in symbols.entries) {
    final info = entry.value as Map<String, dynamic>;
    check(
      'symbols.${entry.key}.fixture',
      info['unicode'],
      dotsToUnicode(info['dots']),
    );
  }

  final supportedSymbols = <String, String>{
    'capital_indicator': mapping.capitalIndicator,
    'capital_phrase': mapping.allCapsPhrase,
    'number_indicator': mapping.numberIndicator,
  };
  for (final entry in supportedSymbols.entries) {
    check(
      'symbols.${entry.key}.implementation',
      entry.value,
      (symbols[entry.key] as Map<String, dynamic>)['unicode'],
    );
  }

  final unsupported = (rules['unsupported_rules'] as List<dynamic>)
      .cast<Map<String, dynamic>>();
  final unsupportedSymbols = unsupported
      .map((entry) => entry['fixture_symbol'] as String)
      .toSet();
  final documentedUnsupported = unsupportedSymbols.toList()..sort();
  final expectedUnsupported =
      symbols.keys.toSet().difference(supportedSymbols.keys.toSet()).toList()
        ..sort();
  check(
    'unsupported_rules.coverage',
    documentedUnsupported.join(','),
    expectedUnsupported.join(','),
  );
  for (final entry in unsupported) {
    check(
      'unsupported_rules.${entry['id']}.status',
      entry['status'],
      'not_implemented',
    );
    check(
      'unsupported_rules.${entry['id']}.known_symbol',
      symbols.containsKey(entry['fixture_symbol']),
      true,
    );
  }

  final exactExamples = (rules['exact_examples'] as List<dynamic>)
      .cast<Map<String, dynamic>>();
  for (final example in exactExamples) {
    final input = example['input'] as String;
    final expected = example['unicode'] as String;
    final result = converter.convertWithDetails(input);
    check(
      'exact_examples.${example['id']}.warnings',
      result.hasWarnings,
      false,
    );
    check(
      'exact_examples.${example['id']}.output',
      result.brailleText,
      expected,
    );
    check(
      'exact_examples.${example['id']}.source',
      (example['source'] as String).isNotEmpty,
      true,
    );
  }

  _finish(
    jsonOutput: jsonOutput,
    checks: checks,
    failures: failures,
    unsupported: unsupported,
    reviewStatus: metadata['review_status'] as String,
    exitCodeValue: failures.isEmpty ? 0 : 1,
  );
}

Never _finish({
  required bool jsonOutput,
  required int checks,
  required List<String> failures,
  required List<Map<String, dynamic>> unsupported,
  required String reviewStatus,
  required int exitCodeValue,
}) {
  final report = <String, dynamic>{
    'standard': 'Thông tư 15/2019/TT-BGDĐT',
    'status': failures.isEmpty ? 'passed' : 'failed',
    'checks': checks,
    'failures': failures,
    'unsupported_rules': unsupported,
    'external_review_status': reviewStatus,
  };

  if (jsonOutput) {
    stdout.writeln(jsonEncode(report));
  } else if (failures.isEmpty) {
    stdout.writeln(
      'TT15 verification passed: $checks exact checks; '
      '${unsupported.length} explicitly unsupported formatting rules; '
      'external review: $reviewStatus.',
    );
  } else {
    stderr.writeln('TT15 verification failed (${failures.length}/$checks):');
    for (final failure in failures) {
      stderr.writeln('  - $failure');
    }
  }
  exit(exitCodeValue);
}
