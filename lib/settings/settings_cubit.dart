import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:local/repos/auth_repo.dart';
import 'package:local/repos/user_repo.dart';

import '../repos/notifications_repo.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._authRepo, this._userRepo, this._notificationsRepo)
      : super(
            SettingsState(name: _userRepo.user?.name ?? "", isLoggedIn: true)) {
    _init();
  }

  final AuthRepo _authRepo;
  final UserRepo _userRepo;
  final NotificationsRepo _notificationsRepo;
  StreamSubscription? _userSubscription;

  _init() {
    _userSubscription = _userRepo.userStream.listen((user) {
      emit(state.copyWith(name: user.name));
    });
  }

  Future<void> logout() async {
    await _userRepo.onLogout();
    await _notificationsRepo.onLogout();
    _authRepo.logout();
    emit(state.copyWith(isLoggedIn: false));
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
