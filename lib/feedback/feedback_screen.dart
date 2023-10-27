import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local/feedback/feedback_cubit.dart';
import 'package:local/theme/dimens.dart';
import 'package:local/widgets/dialog_utils.dart';
import 'package:models/feedback_model.dart';

import '../generated/l10n.dart';
import '../theme/decorations.dart';
import '../theme/wl_colors.dart';
import '../widgets/button_loading.dart';
import 'feedback_tile.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _restaurantController = TextEditingController();
  final TextEditingController _courierController = TextEditingController();

  @override
  void dispose() {
    _restaurantController.dispose();
    _courierController.dispose();
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
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(
                            height: 16,
                          ),
                          Text(
                            S.of(context).feedback_restaurant_question(
                                state.userOrder.restaurantName),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          _getFeedbackButtons(
                              liked: state.restaurantFeedback,
                              onFeedback: (liked) {
                                context
                                    .read<FeedbackCubit>()
                                    .onRestaurantLiked(liked);
                              }),
                          TextField(
                            controller: _restaurantController,
                            decoration: InputDecoration(
                              border: outlineInputBorder(),
                              hintText:
                                  _getRestaurantHint(state.restaurantFeedback),
                              hintStyle: Theme.of(context).textTheme.bodySmall,
                            ),
                            maxLines: 4,
                          ),
                          const SizedBox(height: 40),
                          Text(
                            S.of(context).feedback_courier_question,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          _getFeedbackButtons(
                              liked: state.courierFeedback,
                              onFeedback: (liked) {
                                context
                                    .read<FeedbackCubit>()
                                    .onCourierLiked(liked);
                              }),
                          TextField(
                            controller: _courierController,
                            decoration: InputDecoration(
                              border: outlineInputBorder(),
                              hintText: _getCourierHint(state.courierFeedback,
                                  state.userOrder.courierName),
                              hintStyle: Theme.of(context).textTheme.bodySmall,
                            ),
                            maxLines: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      context.read<FeedbackCubit>().sendFeedback(
                          _restaurantController.text, _courierController.text);
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

  Widget _getFeedbackButtons(
      {required Function(bool) onFeedback, bool? liked}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () {
            onFeedback(false);
          },
          icon: Icon(
            false == liked ? Icons.thumb_down : Icons.thumb_down_alt_outlined,
            color: WlColors.error,
          ),
        ),
        IconButton(
          onPressed: () {
            onFeedback(true);
          },
          icon: Icon(
            true == liked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
            color: WlColors.notificationGreen,
          ),
        ),
      ],
    );
  }

  String _getRestaurantHint(bool? liked) {
    if (liked == null) {
      return S.of(context).feedback_comments_label;
    }
    return liked
        ? S.of(context).feedback_restaurant_hint_positive
        : S.of(context).feedback_restaurant_hint_negative;
  }

  String _getCourierHint(bool? liked, String courierName) {
    if (liked == null) {
      return S.of(context).feedback_comments_label;
    }
    final firstName = courierName.split(' ').first;
    return liked
        ? S.of(context).feedback_courier_hint_positive(firstName)
        : S.of(context).feedback_courier_hint_negative;
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
