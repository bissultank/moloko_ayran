part of 'theme_bloc.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();
  @override
  List<Object?> get props => [];
}

class ThemeLoad extends ThemeEvent {
  const ThemeLoad();
}

class ThemeChange extends ThemeEvent {
  const ThemeChange(this.mode);
  final ThemeMode mode;
  @override
  List<Object?> get props => [mode];
}
