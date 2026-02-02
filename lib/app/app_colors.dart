import 'package:flutter/material.dart';

class AppColors {
  // New User Palette
  static const Color frostedBlue = Color(0xFF8DE4FF);
  static const Color bubblegumPink = Color(0xFFF7567C);
  static const Color amberGlow = Color(0xFFFF9F1C);
  static const Color chartreuse = Color(0xFFBCED09);
  static const Color purpleX11 = Color(0xFF8447FF);

  // Backgrounds
  static const Color creamWhite = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color wash = Color(0xFFF5F6FA);
  
  // Text
  static const Color charcoal = Color(0xFF2D3436);
  static const Color slate = Color(0xFF636E72);

  // Semantic mappings
  static const Color freshMint = frostedBlue; // Mapping old name to new color for safety
  static const Color softLavender = purpleX11;
  static const Color warmPeach = bubblegumPink;
  
  static const Color primary = frostedBlue;
  static const Color secondary = purpleX11;
  static const Color accent = bubblegumPink;
  static const Color warn = amberGlow;
  static const Color success = chartreuse;

  static const Color error = Color(0xFFFF6B6B);

  // Gradients
  static const LinearGradient magicHour = LinearGradient(
    colors: [bubblegumPink, amberGlow],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient freshStart = LinearGradient(
    colors: [frostedBlue, purpleX11],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldenHour = LinearGradient(
    colors: [amberGlow, chartreuse],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Legacy mappings
  static const Color primaryDark = Color(0xFF3AAFA9); 
  static const Color primaryLight = frostedBlue; 
  static const Color background = creamWhite;
  static const Color textPrimary = charcoal;
  static const Color textSecondary = slate;
  static const Color onPrimary = charcoal; // Light blue needs dark text
  static const Color onSecondary = surface;
  static const Color onSurface = charcoal;
  static const Color onBackground = charcoal;
  static const Color onError = surface;
}
