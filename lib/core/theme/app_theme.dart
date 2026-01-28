import 'package:flutter/material.dart';

class AppTheme {
  static ColorScheme get _lightScheme => ColorScheme.fromSeed(
        brightness: Brightness.light,
        seedColor: const Color(0xFF0FA27A),
        primary: const Color(0xFF0FA27A),
        secondary: const Color(0xFF1E4A72),
        tertiary: const Color(0xFF6F5CFF),
        surface: const Color(0xFFFFFFFF),
        onSurface: const Color(0xFF0E1A1F),
        error: const Color(0xFFD14343),
      );

  static ColorScheme get _darkScheme => ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: const Color(0xFF30C48D),
        primary: const Color(0xFF30C48D),
        secondary: const Color(0xFF8DB7FF),
        tertiary: const Color(0xFFB7A6FF),
        surface: const Color(0xFF111722),
        onSurface: const Color(0xFFE6EDF3),
        error: const Color(0xFFF87272),
      );

  static ThemeData get light => _base(_lightScheme);
  static ThemeData get dark => _base(_darkScheme);

  static ThemeData _base(ColorScheme scheme) {
    final base = ThemeData(colorScheme: scheme, useMaterial3: true);
    final text = base.textTheme;
    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      textTheme: text.copyWith(
        headlineLarge: text.headlineLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
        headlineMedium: text.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        bodyLarge: text.bodyLarge?.copyWith(height: 1.4),
        bodyMedium: text.bodyMedium?.copyWith(height: 1.4),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        scrolledUnderElevation: 0.5,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 1.2),
        ),
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.secondary,
          textStyle: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.tertiary,
        foregroundColor: scheme.onTertiary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      chipTheme: base.chipTheme.copyWith(
        selectedColor: scheme.primary.withValues(alpha: 0.12),
        side: BorderSide(color: scheme.outline.withValues(alpha: 0.3)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        labelStyle: text.labelLarge,
      ),
      dividerColor: scheme.outlineVariant,
    );
  }
}
