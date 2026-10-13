import 'package:flutter/material.dart';

/// The app's black and white Material themes.
abstract final class AppTheme {
  /// White surfaces and black primary controls.
  static final ThemeData light = _build(Brightness.light);

  /// Black surfaces and white primary controls.
  static final ThemeData dark = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final foreground = isDark ? Colors.white : Colors.black;
    final background = isDark ? Colors.black : Colors.white;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: Colors.black,
          brightness: brightness,
          dynamicSchemeVariant: DynamicSchemeVariant.monochrome,
        ).copyWith(
          primary: foreground,
          onPrimary: background,
          surface: background,
          onSurface: foreground,
          error: foreground,
          onError: background,
          errorContainer: isDark
              ? const Color(0xFF303030)
              : const Color(0xFFEDEDED),
          onErrorContainer: foreground,
          surfaceTint: Colors.transparent,
        );
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: foreground,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      useMaterial3: true,
    );
  }
}
