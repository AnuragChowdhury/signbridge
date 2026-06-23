import 'package:flutter/material.dart';

/// Color schemes for SignBridge light and dark themes.
///
/// Uses a curated palette with teal/cyan primary tones,
/// warm amber accents, and soft purple highlights.
class AppColors {
  AppColors._();

  // ── Seed Colors ──
  static const Color primarySeed = Color(0xFF0D9488); // Teal-500
  static const Color secondarySeed = Color(0xFFF59E0B); // Amber-500
  static const Color tertiarySeed = Color(0xFF8B5CF6); // Violet-500

  // ── Light Theme Colors ──
  static const lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF0D9488),
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFCCFBF1),
    onPrimaryContainer: Color(0xFF064E3B),
    secondary: Color(0xFFF59E0B),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFFEF3C7),
    onSecondaryContainer: Color(0xFF78350F),
    tertiary: Color(0xFF8B5CF6),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFEDE9FE),
    onTertiaryContainer: Color(0xFF3B0764),
    error: Color(0xFFEF4444),
    onError: Colors.white,
    errorContainer: Color(0xFFFEE2E2),
    onErrorContainer: Color(0xFF7F1D1D),
    surface: Color(0xFFFAFAFA),
    onSurface: Color(0xFF1F2937),
    surfaceContainerHighest: Color(0xFFF3F4F6),
    onSurfaceVariant: Color(0xFF4B5563),
    outline: Color(0xFFD1D5DB),
    outlineVariant: Color(0xFFE5E7EB),
    shadow: Colors.black12,
    scrim: Colors.black54,
    inverseSurface: Color(0xFF1F2937),
    onInverseSurface: Color(0xFFF9FAFB),
    inversePrimary: Color(0xFF5EEAD4),
  );

  // ── Dark Theme Colors ──
  static const darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF5EEAD4),
    onPrimary: Color(0xFF003D36),
    primaryContainer: Color(0xFF115E59),
    onPrimaryContainer: Color(0xFFCCFBF1),
    secondary: Color(0xFFFBBF24),
    onSecondary: Color(0xFF451A03),
    secondaryContainer: Color(0xFF78350F),
    onSecondaryContainer: Color(0xFFFEF3C7),
    tertiary: Color(0xFFA78BFA),
    onTertiary: Color(0xFF2E1065),
    tertiaryContainer: Color(0xFF4C1D95),
    onTertiaryContainer: Color(0xFFEDE9FE),
    error: Color(0xFFFCA5A5),
    onError: Color(0xFF450A0A),
    errorContainer: Color(0xFF7F1D1D),
    onErrorContainer: Color(0xFFFEE2E2),
    surface: Color(0xFF0F172A),
    onSurface: Color(0xFFF1F5F9),
    surfaceContainerHighest: Color(0xFF1E293B),
    onSurfaceVariant: Color(0xFF94A3B8),
    outline: Color(0xFF475569),
    outlineVariant: Color(0xFF334155),
    shadow: Colors.black26,
    scrim: Colors.black87,
    inverseSurface: Color(0xFFF1F5F9),
    onInverseSurface: Color(0xFF0F172A),
    inversePrimary: Color(0xFF0D9488),
  );

  // ── Gradient Colors ──
  static const List<Color> primaryGradient = [
    Color(0xFF0D9488),
    Color(0xFF0EA5E9),
  ];

  static const List<Color> darkGradient = [
    Color(0xFF0F172A),
    Color(0xFF1E293B),
  ];

  static const List<Color> accentGradient = [
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
  ];

  // ── Confidence Level Colors ──
  static const Color highConfidence = Color(0xFF10B981);
  static const Color mediumConfidence = Color(0xFFF59E0B);
  static const Color lowConfidence = Color(0xFFEF4444);

  /// Returns a color based on the confidence value.
  static Color confidenceColor(double confidence) {
    if (confidence >= 0.8) return highConfidence;
    if (confidence >= 0.5) return mediumConfidence;
    return lowConfidence;
  }

  // ── Glassmorphism ──
  static Color glassBackground(Brightness brightness) {
    return brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.7);
  }

  static Color glassBorder(Brightness brightness) {
    return brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.white.withValues(alpha: 0.3);
  }
}
