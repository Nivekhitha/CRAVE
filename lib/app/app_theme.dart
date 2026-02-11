import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Status Bar control
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  // --- WARM CRAVE (Light) ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.accent,        // Warm Terracotta
        onPrimary: Colors.white,
        secondary: AppColors.teal,        // Hydration/Action
        onSecondary: Colors.white,
        tertiary: AppColors.sage,         // Pantry/Ingredients
        onTertiary: Colors.white,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.bg,            // Warm Cream Background
        onSurface: AppColors.text,        // Deep Brown Text
        surfaceContainerLow: AppColors.card, // Card Background
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.warmDark,      // Separators
      ),

      scaffoldBackgroundColor: AppColors.bg,

      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.text),
        titleTextStyle: TextStyle(
          color: AppColors.text,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Playfair Display',
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark, // Dark icons for light bg
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.shadow.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          side: const BorderSide(color: AppColors.warmDark), // Warm border
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        prefixIconColor: AppColors.textSecondary,
        hintStyle: const TextStyle(color: AppColors.textMuted),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),

      // Typography overrides
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.text),
        displayMedium: AppTextStyles.displayMedium.copyWith(color: AppColors.text),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.text),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
      ),
    );
  }

  // --- WARM CRAVE (Dark) ---
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color Scheme
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.accentDark,       // Brighter Terracotta
        onPrimary: Colors.white,
        secondary: AppColors.tealDark,       // Brighter Teal
        onSecondary: Colors.black,
        tertiary: AppColors.sageDark,        // Brighter Sage
        onTertiary: Colors.black,
        error: AppColors.error,
        onError: Colors.black,
        surface: AppColors.bgDark,           // warmDarkBg was fill, bgDark is main bg
        onSurface: AppColors.textDark,       // Light Cream Text
        surfaceContainerLow: AppColors.cardDark, // Dark Card (Slightly lighter than bg)
        onSurfaceVariant: AppColors.textSecondaryDarkTheme,
        outline: AppColors.warmBorderDark,   // Dark Warm Border
      ),
      
      scaffoldBackgroundColor: AppColors.bgDark,
      
      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.textDark),
        titleTextStyle: TextStyle(
          color: AppColors.textDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Playfair Display', 
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light, // Light icons for dark bg
      ),
      
      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentDark,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentDark,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textDark,
          side: const BorderSide(color: AppColors.warmBorderDark),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.accentDark, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        prefixIconColor: AppColors.textSecondaryDarkTheme,
        hintStyle: const TextStyle(color: AppColors.textMutedDark),
        labelStyle: const TextStyle(color: AppColors.textSecondaryDarkTheme),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderDark, width: 1), 
        ),
        margin: EdgeInsets.zero,
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentDark,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      
      // Typography
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.textDark),
        displayMedium: AppTextStyles.displayMedium.copyWith(color: AppColors.textDark),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.textDark),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDarkTheme),
      ),
    );
  }
}
