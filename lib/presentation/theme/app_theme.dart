import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const kMedphePrimary = Color(0xFF1D2EEC);
const kMedpheSecondary = Color(0xFF6C1DEC);
const kMedpheSurface = Color(0xFFF1EEFB);

/// Paleta rotativa para íconos de categoría/especialidad — evita que todo
/// se vea monocromático azul.
const kCategoryPalette = [
  kMedphePrimary,
  kMedpheSecondary,
  Color(0xFF12A594),
  Color(0xFFF2994A),
];

ThemeData buildMedpheTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: kMedphePrimary,
    brightness: Brightness.light,
  ).copyWith(secondary: kMedpheSecondary);

  final textTheme = GoogleFonts.poppinsTextTheme();

  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    fontFamily: GoogleFonts.poppins().fontFamily,
    textTheme: textTheme,
    scaffoldBackgroundColor: kMedpheSurface,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black87,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: kMedphePrimary.withValues(alpha: 0.08),
      labelStyle: const TextStyle(
        color: kMedphePrimary,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kMedphePrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kMedphePrimary, width: 1.5),
      ),
    ),
  );
}
