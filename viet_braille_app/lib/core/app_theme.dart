import 'package:flutter/material.dart';

/// Quản lý theme tập trung cho ứng dụng.
/// Tránh trùng lặp giữa light theme và dark theme.
class AppTheme {
  AppTheme._();

  static const _seedColor = Colors.indigo;

  // ── Shared component themes ──
  static const _appBarTheme = AppBarTheme(centerTitle: true, elevation: 2);

  static final _elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  static final _inputDecorationTheme = InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  /// Light theme.
  static ThemeData light({double fontScale = 1.0}) =>
      _buildTheme(Brightness.light, fontScale);

  /// Dark theme.
  static ThemeData dark({double fontScale = 1.0}) =>
      _buildTheme(Brightness.dark, fontScale);

  static ThemeData _buildTheme(Brightness brightness, double fontScale) {
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: brightness,
      ),
      useMaterial3: true,
      appBarTheme: _appBarTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
    );

    // Apply font scale only if not default (1.0)
    if (fontScale == 1.0) return baseTheme;

    // Manually scale each text style to avoid null fontSize issues
    final scaledTextTheme = baseTheme.textTheme.copyWith(
      displayLarge: _scaleStyle(baseTheme.textTheme.displayLarge, fontScale),
      displayMedium: _scaleStyle(baseTheme.textTheme.displayMedium, fontScale),
      displaySmall: _scaleStyle(baseTheme.textTheme.displaySmall, fontScale),
      headlineLarge: _scaleStyle(baseTheme.textTheme.headlineLarge, fontScale),
      headlineMedium: _scaleStyle(
        baseTheme.textTheme.headlineMedium,
        fontScale,
      ),
      headlineSmall: _scaleStyle(baseTheme.textTheme.headlineSmall, fontScale),
      titleLarge: _scaleStyle(baseTheme.textTheme.titleLarge, fontScale),
      titleMedium: _scaleStyle(baseTheme.textTheme.titleMedium, fontScale),
      titleSmall: _scaleStyle(baseTheme.textTheme.titleSmall, fontScale),
      bodyLarge: _scaleStyle(baseTheme.textTheme.bodyLarge, fontScale),
      bodyMedium: _scaleStyle(baseTheme.textTheme.bodyMedium, fontScale),
      bodySmall: _scaleStyle(baseTheme.textTheme.bodySmall, fontScale),
      labelLarge: _scaleStyle(baseTheme.textTheme.labelLarge, fontScale),
      labelMedium: _scaleStyle(baseTheme.textTheme.labelMedium, fontScale),
      labelSmall: _scaleStyle(baseTheme.textTheme.labelSmall, fontScale),
    );

    return baseTheme.copyWith(textTheme: scaledTextTheme);
  }

  static TextStyle? _scaleStyle(TextStyle? style, double factor) {
    if (style == null) return null;
    final baseSize = style.fontSize ?? 14.0;
    return style.copyWith(fontSize: baseSize * factor);
  }
}
