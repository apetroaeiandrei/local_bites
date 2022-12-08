import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local/food_details/food_details_cubit.dart';
import 'package:local/theme/wl_colors.dart';
import 'package:models/food_option.dart';

import '../generated/l10n.dart';
import '../theme/dimens.dart';

class FoodDetailsScreen extends StatefulWidget {
  const FoodDetailsScreen({Key? key}) : super(key: key);

  @override
  State<FoodDetailsScreen> createState() => _FoodDetailsScreenState();
}

class _FoodDetailsScreenState extends State<FoodDetailsScreen> {
  final _headerKey = GlobalKey();
  final _scrollController = ScrollController();
  bool _titleVisible = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final headerPosition = _getHeaderPosition();
      if (headerPosition < 0) {
        if (!_titleVisible) {
          setState(() {
            _titleVisible = true;
          });
        }
      } else {
        if (_titleVisible) {
          setState(() {
            _titleVisible = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FoodDetailsCubit, FoodDetailsState>(
      listener: (context, state) {
        print(state.status);
        switch (state.status) {
          case FoodDetailsStatus.initial:
            break;
          case FoodDetailsStatus.loading:
            break;
          case FoodDetailsStatus.addSuccess:
            Navigator.of(context).pop();
            break;
          case FoodDetailsStatus.optionsError:
            _showInvalidOptionsSnackBar(context);
            break;
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    stretch: true,
                    expandedHeight: Dimens.sliverImageHeight,
                    leadingWidth: 45,
                    leading: Container(
                      margin: const EdgeInsets.only(left: 5),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    title: AnimatedOpacity(
                      opacity: _titleVisible ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        state.food.name,
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Image.network(
                        state.food.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        key: _headerKey,
                        padding: const EdgeInsets.only(
                            left: Dimens.defaultPadding,
                            top: Dimens.defaultPadding),
                        child: Text(
                          state.food.name,
                          style: Theme.of(context).textTheme.headline2,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: Dimens.defaultPadding,
                            top: Dimens.defaultPadding),
                        child: Text(
                          state.food.description,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: Dimens.defaultPadding,
                            top: Dimens.defaultPadding,
                            bottom: 12),
                        child: Text(
                          S.of(context).price_currency_ron(state.food.price),
                          style: Theme.of(context).textTheme.headline3,
                        ),
                      ),
                      ..._getOptions(state),
                      _getQuantityControls(state),
                      const SizedBox(
                        height: 70,
                      ),
                    ]),
                  ),
                ],
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                bottom: state.status == FoodDetailsStatus.loading
                    ? -50
                    : Dimens.defaultPadding,
                left: Dimens.defaultPadding,
                right: Dimens.defaultPadding,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<FoodDetailsCubit>().addFood();
                  },
                  child: Text(
                    S
                        .of(context)
                        .food_details_add_button(state.quantity, state.price),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Iterable<Widget> _getOptions(FoodDetailsState state) {
    return state.options.map(
      (e) => Padding(
        padding: const EdgeInsets.all(Dimens.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              e.name,
              style: Theme.of(context).textTheme.headline2,
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              S
                  .of(context)
                  .food_details_min_max(e.minSelection, e.maxSelection),
              style: Theme.of(context).textTheme.headline5?.copyWith(
                  color: state.invalidOptions.contains(e)
                      ? WlColors.error
                      : WlColors.secondary),
            ),
            ...e.options.map((option) => _buildOption(option, state)),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(FoodOption option, FoodDetailsState state) {
    final bool selected = state.selectedOptions.contains(option.id);
    return Row(
      children: [
        Text(
          option.name,
          style: Theme.of(context).textTheme.subtitle1,
        ),
        const SizedBox(
          width: 4,
        ),
        Text(S.of(context).food_option_price_extra(option.price),
            style: Theme.of(context).textTheme.subtitle2),
        const Spacer(),
        IconButton(
          icon: Icon(selected ? Icons.check_circle : Icons.add),
          onPressed: () {
            if (selected) {
              context.read<FoodDetailsCubit>().removeOption(option);
            } else {
              context.read<FoodDetailsCubit>().addOption(option);
            }
          },
        ),
      ],
    );
  }

  Widget _getQuantityControls(FoodDetailsState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: state.quantity == 1
              ? null
              : () {
                  context.read<FoodDetailsCubit>().decrementQuantity();
                },
        ),
        Text(
          state.quantity.toString(),
          style: Theme.of(context).textTheme.headline2,
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            context.read<FoodDetailsCubit>().incrementQuantity();
          },
        ),
      ],
    );
  }

  _showInvalidOptionsSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).food_details_invalid_options),
      ),
    );
  }

  double _getHeaderPosition() {
    final RenderBox renderBox =
        _headerKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    return position.dy - MediaQuery.of(context).padding.top - kToolbarHeight;
  }
}
