part of 'feedback_cubit.dart';

enum FeedbackStatus {
  initial,
  sending,
  sent,
  error,
}

class FeedbackState extends Equatable {
  final bool? restaurantFeedback;
  final bool? courierFeedback;
  final FeedbackStatus status;
  final UserOrder userOrder;

  @override
  List<Object?> get props => [restaurantFeedback, courierFeedback, status];

  const FeedbackState({
    this.restaurantFeedback,
    this.courierFeedback,
    required this.status,
    required this.userOrder,
  });

  FeedbackState copyWith({
    bool? restaurantFeedback,
    bool? courierFeedback,
    FeedbackStatus? status,
    UserOrder? userOrder,
  }) {
    return FeedbackState(
      restaurantFeedback: restaurantFeedback ?? this.restaurantFeedback,
      courierFeedback: courierFeedback ?? this.courierFeedback,
      status: status ?? this.status,
      userOrder: userOrder ?? this.userOrder,
    );
  }
}
