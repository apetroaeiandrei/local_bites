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
  ) : super(FeedbackState(
          status: FeedbackStatus.initial,
          userOrder: userOrder,
        ));

  final Analytics analytics;
  final UserRepo userRepo;
  final UserOrder userOrder;

  Future<void> sendFeedback(String restaurantText, String courierText) async {
    emit(state.copyWith(status: FeedbackStatus.sending));

    bool restaurantSuccess = true;
    bool courierSuccess = true;
    if (state.restaurantFeedback != null) {
      restaurantSuccess = await userRepo.sendRestaurantFeedback(
          userOrder, restaurantText, state.restaurantFeedback!, []);
      analytics.logEventWithParams(name: Metric.eventFeedbackSend, parameters: {
        Metric.propertyFeedbackIsPositive: state.restaurantFeedback!.toString(),
      });
    }
    if (state.courierFeedback != null) {
      courierSuccess = await userRepo.sendCourierFeedback(
          userOrder, courierText, state.courierFeedback!, []);
      analytics.logEventWithParams(name: Metric.eventFeedbackSend, parameters: {
        Metric.propertyFeedbackIsPositive: state.courierFeedback!.toString(),
      });
    }
    if (courierSuccess && restaurantSuccess) {
      emit(state.copyWith(status: FeedbackStatus.sent));
    } else {
      emit(state.copyWith(status: FeedbackStatus.error));
      Future.delayed(const Duration(milliseconds: 100), () {
        emit(state.copyWith(status: FeedbackStatus.initial));
      });
    }
  }

  void onRestaurantLiked(bool liked) {
    emit(state.copyWith(restaurantFeedback: liked));
  }

  void onCourierLiked(bool liked) {
    emit(state.copyWith(courierFeedback: liked));
  }
}
