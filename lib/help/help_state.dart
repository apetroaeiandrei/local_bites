part of 'help_cubit.dart';

class HelpState extends Equatable {
  final List<FaqItem> items;

  @override
  List<Object> get props => [items];

  const HelpState({
    required this.items,
  });

  HelpState copyWith({
    List<FaqItem>? items,
  }) {
    return HelpState(
      items: items ?? this.items,
    );
  }
}
