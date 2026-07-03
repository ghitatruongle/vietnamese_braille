import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viet_braille_app/presentation/providers/theme_provider.dart';

void main() {
  group('ThemeNotifier', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initial state is false (light mode)', () {
      final container = ProviderContainer();
      final isDark = container.read(themeProvider);
      expect(isDark, isFalse);
    });

    test('loads saved dark mode preference', () async {
      SharedPreferences.setMockInitialValues({'dark_mode': true});
      final container = ProviderContainer();
      // Trigger provider creation and wait for async _loadTheme
      container.read(themeProvider);
      // Allow microtasks and timers to flush
      await Future.delayed(const Duration(milliseconds: 100));
      final isDark = container.read(themeProvider);
      expect(isDark, isTrue);
    });

    test('toggle flips state and persists', () async {
      final container = ProviderContainer();
      expect(container.read(themeProvider), isFalse);

      await container.read(themeProvider.notifier).toggle();
      expect(container.read(themeProvider), isTrue);

      // Verify persisted
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('dark_mode'), isTrue);

      await container.read(themeProvider.notifier).toggle();
      expect(container.read(themeProvider), isFalse);
      expect(prefs.getBool('dark_mode'), isFalse);
    });
  });
}
