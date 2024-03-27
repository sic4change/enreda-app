import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _lightFillColor = Colors.red;

  static final Color _lightFocusColor = Colors.black.withOpacity(0.12);

  static ThemeData lightThemeData =
  themeData(lightColorScheme, _lightFocusColor);

  static MaterialColor white = const MaterialColor(
    0xFFFFFFFF,
    const <int, Color>{
      50: const Color(0xFFFFFFFF),
      100: const Color(0xFFFFFFFF),
      200: const Color(0xFFFFFFFF),
      300: const Color(0xFFFFFFFF),
      400: const Color(0xFFFFFFFF),
      500: const Color(0xFFFFFFFF),
      600: const Color(0xFFFFFFFF),
      700: const Color(0xFFFFFFFF),
      800: const Color(0xFFFFFFFF),
      900: const Color(0xFFFFFFFF),
    },
  );

  static ThemeData themeData(ColorScheme colorScheme, Color focusColor) {
    return ThemeData(
      dialogTheme: DialogTheme().copyWith(surfaceTintColor: Colors.white,),
      primarySwatch: white,
      useMaterial3: true,
      textTheme: _textTheme,
      iconTheme: IconThemeData(color: AppColors.greyBorder),
      canvasColor: colorScheme.background,
      scaffoldBackgroundColor: colorScheme.background,
      highlightColor: Colors.transparent,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      focusColor: AppColors.primaryColor, colorScheme: colorScheme.copyWith(secondary: colorScheme.primary),
    );
  }

  static const ColorScheme lightColorScheme = ColorScheme(
    primary: AppColors.primaryColor,
    secondary: AppColors.primaryColor,
    background: Colors.white,
    surface: Color(0xFFFAFBFB),
    onBackground: AppColors.primaryColor,
    error: _lightFillColor,
    onError: _lightFillColor,
    onPrimary: Color(0xFF241E30),
    onSecondary: Color(0xFF322942),
    onSurface: Color(0xFF241E30),
    brightness: Brightness.light,
  );

  // static const _superBold = FontWeight.w900;
  static const _bold = FontWeight.w700;
  // static const _semiBold = FontWeight.w600;
  // static const _medium = FontWeight.w500;
  static const _regular = FontWeight.w400;
  static const _light = FontWeight.w300;

  static final TextTheme _textTheme = TextTheme(
    displayLarge: GoogleFonts.lato(
      fontSize: Sizes.TEXT_SIZE_96,
      color: AppColors.black,
      fontWeight: _bold,
      fontStyle: FontStyle.normal,
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: Sizes.TEXT_SIZE_60,
      color: AppColors.black,
      fontWeight: _bold,
      fontStyle: FontStyle.normal,
    ),
    displaySmall: GoogleFonts.inter(
      fontSize: Sizes.TEXT_SIZE_48,
      color: AppColors.black,
      fontWeight: _bold,
      fontStyle: FontStyle.normal,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: Sizes.TEXT_SIZE_34,
      color: AppColors.black,
      fontWeight: _bold,
      fontStyle: FontStyle.normal,
    ),
    headlineSmall: GoogleFonts.sora(
      fontSize: Sizes.TEXT_SIZE_34,
      color: AppColors.black,
      fontWeight: _bold,
      fontStyle: FontStyle.normal,
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: Sizes.TEXT_SIZE_20,
      color: AppColors.black,
      fontWeight: _bold,
      fontStyle: FontStyle.normal,
    ),
    titleMedium: GoogleFonts.outfit(
      fontSize: Sizes.TEXT_SIZE_18,
      color: AppColors.black,
      fontWeight: _bold,
      fontStyle: FontStyle.normal,
    ),
    titleSmall: GoogleFonts.ibmPlexMono(
      fontSize: Sizes.TEXT_SIZE_14,
      color: AppColors.black,
      fontWeight: _bold,
      fontStyle: FontStyle.normal,
    ),
    bodyLarge: GoogleFonts.outfit(
      fontSize: Sizes.TEXT_SIZE_18,
      fontWeight: FontWeight.w600,
      color: AppColors.primaryText2,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: Sizes.TEXT_SIZE_14,
      color: AppColors.black,
      fontStyle: FontStyle.normal,
    ),
    labelLarge: GoogleFonts.lato(
      fontSize: Sizes.TEXT_SIZE_16,
      color: AppColors.black,
      fontStyle: FontStyle.normal,
      fontWeight: _regular,
    ),
    bodySmall: GoogleFonts.lato(
      fontSize: Sizes.TEXT_SIZE_13,
      color: AppColors.greyAlt,
      fontWeight: _regular,
      fontStyle: FontStyle.normal,
    ),
  );
}