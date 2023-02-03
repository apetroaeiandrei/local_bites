import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:local/repos/notifications_repo.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._notificationsRepo)
      : super(const NotificationsState(
          notificationsEnabled: true,
          hasTopicPromo: true,
          showSettingsDialog: false,
        )) {
    init();
  }

  final NotificationsRepo _notificationsRepo;

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
    if (state.hasTopicPromo) {
      _notificationsRepo.unsubscribeFromTopic(NotificationsRepo.topicPromo);
    } else {
      _notificationsRepo.subscribeToTopic(NotificationsRepo.topicPromo);
    }
    emit(state.copyWith(hasTopicPromo: !state.hasTopicPromo));
  }

  Future<void> onWantNotificationsClick() async {
    final authorized = await _notificationsRepo.registerNotifications();
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
