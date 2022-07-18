part of 'settings_cubit.dart';


class SettingsState extends Equatable {
  final bool isLoggedIn;
  final String name;

  @override
  List<Object> get props => [isLoggedIn, name];

  const SettingsState({
    required this.isLoggedIn,
    required this.name,
  });

  SettingsState copyWith({
    bool? isLoggedIn,
    String? name,
  }) {
    return SettingsState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      name: name ?? this.name,
    );
  }
}
