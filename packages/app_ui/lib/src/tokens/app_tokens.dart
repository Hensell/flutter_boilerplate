import 'package:flutter/material.dart';

/// Spacing scale shared by screens and components.
abstract final class AppSpacing {
  /// Compact separation.
  static const small = 8.0;

  /// Separation within a section.
  static const medium = 12.0;

  /// Separation between related groups.
  static const large = 16.0;

  /// Divider breathing room.
  static const divider = 20.0;

  /// Screen padding and section separation.
  static const section = 24.0;

  /// Separation between major groups.
  static const major = 32.0;
}

/// Responsive content widths.
abstract final class AppLayout {
  /// Width for forms and preferences.
  static const formWidth = 640.0;

  /// Width for reading content.
  static const readingWidth = 720.0;
}

/// Monochrome palette. Features consume semantic roles from the active theme.
abstract final class AppColors {
  /// White surface or foreground.
  static const Color white = Colors.white;

  /// Black surface or foreground.
  static const Color black = Colors.black;

  /// Dark error surface.
  static const darkError = Color(0xFF303030);

  /// Light error surface.
  static const lightError = Color(0xFFEDEDED);
}
