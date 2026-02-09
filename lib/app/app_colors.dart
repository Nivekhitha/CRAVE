import 'package:flutter/material.dart';

class AppColors {
  // --- WARM CRAVE PALETTE (Light Mode) ---
  
  // Base Colors
  static const Color bg = Color(0xFFFAF7F2); // Main background (warm cream)
  static const Color card = Color(0xFFFFFFFF); // Card backgrounds
  static const Color accent = Color(0xFFD4654A); // Primary accent — buttons, highlights, hearts (warm terracotta/red)
  static const Color accentLight = Color(0xFFFFF0EC); // Light accent background tint
  static const Color text = Color(0xFF2C2417); // Primary text (deep warm brown)
  static const Color textSecondary = Color(0xFF8C8279); // Secondary text (muted brown)
  static const Color textMuted = Color(0xFFB5AEA6); // Placeholder/hint text
  static const Color warm = Color(0xFFF5E6D3); // Warm background fills (light tan)
  static const Color warmDark = Color(0xFFE8D5BF); // Warm border/separator
  
  // Semantic Accents
  static const Color teal = Color(0xFF5BA5A5); // Teal accent — hydration, secondary actions
  static const Color tealLight = Color(0xFFE8F5F5); // Light teal background tint
  static const Color gold = Color(0xFFD4A857); // Gold accent — stars, streaks, badges
  static const Color goldLight = Color(0xFFFDF6E8); // Light gold background tint
  static const Color sage = Color(0xFF7BA47B); // Green accent — grocery/pantry
  static const Color sageLight = Color(0xFFEDF5ED); // Light sage background tint
  
  // UI Elements
  static const Color border = Color.fromRGBO(0, 0, 0, 0.05); // Subtle card borders
  static const Color shadow = Color(0xFF2C2417); // Shadow color (same as text)

  // Gradients (Warm Crave)
  static const LinearGradient warmGradient = LinearGradient(
    colors: [accent, Color(0xFFE87A5D)], 
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // --- WARM CRAVE DARK PALETTE ---
  
  // Base Colors (Dark)
  static const Color bgDark = Color(0xFF1A1612); // Deep warm brown
  static const Color cardDark = Color(0xFF252017); // Slightly lighter than bg
  static const Color accentDark = Color(0xFFE07A60); // Slightly brighter terracotta
  static const Color accentLightDark = Color(0xFF3D2520); // Muted dark tint
  
  static const Color textDark = Color(0xFFF0EBE3); // Inverted — light cream
  static const Color textSecondaryDarkTheme = Color(0xFF9A9189); // Stays mid-tone
  static const Color textMutedDark = Color(0xFF5C5650); // Dimmer on dark
  
  static const Color warmDarkBg = Color(0xFF2E2720); // Dark warm fill
  static const Color warmBorderDark = Color(0xFF3A3128); // Dark warm border
  
  // Semantic Accents (Dark)
  static const Color tealDark = Color(0xFF6DB8B8); // Slightly brighter
  static const Color tealLightDark = Color(0xFF1E2E2E); // Dark teal tint
  static const Color goldDark = Color(0xFFE0B86A); // Slightly brighter
  static const Color goldLightDark = Color(0xFF2E2818); // Dark gold tint
  static const Color sageDark = Color(0xFF8DB88D); // Slightly brighter
  static const Color sageLightDark = Color(0xFF1E2E1E); // Dark sage tint

  static const Color borderDark = Color.fromRGBO(255, 255, 255, 0.08); // Subtle light border
  static const Color shadowDark = Color(0xFF000000); // Pure black shadow

  // Gradients (Warm Crave Dark)
  static const LinearGradient warmGradientDark = LinearGradient(
    colors: [accentDark, Color(0xFFD4654A)], 
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // --- CHEF'S TABLE PALETTE (Legacy/Reference) ---
  
  // Primary
  static const Color charcoal = Color(0xFF121212); // Deep Background
  static const Color flameAmber = Color(0xFFFF6B00); // Primary Action (Fire/Cooking)
  static const Color searGold = Color(0xFFFFD166); // Accents/Ratings

  // Functional
  static const Color surface = Color(0xFF1E1E1E); // Card Backgrounds
  static const Color surfaceLight = Color(0xFF2C2C2C); // lighter surface for layers
  static const Color textPrimary = Color(0xFFFAFAFA); // High Emphasis
  static const Color textSecondaryDark = Color(0xFFA0A0A0); // Medium Emphasis (renamed to avoid conflict)
  static const Color divider = Color(0xFF333333);

  // Status
  static const Color success = Color(0xFF00C853); // Fresh Basil Green
  static const Color error = Color(0xFFCF6679); // Muted Red
  static const Color warning = searGold;
  
  // Legacy Mapping (For backwards compatibility during refactor)
  static const Color primary = flameAmber;
  static const Color secondary = searGold;
  // static const Color accent = flameAmber; // Commented out to use new accent
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
  static const Color slate = textSecondaryDark;
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


  // Dynamic Theme-Aware Getters
  static Color getBg(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? bgDark : bg;
  
  static Color getCard(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? cardDark : card;
  
  static Color getAccent(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? accentDark : accent;
  
  static Color getAccentLight(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? accentLightDark : accentLight;
  
  static Color getText(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? textDark : text;
  
  static Color getTextSecondary(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? textSecondaryDarkTheme : textSecondary;
  
  static Color getTextMuted(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? textMutedDark : textMuted;
  
  static Color getWarm(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? warmDarkBg : warm;
  
  static Color getWarmDark(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? warmBorderDark : warmDark;
  
  static Color getTeal(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? tealDark : teal;
  
  static Color getTealLight(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? tealLightDark : tealLight;
  
  static Color getGold(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? goldDark : gold;
  
  static Color getGoldLight(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? goldLightDark : goldLight;
  
  static Color getSage(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? sageDark : sage;
  
  static Color getSageLight(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? sageLightDark : sageLight;
  
  static Color getBorder(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? borderDark : border;
  
  static Color getShadow(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? shadowDark : shadow;
}
