import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viet_braille_app/presentation/widgets/braille_display_section.dart';

void main() {
  testWidgets('uses bundled Braille font and exposes copy action', (
    tester,
  ) async {
    var copyCalls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BrailleDisplaySection(
            brailleText: '⠧⠊⠣⠞',
            onCopy: () => copyCalls++,
          ),
        ),
      ),
    );

    final output = tester.widget<SelectableText>(find.byType(SelectableText));
    expect(output.style?.fontFamily, 'NotoSansSymbols2');

    await tester.tap(find.byIcon(Icons.copy));
    expect(copyCalls, 1);
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  });
}
