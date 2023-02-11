import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local/feedback/feedback_cubit.dart';
import 'package:local/theme/dimens.dart';
import 'package:local/widgets/dialog_utils.dart';
import 'package:models/feedback_model.dart';

import '../generated/l10n.dart';
import '../theme/decorations.dart';
import '../widgets/button_loading.dart';
import 'feedback_tile.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FeedbackCubit, FeedbackState>(
      listener: (context, state) {
        switch (state.status) {
          case FeedbackStatus.initial:
          case FeedbackStatus.sending:
            break;
          case FeedbackStatus.sent:
            Navigator.of(context).pop();
            break;
          case FeedbackStatus.error:
            _showErrorDialog();
            break;
        }
      },
      builder: (context, state) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            appBar: AppBar(
              title: Text(S.of(context).feedback_title),
            ),
            body: Padding(
              padding: const EdgeInsets.all(Dimens.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    state.isPositive
                        ? S.of(context).feedback_headline_positive
                        : S.of(context).feedback_headline_negative,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: Dimens.defaultPadding),
                  Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: FeedbackSuggestions.values
                          .map((e) => FeedbackTile(
                                suggestion: e,
                                isSelected:
                                    state.selectedSuggestions.contains(e),
                                onTap: () {
                                  context
                                      .read<FeedbackCubit>()
                                      .toggleSuggestion(e);
                                },
                              ))
                          .toList()),
                  const SizedBox(height: Dimens.defaultPadding),
                  TextField(
                    controller: _textController,
                    decoration: textFieldDecoration(
                        label: S.of(context).feedback_comments_label),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 10),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<FeedbackCubit>()
                          .sendFeedback(_textController.text);
                    },
                    child: state.status == FeedbackStatus.sending
                        ? const ButtonLoading()
                        : Text(S.of(context).feedback_send),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog() {
    showPlatformDialog(
        context: context,
        title: S.of(context).generic_error_title,
        content: S.of(context).generic_error_content,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(S.of(context).generic_ok),
          ),
        ]);
  }
}
