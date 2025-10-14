import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ThemeState {
  final ThemeMode mode;
  const ThemeState(this.mode);

  ThemeData get themeData {
    switch (mode) {
      case ThemeMode.light:
        return AppTheme.lightTheme;
      case ThemeMode.dark:
        return AppTheme.darkTheme;
      case ThemeMode.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark
            ? AppTheme.darkTheme
            : AppTheme.lightTheme;
    }
  }
}
