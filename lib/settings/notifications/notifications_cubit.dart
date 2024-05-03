import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:local/repos/notifications_repo.dart';
import 'package:local/repos/user_repo.dart';

import '../../constants.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._notificationsRepo, this._userRepo)
      : super(const NotificationsState(
          notificationsEnabled: true,
          hasTopicPromo: true,
          showSettingsDialog: false,
        )) {
    init();
  }

  final NotificationsRepo _notificationsRepo;
  final UserRepo _userRepo;

  init() async {
    final notificationsEnabled =
        await _notificationsRepo.areNotificationsEnabled();
    final hasTopicPromo = await _notificationsRepo.hasTopicPromo();
    emit(state.copyWith(
      notificationsEnabled: notificationsEnabled,
      hasTopicPromo: hasTopicPromo,
    ));
  }

  void toggleTopicPromo() {
    final zip = _userRepo.user?.zipCode ?? Constants.unknownZipCode;
    if (state.hasTopicPromo) {
      _notificationsRepo
          .unsubscribeFromTopic(NotificationsRepo.topicPromoZip(zip));
    } else {
      _notificationsRepo.subscribeToTopic(NotificationsRepo.topicPromoZip(zip));
    }
    emit(state.copyWith(hasTopicPromo: !state.hasTopicPromo));
  }

  Future<void> onWantNotificationsClick() async {
    final zip = _userRepo.user?.zipCode ?? Constants.unknownZipCode;
    final authorized = await _notificationsRepo.registerNotifications(zip);
    if (authorized) {
      init();
    } else {
      emit(state.copyWith(showSettingsDialog: true));
      Future.delayed(const Duration(milliseconds: 20), () {
        emit(state.copyWith(showSettingsDialog: false));
      });
    }
  }

  void onAppLifecycleStateChanged(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      init();
    }
  }
}
