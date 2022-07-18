import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:local/repos/auth_repo.dart';
import 'package:local/repos/user_repo.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._authRepo, this._userRepo)
      : super(
            SettingsState(name: _userRepo.user?.name ?? "", isLoggedIn: true));

  final AuthRepo _authRepo;
  final UserRepo _userRepo;

  void logout() {
    _authRepo.logout();
    emit(state.copyWith(isLoggedIn: false));
  }
}
