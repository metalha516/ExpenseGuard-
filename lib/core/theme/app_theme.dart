import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Theme extension for the signature "Pastel Flat" color ramps and tokens.
@immutable
class AppPastelColors extends ThemeExtension<AppPastelColors> {
  const AppPastelColors({
    required this.mint,
    required this.mintDim,
    required this.lavender,
    required this.lavenderDim,
    required this.peach,
    required this.peachDim,
    required this.skyBlue,
    required this.skyBlueDim,
    required this.borderDark,
    required this.cardSurface,
    required this.cardSurfaceAlt,
    required this.tagBackground,
    required this.borderWidth,
    required this.primarySage,
    required this.secondaryPlum,
  });

  /// Mint pastel accent (#B5EAD7) - primary container, approved status, active items
  final Color mint;
  final Color mintDim;

  /// Lavender pastel accent (#E2CCF0) - secondary container, category tags
  final Color lavender;
  final Color lavenderDim;

  /// Peach pastel accent (#FFDAC1) - pending status, alerts, warm highlights
  final Color peach;
  final Color peachDim;

  /// Sky Blue pastel accent (#C7CEEA) - info tags, scan receipt actions
  final Color skyBlue;
  final Color skyBlueDim;

  /// Signature high-contrast outline border stroke (#1A1C1E)
  final Color borderDark;

  /// Surface background for cards
  final Color cardSurface;

  /// Secondary surface background
  final Color cardSurfaceAlt;

  /// Background for tags/chips
  final Color tagBackground;

  /// Standard border stroke thickness
  final double borderWidth;

  /// Deep Sage Green (#366758)
  final Color primarySage;

  /// Muted Slate Plum (#695876)
  final Color secondaryPlum;

  /// Light theme preset for Pastel Flat
  static const AppPastelColors light = AppPastelColors(
    mint: Color(0xFFB5EAD7),
    mintDim: Color(0x33B5EAD7),
    lavender: Color(0xFFE2CCF0),
    lavenderDim: Color(0x33E2CCF0),
    peach: Color(0xFFFFDAC1),
    peachDim: Color(0x33FFDAC1),
    skyBlue: Color(0xFFC7CEEA),
    skyBlueDim: Color(0x33C7CEEA),
    borderDark: Color(0xFF1A1C1E),
    cardSurface: Color(0xFFFFFFFF),
    cardSurfaceAlt: Color(0xFFF3F4F5),
    tagBackground: Color(0xFFEDEEEF),
    borderWidth: 1.5,
    primarySage: Color(0xFF366758),
    secondaryPlum: Color(0xFF695876),
  );

  /// Dark theme preset for Pastel Flat
  static const AppPastelColors dark = AppPastelColors(
    mint: Color(0xFFB5EAD7),
    mintDim: Color(0x2EB5EAD7),
    lavender: Color(0xFFE2CCF0),
    lavenderDim: Color(0x2EE2CCF0),
    peach: Color(0xFFFFDAC1),
    peachDim: Color(0x2EFFDAC1),
    skyBlue: Color(0xFFC7CEEA),
    skyBlueDim: Color(0x2EC7CEEA),
    borderDark: Color(0xFF1A1C1E),
    cardSurface: Color(0xFF2D2E37),
    cardSurfaceAlt: Color(0xFF24252D),
    tagBackground: Color(0xFF3A3B46),
    borderWidth: 1.5,
    primarySage: Color(0xFFB5EAD7),
    secondaryPlum: Color(0xFFE2CCF0),
  );

  @override
  AppPastelColors copyWith({
    Color? mint,
    Color? mintDim,
    Color? lavender,
    Color? lavenderDim,
    Color? peach,
    Color? peachDim,
    Color? skyBlue,
    Color? skyBlueDim,
    Color? borderDark,
    Color? cardSurface,
    Color? cardSurfaceAlt,
    Color? tagBackground,
    double? borderWidth,
    Color? primarySage,
    Color? secondaryPlum,
  }) {
    return AppPastelColors(
      mint: mint ?? this.mint,
      mintDim: mintDim ?? this.mintDim,
      lavender: lavender ?? this.lavender,
      lavenderDim: lavenderDim ?? this.lavenderDim,
      peach: peach ?? this.peach,
      peachDim: peachDim ?? this.peachDim,
      skyBlue: skyBlue ?? this.skyBlue,
      skyBlueDim: skyBlueDim ?? this.skyBlueDim,
      borderDark: borderDark ?? this.borderDark,
      cardSurface: cardSurface ?? this.cardSurface,
      cardSurfaceAlt: cardSurfaceAlt ?? this.cardSurfaceAlt,
      tagBackground: tagBackground ?? this.tagBackground,
      borderWidth: borderWidth ?? this.borderWidth,
      primarySage: primarySage ?? this.primarySage,
      secondaryPlum: secondaryPlum ?? this.secondaryPlum,
    );
  }

  @override
  AppPastelColors lerp(ThemeExtension<AppPastelColors>? other, double t) {
    if (other is! AppPastelColors) return this;
    return AppPastelColors(
      mint: Color.lerp(mint, other.mint, t)!,
      mintDim: Color.lerp(mintDim, other.mintDim, t)!,
      lavender: Color.lerp(lavender, other.lavender, t)!,
      lavenderDim: Color.lerp(lavenderDim, other.lavenderDim, t)!,
      peach: Color.lerp(peach, other.peach, t)!,
      peachDim: Color.lerp(peachDim, other.peachDim, t)!,
      skyBlue: Color.lerp(skyBlue, other.skyBlue, t)!,
      skyBlueDim: Color.lerp(skyBlueDim, other.skyBlueDim, t)!,
      borderDark: Color.lerp(borderDark, other.borderDark, t)!,
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t)!,
      cardSurfaceAlt: Color.lerp(cardSurfaceAlt, other.cardSurfaceAlt, t)!,
      tagBackground: Color.lerp(tagBackground, other.tagBackground, t)!,
      borderWidth: lerpDouble(borderWidth, other.borderWidth, t)!,
      primarySage: Color.lerp(primarySage, other.primarySage, t)!,
      secondaryPlum: Color.lerp(secondaryPlum, other.secondaryPlum, t)!,
    );
  }
}

/// The overarching Pastel Flat design system for ExpenseGuard.
class AppTheme {
  AppTheme._();

  // Spacing & Border constants
  static const double marginMobile = 20.0;
  static const double gutterMobile = 12.0;
  static const double stackGap = 16.0;
  static const double cardRadius = 16.0;
  static const double buttonRadius = 12.0;
  static const double chipRadius = 999.0;
  static const double touchTarget = 44.0;
  static const double borderWidth = 1.5;

  /// Builds the Inter typography hierarchy conforming to Stitch design specifications.
  static TextTheme _buildTextTheme({
    required Color primaryText,
    required Color secondaryText,
  }) {
    return TextTheme(
      // display-currency: 40px, w800, line-height 48px, tabular figures
      displayLarge: GoogleFonts.inter(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        height: 48 / 40,
        letterSpacing: -1.2,
        color: primaryText,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      // headline-lg: 28px, w700, line-height 34px
      headlineLarge: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 34 / 28,
        letterSpacing: -0.56,
        color: primaryText,
      ),
      // headline-md: 20px, w700, line-height 26px
      headlineMedium: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 26 / 20,
        letterSpacing: -0.2,
        color: primaryText,
      ),
      // title-large: 20px, w600
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 26 / 20,
        color: primaryText,
      ),
      // title-medium / body-lg bold: 17px, w600
      titleMedium: GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 24 / 17,
        color: primaryText,
      ),
      // body-lg: 17px, w400, line-height 24px
      bodyLarge: GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        height: 24 / 17,
        color: primaryText,
      ),
      // body-md: 15px, w400, line-height 22px
      bodyMedium: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 22 / 15,
        color: secondaryText,
      ),
      // label-md: 13px, w600, line-height 18px, letter-spacing 0.02em
      labelMedium: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 18 / 13,
        letterSpacing: 0.26,
        color: primaryText,
      ),
      // metadata: 12px, w500, line-height 16px
      labelSmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        color: secondaryText,
      ),
    );
  }

  /// Light theme based on "Pastel Flat" design tokens.
  static ThemeData get lightTheme {
    const primaryColor = Color(0xFF366758);
    const darkBorder = Color(0xFF1A1C1E);
    const lightBg = Color(0xFFF8F9FA);
    const onSurface = Color(0xFF191C1D);
    const onSurfaceVariant = Color(0xFF404945);

    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: primaryColor,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFB5EAD7), // mint
      onPrimaryContainer: const Color(0xFF396B5C),
      secondary: const Color(0xFF695876), // muted plum
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFF1DAFF), // lavender container
      onSecondaryContainer: const Color(0xFF6F5E7D),
      tertiary: const Color(0xFF745945),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFFDD8BF), // peach container
      onTertiaryContainer: const Color(0xFF785D49),
      error: const Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: const Color(0xFFFFDAD6),
      onErrorContainer: const Color(0xFF93000A),
      surface: lightBg,
      onSurface: onSurface,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: const Color(0xFFF3F4F5),
      surfaceContainer: const Color(0xFFEDEEEF),
      surfaceContainerHigh: const Color(0xFFE7E8E9),
      surfaceContainerHighest: const Color(0xFFE1E3E4),
      onSurfaceVariant: onSurfaceVariant,
      outline: const Color(0xFF707975),
      outlineVariant: const Color(0xFFC0C9C4),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(
        primaryText: onSurface,
        secondaryText: onSurfaceVariant,
      ),
      extensions: const [AppPastelColors.light],
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: onSurface),
        titleTextStyle: TextStyle(
          color: primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: const BorderSide(color: darkBorder, width: borderWidth),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, touchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
            side: const BorderSide(color: darkBorder, width: borderWidth),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurface,
          minimumSize: const Size(double.infinity, touchTarget),
          side: const BorderSide(color: darkBorder, width: borderWidth),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
          borderSide: const BorderSide(color: darkBorder, width: borderWidth),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
          borderSide: const BorderSide(color: darkBorder, width: borderWidth),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
          borderSide: const BorderSide(color: primaryColor, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
          borderSide: const BorderSide(color: Color(0xFFBA1A1A), width: borderWidth),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFEDEEEF),
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(chipRadius),
          side: const BorderSide(color: darkBorder, width: 1.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1.0,
      ),
    );
  }

  /// Dark theme based on "Pastel Flat" design tokens.
  static ThemeData get darkTheme {
    const darkBg = Color(0xFF2D2E37);
    const darkCardBg = Color(0xFF2D2E37);
    const darkBorder = Color(0xFF1A1C1E);
    const mintAccent = Color(0xFFB5EAD7);
    const onSurface = Colors.white;
    const onSurfaceVariant = Color(0xFFC0C9C4);

    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: mintAccent,
      onPrimary: const Color(0xFF1A1C1E),
      primaryContainer: const Color(0xFF366758),
      onPrimaryContainer: mintAccent,
      secondary: const Color(0xFFE2CCF0),
      onSecondary: const Color(0xFF231530),
      secondaryContainer: const Color(0xFF403649),
      onSecondaryContainer: const Color(0xFFE2CCF0),
      tertiary: const Color(0xFFFFDAC1),
      onTertiary: const Color(0xFF2A1708),
      tertiaryContainer: const Color(0xFF5A422F),
      onTertiaryContainer: const Color(0xFFFFDAC1),
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690005),
      errorContainer: const Color(0xFF93000A),
      onErrorContainer: const Color(0xFFFFDAD6),
      surface: darkBg,
      onSurface: onSurface,
      surfaceContainerLowest: const Color(0xFF24252D),
      surfaceContainerLow: const Color(0xFF282932),
      surfaceContainer: darkBg,
      surfaceContainerHigh: const Color(0xFF353744),
      surfaceContainerHighest: const Color(0xFF3E4050),
      onSurfaceVariant: onSurfaceVariant,
      outline: const Color(0xFF707975),
      outlineVariant: darkBorder,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(
        primaryText: onSurface,
        secondaryText: onSurfaceVariant,
      ),
      extensions: const [AppPastelColors.dark],
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: onSurface),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCardBg,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: const BorderSide(color: darkBorder, width: borderWidth),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: mintAccent,
          foregroundColor: const Color(0xFF1A1C1E),
          minimumSize: const Size(double.infinity, touchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
            side: const BorderSide(color: darkBorder, width: borderWidth),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, touchTarget),
          side: const BorderSide(color: darkBorder, width: borderWidth),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF24252D),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
          borderSide: const BorderSide(color: darkBorder, width: borderWidth),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
          borderSide: const BorderSide(color: darkBorder, width: borderWidth),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
          borderSide: const BorderSide(color: mintAccent, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
          borderSide: const BorderSide(color: Color(0xFFFFB4AB), width: borderWidth),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF353744),
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(chipRadius),
          side: const BorderSide(color: darkBorder, width: 1.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1.0,
      ),
    );
  }
}

/// Convenience extensions for accessing Pastel Flat tokens from BuildContext.
extension AppThemeContextExtension on BuildContext {
  AppPastelColors get pastelColors =>
      Theme.of(this).extension<AppPastelColors>() ?? AppPastelColors.light;

  TextStyle get displayCurrency => Theme.of(this).textTheme.displayLarge!;
  TextStyle get metadataText => Theme.of(this).textTheme.labelSmall!;
  TextStyle get headlineLg => Theme.of(this).textTheme.headlineLarge!;
  TextStyle get headlineMd => Theme.of(this).textTheme.headlineMedium!;
  TextStyle get bodyLg => Theme.of(this).textTheme.bodyLarge!;
  TextStyle get bodyLarge => Theme.of(this).textTheme.bodyLarge!;
  TextStyle get bodyMd => Theme.of(this).textTheme.bodyMedium!;
  TextStyle get bodyMedium => Theme.of(this).textTheme.bodyMedium!;
  TextStyle get labelMd => Theme.of(this).textTheme.labelMedium!;
}
