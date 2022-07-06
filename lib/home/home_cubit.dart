import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:local/repos/user_repo.dart';

import 'home_status.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._userRepo)
      : super(const HomeState(status: HomeStatus.initial)) {
    _init();
  }

  final UserRepo _userRepo;

  _init() async {
    if (await _userRepo.isProfileCompleted()) {
      emit(state.copyWith(status: HomeStatus.completed));
    } else {
      emit(state.copyWith(status: HomeStatus.inCompleted));
    }
  }
}
