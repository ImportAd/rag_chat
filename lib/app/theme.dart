/// Дизайн-токены и тема «РГУП · Ассистент».
///
/// Палитра «Синий РГУП»: тёплый бежевый фон + глубокий синий акцент из логотипа.
/// Светлая тема — основная; тёмная — для вечерней работы.
library;

import 'package:flutter/material.dart';

/// Цветовые токены — Light
class AppColorsLight {
  static const bg            = Color(0xFFF5F1E8);
  static const surface       = Color(0xFFFAF7EE);
  static const surfaceAlt    = Color(0xFFEDE7D5);
  static const surface2      = Color(0xFFE2DBC3);
  static const border        = Color(0xFFDDD5BC);
  static const borderStrong  = Color(0xFFC4BA9A);
  static const text          = Color(0xFF1F2437);
  static const textMuted     = Color(0xFF5D6275);
  static const textDim       = Color(0xFF959AB0);
  static const primary       = Color(0xFF1A3A6E);
  static const primaryHover  = Color(0xFF0F2A55);
  static const onPrimary     = Color(0xFFFAF7EE);
  static const accent        = Color(0xFF1A3A6E);
  static const accentBg      = Color(0xFFE0E6F0);
  static const userAvatar    = Color(0xFF7A6D52);
  static const success       = Color(0xFF3D7A5A);
  static const warning       = Color(0xFFA8662E);
  static const danger        = Color(0xFF973232);
  static const goldAccent    = Color(0xFFB8924A);
}

/// Цветовые токены — Dark
class AppColorsDark {
  static const bg            = Color(0xFF14171F);
  static const surface       = Color(0xFF1C202B);
  static const surfaceAlt    = Color(0xFF242936);
  static const surface2      = Color(0xFF2D3342);
  static const border        = Color(0xFF2A2F3D);
  static const borderStrong  = Color(0xFF3D4456);
  static const text          = Color(0xFFE8E4D6);
  static const textMuted     = Color(0xFFA0A5B8);
  static const textDim       = Color(0xFF6D7288);
  static const primary       = Color(0xFF7AA0D6);
  static const primaryHover  = Color(0xFF95B4E0);
  static const onPrimary     = Color(0xFF14171F);
  static const accent        = Color(0xFF7AA0D6);
  static const accentBg      = Color(0xFF25304A);
  static const userAvatar    = Color(0xFFA89A78);
  static const success       = Color(0xFF68B38A);
  static const warning       = Color(0xFFD9A054);
  static const danger        = Color(0xFFD85466);
  static const goldAccent    = Color(0xFFD9B574);
}

/// Семейства шрифтов
class AppFonts {
  static const ui      = 'Inter';
  static const display = 'Lora';
  static const mono    = 'JetBrainsMono';
}

/// Радиусы
class AppRadius {
  static const sm   = 8.0;
  static const md   = 14.0;
  static const lg   = 20.0;
  static const full = 999.0;
}

/// Отступы (шкала 4 / 8 / 12 / 16 / 24 / 32)
class AppSpacing {
  static const xs  = 4.0;
  static const sm  = 8.0;
  static const md  = 12.0;
  static const lg  = 16.0;
  static const xl  = 24.0;
  static const xxl = 32.0;
}

/// Фабрика темы приложения.
class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark  => _build(Brightness.dark);

  static ThemeData _build(Brightness b) {
    final isDark = b == Brightness.dark;

    final bg           = isDark ? AppColorsDark.bg           : AppColorsLight.bg;
    final surface      = isDark ? AppColorsDark.surface      : AppColorsLight.surface;
    final surfaceAlt   = isDark ? AppColorsDark.surfaceAlt   : AppColorsLight.surfaceAlt;
    final primary      = isDark ? AppColorsDark.primary      : AppColorsLight.primary;
    final onPrimary    = isDark ? AppColorsDark.onPrimary    : AppColorsLight.onPrimary;
    final text         = isDark ? AppColorsDark.text         : AppColorsLight.text;
    final textMuted    = isDark ? AppColorsDark.textMuted    : AppColorsLight.textMuted;
    final border       = isDark ? AppColorsDark.border       : AppColorsLight.border;
    final danger       = isDark ? AppColorsDark.danger       : AppColorsLight.danger;

    final base = ThemeData(
      brightness: b,
      useMaterial3: true,
      // Глобальный шрифт — Inter; display-стили (заголовки) переопределяются через textTheme.
      fontFamily: AppFonts.ui,
    );

    return base.copyWith(
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      colorScheme: ColorScheme(
        brightness: b,
        primary: primary,
        onPrimary: onPrimary,
        secondary: primary,
        onSecondary: onPrimary,
        error: danger,
        onError: onPrimary,
        surface: surface,
        onSurface: text,
        surfaceContainerHighest: surfaceAlt,
        outline: border,
        outlineVariant: border,
      ),
      textTheme: _textTheme(text, textMuted),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: bg,
        foregroundColor: text,
        titleTextStyle: TextStyle(
          fontFamily: AppFonts.display,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: TextStyle(color: textMuted, fontFamily: AppFonts.ui, fontSize: 14),
        labelStyle: TextStyle(color: textMuted, fontFamily: AppFonts.ui, fontSize: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: danger),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(
            fontFamily: AppFonts.ui,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
          elevation: 0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(
            fontFamily: AppFonts.ui,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          side: BorderSide(color: border),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(
            fontFamily: AppFonts.ui,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(
            fontFamily: AppFonts.ui,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: surface,
        contentTextStyle: TextStyle(color: text, fontFamily: AppFonts.ui, fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          side: BorderSide(color: border),
        ),
      ),
    );
  }

  static TextTheme _textTheme(Color text, Color muted) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: AppFonts.display,
        fontSize: 34, fontWeight: FontWeight.w500,
        color: text, letterSpacing: -0.6,
      ),
      displayMedium: TextStyle(
        fontFamily: AppFonts.display,
        fontSize: 28, fontWeight: FontWeight.w500,
        color: text, letterSpacing: -0.5,
      ),
      displaySmall: TextStyle(
        fontFamily: AppFonts.display,
        fontSize: 24, fontWeight: FontWeight.w500,
        color: text, letterSpacing: -0.3,
      ),
      headlineSmall: TextStyle(
        fontFamily: AppFonts.display,
        fontSize: 18, fontWeight: FontWeight.w500,
        color: text, letterSpacing: -0.2,
      ),
      titleLarge: TextStyle(
        fontFamily: AppFonts.display,
        fontSize: 17, fontWeight: FontWeight.w600,
        color: text,
      ),
      titleMedium: TextStyle(
        fontFamily: AppFonts.ui,
        fontSize: 14, fontWeight: FontWeight.w600,
        color: text,
      ),
      titleSmall: TextStyle(
        fontFamily: AppFonts.ui,
        fontSize: 13, fontWeight: FontWeight.w500,
        color: text,
      ),
      bodyLarge: TextStyle(
        fontFamily: AppFonts.ui,
        fontSize: 15, fontWeight: FontWeight.w400,
        height: 1.65, color: text,
      ),
      bodyMedium: TextStyle(
        fontFamily: AppFonts.ui,
        fontSize: 13.5, fontWeight: FontWeight.w400,
        color: text,
      ),
      bodySmall: TextStyle(
        fontFamily: AppFonts.ui,
        fontSize: 12, fontWeight: FontWeight.w400,
        color: muted,
      ),
      labelLarge: TextStyle(
        fontFamily: AppFonts.ui,
        fontSize: 13, fontWeight: FontWeight.w600,
        color: text,
      ),
      labelMedium: TextStyle(
        fontFamily: AppFonts.ui,
        fontSize: 12, fontWeight: FontWeight.w500,
        color: muted,
      ),
      labelSmall: TextStyle(
        fontFamily: AppFonts.ui,
        fontSize: 11, fontWeight: FontWeight.w400,
        color: muted,
      ),
    );
  }
}
