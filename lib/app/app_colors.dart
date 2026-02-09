import 'package:flutter/material.dart';

class AppColors {
  // --- CHEF'S TABLE PALETTE (Premium Dark) ---
  
  // Primary
  static const Color charcoal = Color(0xFF121212); // Deep Background
  static const Color flameAmber = Color(0xFFFF6B00); // Primary Action (Fire/Cooking)
  static const Color searGold = Color(0xFFFFD166); // Accents/Ratings

  // Functional
  static const Color surface = Color(0xFF1E1E1E); // Card Backgrounds
  static const Color surfaceLight = Color(0xFF2C2C2C); // lighter surface for layers
  static const Color textPrimary = Color(0xFFFAFAFA); // High Emphasis
  static const Color textSecondary = Color(0xFFA0A0A0); // Medium Emphasis
  static const Color divider = Color(0xFF333333);

  // Status
  static const Color success = Color(0xFF00C853); // Fresh Basil Green
  static const Color error = Color(0xFFCF6679); // Muted Red
  static const Color warning = searGold;
  
  // Legacy Mapping (For backwards compatibility during refactor)
  static const Color primary = flameAmber;
  static const Color secondary = searGold;
  static const Color accent = flameAmber;
  static const Color background = charcoal;
  static const Color onPrimary = Colors.white; // Text on primary button
  static const Color onSurface = textPrimary;
  
  // Old Palette Mappings (Deprecated but kept to prevent breakages)
  static const Color freshMint = flameAmber; 
  static const Color softLavender = surfaceLight;
  static const Color warmPeach = searGold;
  static const Color creamWhite = charcoal; // Map light bg to dark
  static const Color frostedBlue = surfaceLight;
  static const Color purpleX11 = searGold;
  static const Color slate = textSecondary;
  static const Color amberGlow = flameAmber;
  static const Color chartreuse = success;
  
  // Gradients
  static const LinearGradient magicHour = LinearGradient(
    colors: [flameAmber, Color(0xFFFF8E33)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumDark = LinearGradient(
    colors: [charcoal, Color(0xFF1A1A1A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // --- LEGACY COMPATIBILITY (Restored) ---
  static const Color primaryLight = flameAmber; // Map to new primary
  static const Color wash = surfaceLight;       // Map to new surface
  
  static const LinearGradient freshStart = magicHour; // Map to new gradient
  static const LinearGradient goldenHour = magicHour; // Map to new gradient
}
