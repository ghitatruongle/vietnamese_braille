import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viet_braille_app/presentation/providers/conversion_provider.dart';
import 'package:viet_braille_app/presentation/widgets/status_section.dart';

void main() {
  Widget buildSubject(ConversionState state) {
    return MaterialApp(
      home: Scaffold(body: StatusSection(state: state)),
    );
  }

  group('StatusSection', () {
    testWidgets('renders nothing while idle', (tester) async {
      await tester.pumpWidget(buildSubject(const ConversionState()));

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byIcon(Icons.error_outline), findsNothing);
      expect(find.byIcon(Icons.check_circle_outline), findsNothing);
    });

    testWidgets('announces and renders loading state', (tester) async {
      await tester.pumpWidget(
        buildSubject(const ConversionState(status: AppStatus.loading)),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics && widget.properties.liveRegion == true,
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders supplied error and fallback error', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          const ConversionState(
            status: AppStatus.error,
            errorMessage: 'Test error',
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Test error'), findsOneWidget);

      await tester.pumpWidget(
        buildSubject(const ConversionState(status: AppStatus.error)),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.data != null &&
              widget.data!.isNotEmpty &&
              widget.data != 'Test error',
        ),
        findsOneWidget,
      );
    });

    testWidgets('announces and renders success state', (tester) async {
      await tester.pumpWidget(
        buildSubject(const ConversionState(status: AppStatus.success)),
      );

      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics && widget.properties.liveRegion == true,
        ),
        findsOneWidget,
      );
    });
  });
}
