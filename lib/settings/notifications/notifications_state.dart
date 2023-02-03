part of 'notifications_cubit.dart';

class NotificationsState extends Equatable {
  final bool notificationsEnabled;
  final bool hasTopicPromo;
  final bool showSettingsDialog;

  @override
  List<Object> get props => [notificationsEnabled, hasTopicPromo, showSettingsDialog];

  const NotificationsState({
    required this.notificationsEnabled,
    required this.hasTopicPromo,
    required this.showSettingsDialog,
  });

  NotificationsState copyWith({
    bool? notificationsEnabled,
    bool? hasTopicPromo,
    bool? showSettingsDialog,
  }) {
    return NotificationsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      hasTopicPromo: hasTopicPromo ?? this.hasTopicPromo,
      showSettingsDialog: showSettingsDialog ?? this.showSettingsDialog,
    );
  }
}
