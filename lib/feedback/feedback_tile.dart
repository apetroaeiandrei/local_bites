import 'package:flutter/material.dart';
import 'package:models/feedback_model.dart';

import '../generated/l10n.dart';

class FeedbackTile extends StatelessWidget {
  const FeedbackTile(
      {Key? key,
      required this.suggestion,
      required this.isSelected,
      required this.onTap})
      : super(key: key);
  final FeedbackSuggestions suggestion;
  final bool isSelected;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.secondary.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? theme.colorScheme.secondary : Colors.grey,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            _getSuggestionString(context),
            style: theme.textTheme.labelMedium,
          ),
        ),
      ),
    );
  }

  String _getSuggestionString(BuildContext context) {
    switch (suggestion) {
      case FeedbackSuggestions.food:
        return S.of(context).feedback_suggestion_food;
      case FeedbackSuggestions.packaging:
        return S.of(context).feedback_suggestion_packaging;
      case FeedbackSuggestions.delivery:
        return S.of(context).feedback_suggestion_delivery;
      case FeedbackSuggestions.app:
        return S.of(context).feedback_suggestion_app;
      case FeedbackSuggestions.time:
        return S.of(context).feedback_suggestion_time;
    }
  }
}
