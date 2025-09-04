import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    switch (_themeMode) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
    }
  }

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? 0;
      if (themeIndex >= 0 && themeIndex < ThemeMode.values.length) {
        _themeMode = ThemeMode.values[themeIndex];
        notifyListeners();
      }
    } catch (e) {
      // Se houver erro, manter tema padrão (system)
      _themeMode = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    try {
      _themeMode = themeMode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, themeMode.index);
      notifyListeners();
    } catch (e) {
      // Se houver erro ao salvar, reverter a mudança
      debugPrint('Erro ao salvar tema: $e');
    }
  }

  Future<void> toggleTheme() async {
    final themes = [ThemeMode.light, ThemeMode.dark, ThemeMode.system];
    final currentIndex = themes.indexOf(_themeMode);
    final nextIndex = (currentIndex + 1) % themes.length;
    await setThemeMode(themes[nextIndex]);
  }

  String getThemeModeText() {
    const themeTexts = {
      ThemeMode.light: 'Claro',
      ThemeMode.dark: 'Escuro',
      ThemeMode.system: 'Sistema',
    };
    return themeTexts[_themeMode] ?? 'Sistema';
  }

  IconData getThemeIcon() {
    const themeIcons = {
      ThemeMode.light: Icons.light_mode,
      ThemeMode.dark: Icons.dark_mode,
      ThemeMode.system: Icons.brightness_auto,
    };
    return themeIcons[_themeMode] ?? Icons.brightness_auto;
  }
}
