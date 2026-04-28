import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();
  @override
  List<Object?> get props => [];
}

class LoadThemeEvent extends ThemeEvent {}

class ChangeThemeModeEvent extends ThemeEvent {
  final ThemeMode themeMode;
  const ChangeThemeModeEvent(this.themeMode);
  @override
  List<Object?> get props => [themeMode];
}

class ChangePrimaryColorEvent extends ThemeEvent {
  final Color color;
  const ChangePrimaryColorEvent(this.color);
  @override
  List<Object?> get props => [color];
}

class ChangeFontScaleEvent extends ThemeEvent {
  final double scale;
  const ChangeFontScaleEvent(this.scale);
  @override
  List<Object?> get props => [scale];
}

// State
class ThemeState extends Equatable {
  final ThemeMode themeMode;
  final Color primaryColor;
  final double fontScale;

  const ThemeState({
    required this.themeMode,
    required this.primaryColor,
    required this.fontScale,
  });

  @override
  List<Object?> get props => [themeMode, primaryColor, fontScale];

  ThemeState copyWith({
    ThemeMode? themeMode,
    Color? primaryColor,
    double? fontScale,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
      fontScale: fontScale ?? this.fontScale,
    );
  }
}

// Bloc
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themeKey = 'theme_preference';
  static const String _colorKey = 'primary_color_preference';
  static const String _fontKey = 'font_scale_preference';

  ThemeBloc() : super(const ThemeState(
    themeMode: ThemeMode.system,
    primaryColor: Color(0xFF2563EB), // Default Blue
    fontScale: 1.0,
  )) {
    on<LoadThemeEvent>(_onLoadTheme);
    on<ChangeThemeModeEvent>(_onChangeThemeMode);
    on<ChangePrimaryColorEvent>(_onChangePrimaryColor);
    on<ChangeFontScaleEvent>(_onChangeFontScale);
  }

  Future<void> _onLoadTheme(LoadThemeEvent event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? ThemeMode.system.index;
    final colorValue = prefs.getInt(_colorKey) ?? const Color(0xFF2563EB).value;
    final fontScale = prefs.getDouble(_fontKey) ?? 1.0;

    emit(ThemeState(
      themeMode: ThemeMode.values[themeIndex],
      primaryColor: Color(colorValue),
      fontScale: fontScale,
    ));
  }

  Future<void> _onChangeThemeMode(ChangeThemeModeEvent event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, event.themeMode.index);
    emit(state.copyWith(themeMode: event.themeMode));
  }

  Future<void> _onChangePrimaryColor(ChangePrimaryColorEvent event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_colorKey, event.color.value);
    emit(state.copyWith(primaryColor: event.color));
  }

  Future<void> _onChangeFontScale(ChangeFontScaleEvent event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontKey, event.scale);
    emit(state.copyWith(fontScale: event.scale));
  }
}
