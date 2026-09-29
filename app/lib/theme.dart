import 'package:flutter/material.dart';

import 'data/app_state.dart';

class AppColors {
  static const background = Color(0xFF0E1014);
  static const surface = Color(0xFF171A20);
  static const surfaceHigh = Color(0xFF20242C);
  static const accent = Color(0xFFFF7A45);
  static const textPrimary = Color(0xFFECEEF2);
  static const textSecondary = Color(0xFF9AA0AB);
  static const read = Color(0xFF4CC38A);

  static Color objectClass(String? cls) => switch (cls) {
        'safe' => const Color(0xFF4CC38A),
        'euclid' => const Color(0xFFF2C94C),
        'keter' => const Color(0xFFEB5757),
        'thaumiel' => const Color(0xFF9B51E0),
        'apollyon' => const Color(0xFFB91C1C),
        'neutralized' || 'decommissioned' => const Color(0xFF828282),
        'explained' => const Color(0xFF56CCF2),
        _ => const Color(0xFF6B7280),
      };
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.accent,
    brightness: Brightness.dark,
  ).copyWith(
    primary: AppColors.accent,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.accent.withValues(alpha: 0.18),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w400,
          color: states.contains(WidgetState.selected)
              ? AppColors.accent
              : AppColors.textSecondary,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? AppColors.accent
              : AppColors.textSecondary,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.accent.withValues(alpha: 0.2),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      labelStyle: const TextStyle(color: AppColors.textPrimary),
    ),
    dividerColor: Colors.white10,
  );
}

class ReaderPalette {
  const ReaderPalette(this.background, this.text, this.muted, this.quote);

  final Color background;
  final Color text;
  final Color muted;
  final Color quote;

  static ReaderPalette of(ReaderTheme theme) => switch (theme) {
        ReaderTheme.dark => const ReaderPalette(
            Color(0xFF111317), Color(0xFFDADDE3), Color(0xFF8B919C), Color(0xFF1C1F26)),
        ReaderTheme.sepia => const ReaderPalette(
            Color(0xFFF4ECD8), Color(0xFF3B3024), Color(0xFF7A6A55), Color(0xFFE9DEC4)),
        ReaderTheme.light => const ReaderPalette(
            Color(0xFFFFFFFF), Color(0xFF1F2328), Color(0xFF6B7280), Color(0xFFF1F3F5)),
      };
}
