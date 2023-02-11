import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:local/analytics/analytics.dart';
import 'package:local/analytics/metric.dart';
import 'package:local/repos/user_repo.dart';
import 'package:models/feedback_model.dart';
import 'package:models/user_order.dart';

part 'feedback_state.dart';

class FeedbackCubit extends Cubit<FeedbackState> {
  FeedbackCubit(
    this.analytics,
    this.userRepo,
    this.userOrder,
    this.isPositive,
  ) : super(FeedbackState(
          status: FeedbackStatus.initial,
          isPositive: isPositive,
          selectedSuggestions: const {},
        ));

  final Analytics analytics;
  final UserRepo userRepo;
  final UserOrder userOrder;
  final bool isPositive;

  Future<void> sendFeedback(String feedback) async {
    emit(state.copyWith(status: FeedbackStatus.sending));
    final success = await userRepo.sendFeedback(
        userOrder, feedback, isPositive, List.from(state.selectedSuggestions));
    analytics.logEventWithParams(name: Metric.eventFeedbackSend, parameters: {
      Metric.propertyFeedbackIsPositive: isPositive.toString(),
      Metric.propertyFeedbackAspects:
          state.selectedSuggestions.map((e) => e.toString()).join(','),
    });
    if (success) {
      emit(state.copyWith(status: FeedbackStatus.sent));
    } else {
      emit(state.copyWith(status: FeedbackStatus.error));
      Future.delayed(const Duration(milliseconds: 100), () {
        emit(state.copyWith(status: FeedbackStatus.initial));
      });
    }
  }

  void toggleSuggestion(FeedbackSuggestions e) {
    final current = Set<FeedbackSuggestions>.from(state.selectedSuggestions);
    if (current.contains(e)) {
      current.remove(e);
    } else {
      current.add(e);
    }
    emit(state.copyWith(selectedSuggestions: current));
  }
}
