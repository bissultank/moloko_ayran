// Слой: presentation | Назначение: ThemeBloc — переключение темы

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState(ThemeMode.system)) {
    on<ThemeLoad>(_onLoad);
    on<ThemeChange>(_onChange);
  }

  Future<void> _onLoad(ThemeLoad event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(AppConstants.kThemeKey);
    final mode = switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    emit(ThemeState(mode));
  }

  Future<void> _onChange(ThemeChange event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final value = switch (event.mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString(AppConstants.kThemeKey, value);
    emit(ThemeState(event.mode));
  }
}
