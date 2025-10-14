enum AppThemeMode { system, light, dark }

abstract class ThemeEvent {}

class ChangeTheme extends ThemeEvent {
  final AppThemeMode newMode;
  ChangeTheme(this.newMode);
}
