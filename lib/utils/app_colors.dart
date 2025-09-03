import 'package:flutter/material.dart';

/// 🎨 Cores principais do app Katholiks
class AppColors {
  // Private constructor para prevenir instanciação
  AppColors._();

  // 🟣 Cores Primárias - Tema Católico
  static const Color primary = Color(0xFF6A1B9A); // Roxo católico
  static const Color primaryLight = Color(0xFF9C4DCC); // Roxo claro
  static const Color primaryDark = Color(0xFF4A148C); // Roxo escuro
  static const Color primaryContainer = Color(0xFFE1BEE7); // Container primário

  // 🔵 Cores Secundárias - Complementares
  static const Color secondary = Color(0xFF1976D2); // Azul católico
  static const Color secondaryLight = Color(0xFF42A5F5); // Azul claro
  static const Color secondaryDark = Color(0xFF0D47A1); // Azul escuro
  static const Color secondaryContainer =
      Color(0xFFBBDEFB); // Container secundário

  // 🌟 Cores de Destaque
  static const Color accent = Color(0xFFFFB74D); // Dourado católico
  static const Color gold = Color(0xFFFFD700); // Ouro
  static const Color silver = Color(0xFFC0C0C0); // Prata

  // ⚠️ Cores de Status
  static const Color success = Color(0xFF4CAF50); // Verde sucesso
  static const Color warning = Color(0xFFFF9800); // Laranja aviso
  static const Color error = Color(0xFFE53935); // Vermelho erro
  static const Color info = Color(0xFF2196F3); // Azul info

  // 🌫️ Cores Neutras
  static const Color background = Color(0xFFFAFAFA); // Fundo claro
  static const Color surface = Color(0xFFFFFFFF); // Superfície
  static const Color surfaceVariant =
      Color(0xFFF5F5F5); // Variante da superfície
  static const Color outline = Color(0xFFBDBDBD); // Contorno

  // 📝 Cores de Texto
  static const Color onPrimary = Color(0xFFFFFFFF); // Texto sobre primária
  static const Color onSecondary = Color(0xFFFFFFFF); // Texto sobre secundária
  static const Color onBackground = Color(0xFF212121); // Texto sobre fundo
  static const Color onSurface = Color(0xFF212121); // Texto sobre superfície
  static const Color textPrimary = Color(0xFF212121); // Texto primário
  static const Color textSecondary = Color(0xFF757575); // Texto secundário
  static const Color textDisabled = Color(0xFFBDBDBD); // Texto desabilitado

  // 🌙 Cores para Dark Theme
  static const Color darkBackground = Color(0xFF121212); // Fundo escuro
  static const Color darkSurface = Color(0xFF1E1E1E); // Superfície escura
  static const Color darkPrimary = Color(0xFFAB47BC); // Primária escura
  static const Color darkOnBackground =
      Color(0xFFE0E0E0); // Texto sobre fundo escuro
  static const Color darkOnSurface =
      Color(0xFFE0E0E0); // Texto sobre superfície escura

  // 🎭 Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryDark],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [gold, accent],
  );
}

/// 🎨 Esquemas de cores prontos
class AppColorSchemes {
  static ColorScheme get lightScheme => ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        background: AppColors.background,
        surface: AppColors.surface,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.onSecondary,
        onError: Colors.white,
        onBackground: AppColors.onBackground,
        onSurface: AppColors.onSurface,
      );

  static ColorScheme get darkScheme => ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.darkPrimary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        background: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.white,
        onBackground: AppColors.darkOnBackground,
        onSurface: AppColors.darkOnSurface,
      );
}

/// 🎨 Extensão para facilitar o uso
extension AppColorsExtension on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;

  Color get primary => colors.primary;
  Color get secondary => colors.secondary;
  Color get background => colors.background;
  Color get surface => colors.surface;
  Color get error => colors.error;

  // Cores customizadas sempre disponíveis
  Color get gold => AppColors.gold;
  Color get success => AppColors.success;
  Color get warning => AppColors.warning;
  Color get textSecondary => AppColors.textSecondary;
}
