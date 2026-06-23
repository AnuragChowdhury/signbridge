import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import 'color_schemes.dart';
import 'text_styles.dart';

/// Material Design 3 theme definitions for SignBridge.
///
/// Provides both light and dark themes with consistent
/// component styling, elevation, and shape configuration.
class AppTheme {
  AppTheme._();

  // ── Light Theme ──
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: AppColors.lightScheme,
      textTheme: _textTheme,
      appBarTheme: _appBarTheme(AppColors.lightScheme),
      cardTheme: _cardTheme(AppColors.lightScheme),
      elevatedButtonTheme: _elevatedButtonTheme(AppColors.lightScheme),
      filledButtonTheme: _filledButtonTheme(AppColors.lightScheme),
      outlinedButtonTheme: _outlinedButtonTheme(AppColors.lightScheme),
      iconButtonTheme: _iconButtonTheme(AppColors.lightScheme),
      floatingActionButtonTheme: _fabTheme(AppColors.lightScheme),
      inputDecorationTheme: _inputTheme(AppColors.lightScheme),
      switchTheme: _switchTheme(AppColors.lightScheme),
      sliderTheme: _sliderTheme(AppColors.lightScheme),
      chipTheme: _chipTheme(AppColors.lightScheme),
      dialogTheme: _dialogTheme(AppColors.lightScheme),
      bottomSheetTheme: _bottomSheetTheme(AppColors.lightScheme),
      snackBarTheme: _snackBarTheme(AppColors.lightScheme),
      dividerTheme: DividerThemeData(
        color: AppColors.lightScheme.outlineVariant,
        thickness: 1,
      ),
      scaffoldBackgroundColor: AppColors.lightScheme.surface,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // ── Dark Theme ──
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: AppColors.darkScheme,
      textTheme: _textTheme,
      appBarTheme: _appBarTheme(AppColors.darkScheme),
      cardTheme: _cardTheme(AppColors.darkScheme),
      elevatedButtonTheme: _elevatedButtonTheme(AppColors.darkScheme),
      filledButtonTheme: _filledButtonTheme(AppColors.darkScheme),
      outlinedButtonTheme: _outlinedButtonTheme(AppColors.darkScheme),
      iconButtonTheme: _iconButtonTheme(AppColors.darkScheme),
      floatingActionButtonTheme: _fabTheme(AppColors.darkScheme),
      inputDecorationTheme: _inputTheme(AppColors.darkScheme),
      switchTheme: _switchTheme(AppColors.darkScheme),
      sliderTheme: _sliderTheme(AppColors.darkScheme),
      chipTheme: _chipTheme(AppColors.darkScheme),
      dialogTheme: _dialogTheme(AppColors.darkScheme),
      bottomSheetTheme: _bottomSheetTheme(AppColors.darkScheme),
      snackBarTheme: _snackBarTheme(AppColors.darkScheme),
      dividerTheme: DividerThemeData(
        color: AppColors.darkScheme.outlineVariant,
        thickness: 1,
      ),
      scaffoldBackgroundColor: AppColors.darkScheme.surface,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // ── Text Theme ──
  static const TextTheme _textTheme = TextTheme(
    displayLarge: AppTextStyles.displayLarge,
    displayMedium: AppTextStyles.displayMedium,
    displaySmall: AppTextStyles.displaySmall,
    headlineLarge: AppTextStyles.headlineLarge,
    headlineMedium: AppTextStyles.headlineMedium,
    headlineSmall: AppTextStyles.headlineSmall,
    titleLarge: AppTextStyles.titleLarge,
    titleMedium: AppTextStyles.titleMedium,
    titleSmall: AppTextStyles.titleSmall,
    bodyLarge: AppTextStyles.bodyLarge,
    bodyMedium: AppTextStyles.bodyMedium,
    bodySmall: AppTextStyles.bodySmall,
    labelLarge: AppTextStyles.labelLarge,
    labelMedium: AppTextStyles.labelMedium,
    labelSmall: AppTextStyles.labelSmall,
  );

  // ── Component Themes ──

  static AppBarTheme _appBarTheme(ColorScheme scheme) {
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 2,
      centerTitle: true,
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      titleTextStyle: AppTextStyles.titleLarge.copyWith(
        color: scheme.onSurface,
      ),
    );
  }

  static CardThemeData _cardTheme(ColorScheme scheme) {
    return CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        side: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      color: scheme.surfaceContainerHighest,
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme(ColorScheme scheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        ),
        textStyle: AppTextStyles.labelLarge,
      ),
    );
  }

  static FilledButtonThemeData _filledButtonTheme(ColorScheme scheme) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        ),
        textStyle: AppTextStyles.labelLarge,
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme(ColorScheme scheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        ),
        side: BorderSide(color: scheme.outline),
        textStyle: AppTextStyles.labelLarge,
      ),
    );
  }

  static IconButtonThemeData _iconButtonTheme(ColorScheme scheme) {
    return IconButtonThemeData(
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        ),
      ),
    );
  }

  static FloatingActionButtonThemeData _fabTheme(ColorScheme scheme) {
    return FloatingActionButtonThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
    );
  }

  static InputDecorationTheme _inputTheme(ColorScheme scheme) {
    return InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        borderSide: BorderSide(color: scheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: scheme.onSurfaceVariant,
      ),
    );
  }

  static SwitchThemeData _switchTheme(ColorScheme scheme) {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return scheme.primary;
        return scheme.outline;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return scheme.primaryContainer;
        }
        return scheme.surfaceContainerHighest;
      }),
    );
  }

  static SliderThemeData _sliderTheme(ColorScheme scheme) {
    return SliderThemeData(
      activeTrackColor: scheme.primary,
      inactiveTrackColor: scheme.surfaceContainerHighest,
      thumbColor: scheme.primary,
      overlayColor: scheme.primary.withValues(alpha: 0.12),
      valueIndicatorColor: scheme.primary,
      valueIndicatorTextStyle: AppTextStyles.labelMedium.copyWith(
        color: scheme.onPrimary,
      ),
    );
  }

  static ChipThemeData _chipTheme(ColorScheme scheme) {
    return ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.chipBorderRadius),
      ),
      side: BorderSide(color: scheme.outlineVariant),
      backgroundColor: scheme.surfaceContainerHighest,
      labelStyle: AppTextStyles.labelMedium,
    );
  }

  static DialogThemeData _dialogTheme(ColorScheme scheme) {
    return DialogThemeData(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      backgroundColor: scheme.surface,
    );
  }

  static BottomSheetThemeData _bottomSheetTheme(ColorScheme scheme) {
    return BottomSheetThemeData(
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    );
  }

  static SnackBarThemeData _snackBarTheme(ColorScheme scheme) {
    return SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
      ),
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(
        color: scheme.onInverseSurface,
      ),
    );
  }
}
