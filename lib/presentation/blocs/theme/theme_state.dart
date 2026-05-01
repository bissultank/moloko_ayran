part of 'theme_bloc.dart';

class ThemeState extends Equatable {
  const ThemeState(this.mode);
  final ThemeMode mode;
  @override
  List<Object?> get props => [mode];
}
