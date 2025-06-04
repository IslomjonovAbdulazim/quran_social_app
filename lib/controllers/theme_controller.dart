import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static ThemeController get instance => Get.find<ThemeController>();

  // Private reactive variables
  final RxBool _isDarkMode = false.obs;
  final RxDouble _fontScale = 1.0.obs;
  final RxString _fontFamily = 'UthmaniHafs'.obs;
  final RxBool _useSystemTheme = true.obs;
  final RxInt _primaryColorIndex = 0.obs;

  // Getters
  bool get isDarkMode => _isDarkMode.value;
  double get fontScale => _fontScale.value;
  String get fontFamily => _fontFamily.value;
  bool get useSystemTheme => _useSystemTheme.value;
  int get primaryColorIndex => _primaryColorIndex.value;

  // Get current theme mode
  ThemeMode get themeMode {
    if (_useSystemTheme.value) {
      return ThemeMode.system;
    }
    return _isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
  }

  // Available font families for Arabic text
  final List<String> availableFonts = [
    'UthmaniHafs',
    'QCF_SurahHeader',
    'SurahName',
    'Roboto', // Fallback for non-Arabic text
  ];

  // Available primary colors
  final List<Color> availableColors = [
    const Color(0xFF2E7D32), // Green (default Islamic color)
    const Color(0xFF1976D2), // Blue
    const Color(0xFF7B1FA2), // Purple
    const Color(0xFFD32F2F), // Red
    const Color(0xFFF57C00), // Orange
    const Color(0xFF388E3C), // Dark Green
    const Color(0xFF5D4037), // Brown
    const Color(0xFF455A64), // Blue Grey
  ];

  late SharedPreferences _prefs;

  @override
  void onInit() {
    super.onInit();
    _loadThemeSettings();
  }

  /// Load theme settings from storage
  Future<void> _loadThemeSettings() async {
    try {
      _prefs = await SharedPreferences.getInstance();

      // Load dark mode preference
      _isDarkMode.value = _prefs.getBool('dark_mode') ?? false;

      // Load system theme preference
      _useSystemTheme.value = _prefs.getBool('use_system_theme') ?? true;

      // Load font scale
      _fontScale.value = _prefs.getDouble('font_scale') ?? 1.0;

      // Load font family
      _fontFamily.value = _prefs.getString('font_family') ?? 'UthmaniHafs';

      // Load primary color index
      _primaryColorIndex.value = _prefs.getInt('primary_color_index') ?? 0;

      // If using system theme, detect current system brightness
      if (_useSystemTheme.value) {
        _detectSystemTheme();
      }

    } catch (e) {
      print('Error loading theme settings: $e');
    }
  }

  /// Detect system theme and update accordingly
  void _detectSystemTheme() {
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    _isDarkMode.value = brightness == Brightness.dark;
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    try {
      _isDarkMode.value = !_isDarkMode.value;
      _useSystemTheme.value = false; // Disable system theme when manually toggling

      await _prefs.setBool('dark_mode', _isDarkMode.value);
      await _prefs.setBool('use_system_theme', false);

      // Update GetX theme
      Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);

      _showThemeChangedSnackbar();
    } catch (e) {
      print('Error toggling theme: $e');
    }
  }

  /// Enable or disable system theme following
  Future<void> setUseSystemTheme(bool useSystem) async {
    try {
      _useSystemTheme.value = useSystem;
      await _prefs.setBool('use_system_theme', useSystem);

      if (useSystem) {
        _detectSystemTheme();
        Get.changeThemeMode(ThemeMode.system);
      } else {
        Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
      }

      _showThemeChangedSnackbar();
    } catch (e) {
      print('Error setting system theme: $e');
    }
  }

  /// Change font scale for accessibility
  Future<void> setFontScale(double scale) async {
    try {
      // Clamp font scale between reasonable limits
      scale = scale.clamp(0.8, 2.0);

      _fontScale.value = scale;
      await _prefs.setDouble('font_scale', scale);

      // Force rebuild to apply new font scale
      Get.forceAppUpdate();

      Get.snackbar(
        'Font Size Changed',
        'Text size has been updated',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Error setting font scale: $e');
    }
  }

  /// Change font family
  Future<void> setFontFamily(String fontFamily) async {
    try {
      if (availableFonts.contains(fontFamily)) {
        _fontFamily.value = fontFamily;
        await _prefs.setString('font_family', fontFamily);

        // Force rebuild to apply new font
        Get.forceAppUpdate();

        Get.snackbar(
          'Font Changed',
          'Font family has been updated to $fontFamily',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      print('Error setting font family: $e');
    }
  }

  /// Change primary color
  Future<void> setPrimaryColor(int colorIndex) async {
    try {
      if (colorIndex >= 0 && colorIndex < availableColors.length) {
        _primaryColorIndex.value = colorIndex;
        await _prefs.setInt('primary_color_index', colorIndex);

        // Force rebuild to apply new color
        Get.forceAppUpdate();

        Get.snackbar(
          'Color Changed',
          'App color theme has been updated',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      print('Error setting primary color: $e');
    }
  }

  /// Get current primary color
  Color get currentPrimaryColor {
    if (_primaryColorIndex.value >= 0 && _primaryColorIndex.value < availableColors.length) {
      return availableColors[_primaryColorIndex.value];
    }
    return availableColors[0]; // Default to first color
  }

  /// Reset theme settings to defaults
  Future<void> resetToDefaults() async {
    try {
      _isDarkMode.value = false;
      _useSystemTheme.value = true;
      _fontScale.value = 1.0;
      _fontFamily.value = 'UthmaniHafs';
      _primaryColorIndex.value = 0;

      // Save to preferences
      await _prefs.setBool('dark_mode', false);
      await _prefs.setBool('use_system_theme', true);
      await _prefs.setDouble('font_scale', 1.0);
      await _prefs.setString('font_family', 'UthmaniHafs');
      await _prefs.setInt('primary_color_index', 0);

      // Apply system theme
      Get.changeThemeMode(ThemeMode.system);

      // Force rebuild
      Get.forceAppUpdate();

      Get.snackbar(
        'Settings Reset',
        'Theme settings have been reset to defaults',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Error resetting theme settings: $e');
    }
  }

  /// Show theme changed snackbar
  void _showThemeChangedSnackbar() {
    final String modeText = _isDarkMode.value ? 'Dark' : 'Light';
    Get.snackbar(
      'Theme Changed',
      'Switched to $modeText mode',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  /// Get text style with current font settings
  TextStyle getTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    bool useArabicFont = true,
  }) {
    return TextStyle(
      fontSize: (fontSize ?? 16) * _fontScale.value,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color,
      fontFamily: useArabicFont ? _fontFamily.value : 'Roboto',
    );
  }

  /// Get Arabic text style specifically for Quran text
  TextStyle getQuranTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: (fontSize ?? 24) * _fontScale.value,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color,
      fontFamily: _fontFamily.value,
      letterSpacing: letterSpacing ?? 1.2,
      height: height ?? 1.8,
    );
  }

  /// Get theme data based on current settings
  ThemeData get currentThemeData {
    final primaryColor = currentPrimaryColor;
    final brightness = _isDarkMode.value ? Brightness.dark : Brightness.light;

    if (_isDarkMode.value) {
      return ThemeData.dark().copyWith(
        // primarySwatch: _createMaterialColor(primaryColor),
        primaryColor: primaryColor,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        textTheme: _buildTextTheme(brightness),
      );
    } else {
      return ThemeData.light().copyWith(
        // primarySwatch: _createMaterialColor(primaryColor),
        primaryColor: primaryColor,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        textTheme: _buildTextTheme(brightness),
      );
    }
  }

  /// Create MaterialColor from Color
  MaterialColor _createMaterialColor(Color color) {
    final strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }

    for (final strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }

    return MaterialColor(color.value, swatch);
  }

  /// Build text theme with current font settings
  TextTheme _buildTextTheme(Brightness brightness) {
    final baseColor = brightness == Brightness.dark ? Colors.white : Colors.black;

    return TextTheme(
      displayLarge: getTextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: baseColor),
      displayMedium: getTextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: baseColor),
      displaySmall: getTextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: baseColor),
      headlineLarge: getTextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: baseColor),
      headlineMedium: getTextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: baseColor),
      headlineSmall: getTextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: baseColor),
      titleLarge: getTextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: baseColor),
      titleMedium: getTextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: baseColor),
      titleSmall: getTextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: baseColor),
      bodyLarge: getTextStyle(fontSize: 16, color: baseColor),
      bodyMedium: getTextStyle(fontSize: 14, color: baseColor),
      bodySmall: getTextStyle(fontSize: 12, color: baseColor),
      labelLarge: getTextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: baseColor),
      labelMedium: getTextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: baseColor),
      labelSmall: getTextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: baseColor),
    );
  }

  @override
  void onClose() {
    // Clean up if needed
    super.onClose();
  }
}