import 'package:flutter/material.dart';

class AnimeColors {
  // Sakura & Pastel Anime Palette
  static const Color sakuraPink = Color(0xFFFF5E86);
  static const Color sakuraLight = Color(0xFFFFEFF3);
  static const Color sakuraDark = Color(0xFFD6336C);
  static const Color sakuraSubtle = Color(0xFFFFF0F4);

  // Mystic & Cyber Accents
  static const Color animeViolet = Color(0xFF845EC2);
  static const Color animeLavender = Color(0xFFC7B1E6);
  static const Color electricCyan = Color(0xFF00C9A7);
  static const Color starlightGold = Color(0xFFFFC75F);
  static const Color sunsetCoral = Color(0xFFFF9671);
  static const Color flameCrimson = Color(0xFFFF4D6D);

  // Backgrounds & Surfaces
  static const Color bgLight = Color(0xFFFAF7FB);
  static const Color cardLight = Colors.white;
  static const Color textMainLight = Color(0xFF2A2035);
  static const Color textSubLight = Color(0xFF7D7289);

  // Dark Mode (Midnight Anime / Cyberpunk Night)
  static const Color bgDark = Color(0xFF13111C);
  static const Color cardDark = Color(0xFF1F1B2E);
  static const Color cardDarkSurface = Color(0xFF28233C);
  static const Color textMainDark = Color(0xFFF7F5FA);
  static const Color textSubDark = Color(0xFFA59EB5);

  // Rank Colors
  static const Color rankS = Color(0xFFFF3366); // S-Rank: Flaming Crimson
  static const Color rankA = Color(0xFFFF9E00); // A-Rank: Thunder Amber
  static const Color rankB = Color(0xFF00C49F); // B-Rank: Wind Emerald

  // Gradients
  static const LinearGradient sakuraGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF5E86), Color(0xFFFF8E72)],
  );

  static const LinearGradient mysticVioletGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF845EC2), Color(0xFFD65DB1), Color(0xFFFF6F91)],
  );

  static const LinearGradient celestialGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2C73D2), Color(0xFF0089BA), Color(0xFF00C9A7)],
  );

  static const LinearGradient rankSGradient = LinearGradient(
    colors: [Color(0xFFFF3366), Color(0xFFFF758C)],
  );

  static const LinearGradient rankAGradient = LinearGradient(
    colors: [Color(0xFFFF9E00), Color(0xFFFFD166)],
  );

  static const LinearGradient rankBGradient = LinearGradient(
    colors: [Color(0xFF00C49F), Color(0xFF48CAE4)],
  );

  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
      case 's':
      case 's-rank':
        return rankS;
      case 'medium':
      case 'a':
      case 'a-rank':
        return rankA;
      case 'low':
      case 'b':
      case 'b-rank':
        return rankB;
      default:
        return animeViolet;
    }
  }

  static String getRankLabel(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 'S-Rank 🔥';
      case 'medium':
        return 'A-Rank ⚡';
      case 'low':
        return 'B-Rank 🍃';
      default:
        return priority;
    }
  }

  static String getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'study':
        return '📚';
      case 'work':
        return '💼';
      case 'personal':
        return '🍜';
      case 'gaming':
        return '🎮';
      case 'general':
      default:
        return '🌸';
    }
  }
}

class AnimeTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AnimeColors.sakuraPink,
      scaffoldBackgroundColor: AnimeColors.bgLight,
      colorScheme: const ColorScheme.light(
        primary: AnimeColors.sakuraPink,
        onPrimary: Colors.white,
        secondary: AnimeColors.animeViolet,
        onSecondary: Colors.white,
        tertiary: AnimeColors.starlightGold,
        surface: AnimeColors.cardLight,
        onSurface: AnimeColors.textMainLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AnimeColors.textMainLight,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: AnimeColors.textMainLight),
      ),
      cardTheme: CardThemeData(
        color: AnimeColors.cardLight,
        elevation: 3,
        shadowColor: AnimeColors.sakuraPink.withAlpha(30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: AnimeColors.sakuraPink.withAlpha(35),
            width: 1.2,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AnimeColors.sakuraPink,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AnimeColors.sakuraPink.withAlpha(60)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AnimeColors.sakuraPink.withAlpha(50)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AnimeColors.sakuraPink, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AnimeColors.sakuraPink,
      scaffoldBackgroundColor: AnimeColors.bgDark,
      colorScheme: const ColorScheme.dark(
        primary: AnimeColors.sakuraPink,
        onPrimary: Colors.white,
        secondary: AnimeColors.animeLavender,
        onSecondary: Colors.white,
        tertiary: AnimeColors.starlightGold,
        surface: AnimeColors.cardDark,
        onSurface: AnimeColors.textMainDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AnimeColors.textMainDark,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: AnimeColors.textMainDark),
      ),
      cardTheme: CardThemeData(
        color: AnimeColors.cardDark,
        elevation: 4,
        shadowColor: Colors.black.withAlpha(120),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: AnimeColors.animeViolet.withAlpha(50),
            width: 1.2,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AnimeColors.sakuraPink,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AnimeColors.cardDarkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AnimeColors.animeViolet.withAlpha(70)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AnimeColors.animeViolet.withAlpha(60)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AnimeColors.sakuraPink, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }
}
