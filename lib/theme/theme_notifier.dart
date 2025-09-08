import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  bool _isDark;
  int _accentColor;

  ThemeNotifier({bool isDark = false, int accentColor = 0xFFE91E63})
      : _isDark = isDark,
        _accentColor = accentColor;

  bool get isDark => _isDark;
  int get accentColor => _accentColor;

  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  set isDark(bool v) {
    if (_isDark != v) {
      _isDark = v;
      notifyListeners();
    }
  }

  set accentColor(int v) {
    if (_accentColor != v) {
      _accentColor = v;
      notifyListeners();
    }
  }
}

/// Use this everywhere to build your dynamic ThemeData.
/// Removed fontSizeFactor completely.
ThemeData buildTheme({
  required bool isDark,
  required int accentColor,
}) {
  final color = Color(accentColor);
  final colorScheme = isDark
      ? ColorScheme.dark(primary: color, secondary: color)
      : ColorScheme.light(primary: color, secondary: color);

  final appBarFg = isDark ? Colors.white : Colors.black;
  final bodyFg = isDark ? Colors.white : Colors.black;

  final textTheme = isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;

  return ThemeData(
    brightness: isDark ? Brightness.dark : Brightness.light,
    colorScheme: colorScheme,
    primaryColor: color,
    scaffoldBackgroundColor: isDark ? const Color(0xFF121212) : null,
    appBarTheme: AppBarTheme(
      backgroundColor: isDark ? const Color(0xFF121212) : color,
      iconTheme: IconThemeData(color: appBarFg),
      titleTextStyle: TextStyle(
        color: appBarFg,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      toolbarTextStyle: TextStyle(
        color: appBarFg,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      elevation: 0,
    ),
    textTheme: textTheme,
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(color),
      trackColor: MaterialStateProperty.all(color.withOpacity(0.5)),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: color,
      thumbColor: color,
      overlayColor: color.withOpacity(0.15),
      inactiveTrackColor: isDark ? Colors.white24 : Colors.black12,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: color,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: color, width: 2),
      ),
      border: const OutlineInputBorder(),
      labelStyle: TextStyle(color: bodyFg),
      hintStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: color, width: 2),
        ),
        border: const OutlineInputBorder(),
      ),
    ),
  );
}
