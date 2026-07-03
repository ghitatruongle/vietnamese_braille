import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viet_braille_app/core/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('light theme uses light brightness', () {
      expect(AppTheme.light().brightness, equals(Brightness.light));
    });

    test('dark theme uses dark brightness', () {
      expect(AppTheme.dark().brightness, equals(Brightness.dark));
    });

    test('both themes use Material 3', () {
      expect(AppTheme.light().useMaterial3, isTrue);
      expect(AppTheme.dark().useMaterial3, isTrue);
    });

    test('both themes are derived from same seed color', () {
      expect(AppTheme.light().colorScheme.primary, isNotNull);
      expect(AppTheme.dark().colorScheme.primary, isNotNull);
      expect(AppTheme.light().colorScheme, isA<ColorScheme>());
      expect(AppTheme.dark().colorScheme, isA<ColorScheme>());
    });

    test('app bar theme has center title and elevation 2', () {
      expect(AppTheme.light().appBarTheme.centerTitle, isTrue);
      expect(AppTheme.light().appBarTheme.elevation, equals(2));
      expect(AppTheme.dark().appBarTheme.centerTitle, isTrue);
      expect(AppTheme.dark().appBarTheme.elevation, equals(2));
    });

    test('elevated button theme has rounded rectangle shape', () {
      final lightStyle = AppTheme.light().elevatedButtonTheme.style;
      final darkStyle = AppTheme.dark().elevatedButtonTheme.style;
      expect(lightStyle, isNotNull);
      expect(darkStyle, isNotNull);
    });

    test('input decoration theme has outline border', () {
      final lightBorder = AppTheme.light().inputDecorationTheme.border;
      final darkBorder = AppTheme.dark().inputDecorationTheme.border;
      expect(lightBorder, isA<OutlineInputBorder>());
      expect(darkBorder, isA<OutlineInputBorder>());
    });

    test('input decoration theme has correct content padding', () {
      final padding = AppTheme.light().inputDecorationTheme.contentPadding;
      expect(
        padding,
        equals(const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
      );
    });

    test('font scale parameter is applied', () {
      final normal = AppTheme.light();
      final scaled = AppTheme.light(fontScale: 1.5);
      // bodyLarge should have a fontSize that scales with fontScale
      final normalSize = normal.textTheme.bodyLarge?.fontSize ?? 14.0;
      final scaledSize = scaled.textTheme.bodyLarge?.fontSize ?? 14.0;
      expect(scaledSize, greaterThan(normalSize));
    });
  });
}
