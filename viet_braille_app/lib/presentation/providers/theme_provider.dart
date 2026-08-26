import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

/// Quản lý dark mode. `true` = dark mode, `false` = light mode.
class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false) {
    _loadTheme();
  }

  static const _key = 'dark_mode';

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? false;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, state);
  }
}

final fontScaleProvider = StateNotifierProvider<FontScaleNotifier, double>((
  ref,
) {
  return FontScaleNotifier();
});

/// Quản lý font scale cho chế độ chữ lớn. Mặc định 1.0.
class FontScaleNotifier extends StateNotifier<double> {
  FontScaleNotifier() : super(1.0) {
    _loadFontScale();
  }

  static const _key = 'font_scale';

  Future<void> _loadFontScale() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getDouble(_key) ?? 1.0;
  }

  Future<void> setFontScale(double scale) async {
    state = scale.clamp(0.8, 2.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_key, state);
  }
}

/// Bật/tắt nhận diện markdown `**bold**`, `*italic*`, `_underline_` trong
/// văn bản nguồn và chèn marker định dạng Braille. Mặc định: tắt.
final markdownFormatProvider =
    StateNotifierProvider<MarkdownFormatNotifier, bool>((ref) {
      return MarkdownFormatNotifier();
    });

class MarkdownFormatNotifier extends StateNotifier<bool> {
  MarkdownFormatNotifier() : super(false) {
    _load();
  }

  static const _key = 'markdown_format';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? false;
  }

  Future<void> setMarkdownFormat(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }
}
