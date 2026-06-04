import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Material 3 light/dark themes tuned for long editing sessions on mobile.
abstract final class AppTheme {
  static const Color _seed = Color(0xFF4F46E5);

  static ThemeData get light {
    final base = FlexThemeData.light(
      colors: const FlexSchemeColor(
        primary: _seed,
        primaryContainer: Color(0xFFE0E7FF),
        secondary: Color(0xFF0D9488),
        secondaryContainer: Color(0xFFCCFBF1),
        tertiary: Color(0xFF7C3AED),
        appBarColor: Color(0xFFF8FAFC),
        error: Color(0xFFDC2626),
      ),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 8,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 10,
        blendOnColors: false,
        useTextTheme: true,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        inputDecoratorIsFilled: true,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorFocusedBorderWidth: 2,
        fabUseShape: true,
        chipRadius: 12,
        popupMenuRadius: 12,
        cardRadius: 16,
        bottomSheetRadius: 20,
        navigationBarIndicatorOpacity: 0.20,
        navigationBarLabelBehavior:
            NavigationDestinationLabelBehavior.alwaysShow,
      ),
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
    );
    return _applyTypography(base);
  }

  static ThemeData get dark {
    final base = FlexThemeData.dark(
      colors: const FlexSchemeColor(
        primary: Color(0xFFA5B4FC),
        primaryContainer: Color(0xFF3730A3),
        secondary: Color(0xFF5EEAD4),
        secondaryContainer: Color(0xFF134E4A),
        tertiary: Color(0xFFC4B5FD),
        appBarColor: Color(0xFF0F172A),
        error: Color(0xFFF87171),
      ),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 12,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 16,
        useTextTheme: true,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        inputDecoratorIsFilled: true,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorFocusedBorderWidth: 2,
        fabUseShape: true,
        chipRadius: 12,
        popupMenuRadius: 12,
        cardRadius: 16,
        bottomSheetRadius: 20,
        navigationBarIndicatorOpacity: 0.24,
        navigationBarLabelBehavior:
            NavigationDestinationLabelBehavior.alwaysShow,
      ),
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
    );
    return _applyTypography(base);
  }

  static ThemeData applyEditorPreferences(
    ThemeData theme,
    EdgeInsets fieldBoxPadding,
  ) {
    return theme.copyWith(
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        contentPadding: fieldBoxPadding,
        isDense: false,
      ),
    );
  }

  static ThemeData _applyTypography(ThemeData theme) {
    final textTheme = GoogleFonts.interTextTheme(theme.textTheme);
    return theme.copyWith(
      textTheme: textTheme,
      primaryTextTheme: GoogleFonts.interTextTheme(theme.primaryTextTheme),
      appBarTheme: theme.appBarTheme.copyWith(
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: theme.cardTheme.copyWith(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      listTileTheme: theme.listTileTheme.copyWith(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      floatingActionButtonTheme: theme.floatingActionButtonTheme.copyWith(
        elevation: 2,
        highlightElevation: 4,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        showCloseIcon: true,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: theme.bottomSheetTheme.copyWith(
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      chipTheme: theme.chipTheme.copyWith(
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }
}
