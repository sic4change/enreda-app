import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Constants {
  // Name
  static String appName = "e-Learning";

  static Color white = Color(0xffffffff);

  // Material Design Color
  static Color lightPrimary = Color(0xfffcfcff);
  static Color lightAccent = Color(0xFFF18C8E);
  static Color lightBackground = Color(0xfffcfcff);

  static Color grey = Color(0xff707070);
  static Color textPrimary = Color(0xFF486581);
  static Color textDark = Color(0xFF305F72);

  // Salmon
  static Color salmonMain = Color(0xFFF18C8E);
  static Color salmonDark = Color(0xFFBB7F87);
  static Color salmonLight = Color(0xFFF19895);

  // Blue
  static Color blueMain = Color(0xFF579ACA);
  static Color blueDark = Color(0xFF4E92B1);
  static Color blueLight = Color(0xFF5AA6C8);

  // Pink
  static Color lightPink = Color(0xFFFAE4F4);

  // Yellow
  static Color lightYellow = Color(0xFFFFF5E5);

  // Violet
  static Color lightViolet = Color(0xFFFBF5FF);
  static Color alertRed = Color(0xFFD32F2F);
  static Color lightGreen = Color(0xFFD6FFED);

  static const Color lightTurquoise = Color(0xFFB5F0F0);
  static const Color onHoverTurquoise = Color(0xFFEFFDFA);
  static const Color turquoise = Color(0xFF00CCCC);
  static const Color skyBlue = Color(0xFF6699C6);
  static const Color lightGray = Color(0xFFD9D9D9);
  //static const Color gray = Color(0xFFD0CECE);
  static const Color darkGray = Color(0xFF535A5F);
  static const Color lightLilac = Color(0xFFF4F5FB);
  static const Color lilac = Color(0xFFA0A5D2);
  static const Color darkLilac = Color(0xFF6768AB);
  static const Color penLightBlue = Color(0xFF5776D1);
  static const Color penBlue = Color(0xFF002185);
  static const Color chatLightBlue = Color(0xFFE3EAFF);
  static const Color chatDarkBlue = Color(0xFF5876D2);
  static const Color chatDarkGray = Color(0xFF44494B);
  static const Color chatLightGray = Color(0xFFF1F3F4);
  static const Color chatButtonsGray = Color(0xFFA0A0A7);
  static const Color deleteRed = Color(0xFFAC0336);

  static ThemeData lighTheme(BuildContext context) {
    return ThemeData(
      backgroundColor: lightBackground,
      primaryColor: lightPrimary,
      accentColor: lightAccent,
      cursorColor: lightAccent,
      scaffoldBackgroundColor: lightBackground,
      textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme),
      appBarTheme: AppBarTheme(
        textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme),
        iconTheme: IconThemeData(
          color: lightAccent,
        ),
      ),
    );
  }

  static double headerHeight = 228.5;
  static double mainPadding = 20.0;
  static double sidebarWidth = 440.0;
}

enum BackgroundHeight {
  Small,
  Large,
  ExtraLarge
}
