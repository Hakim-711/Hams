import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState(ThemeMode.system)) {
    on<ChangeTheme>((event, emit) {
      switch (event.newMode) {
        case AppThemeMode.system:
          emit(const ThemeState(ThemeMode.system));
          break;
        case AppThemeMode.light:
          emit(const ThemeState(ThemeMode.light));
          break;
        case AppThemeMode.dark:
          emit(const ThemeState(ThemeMode.dark));
          break;
      }
    });
  }
}
