part of 'feedback_cubit.dart';

enum FeedbackStatus {
  initial,
  sending,
  sent,
  error,
}

class FeedbackState extends Equatable {
  final bool isPositive;
  final FeedbackStatus status;
  final Set<FeedbackSuggestions> selectedSuggestions;

  @override
  List<Object> get props => [isPositive, status, selectedSuggestions];

  const FeedbackState({
    required this.isPositive,
    required this.status,
    required this.selectedSuggestions,
  });

  FeedbackState copyWith({
    bool? isPositive,
    FeedbackStatus? status,
    Set<FeedbackSuggestions>? selectedSuggestions,
  }) {
    return FeedbackState(
      isPositive: isPositive ?? this.isPositive,
      status: status ?? this.status,
      selectedSuggestions: selectedSuggestions ?? this.selectedSuggestions,
    );
  }
}
