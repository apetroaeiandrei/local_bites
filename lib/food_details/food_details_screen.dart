import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local/food_details/food_details_cubit.dart';
import 'package:models/food_option.dart';

import '../generated/l10n.dart';
import '../theme/dimens.dart';

class FoodDetailsScreen extends StatefulWidget {
  const FoodDetailsScreen({Key? key}) : super(key: key);

  @override
  State<FoodDetailsScreen> createState() => _FoodDetailsScreenState();
}

class _FoodDetailsScreenState extends State<FoodDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FoodDetailsCubit, FoodDetailsState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: Dimens.sliverImageHeight,
                    title: Text(state.food.name),
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
                            bottom: 50),
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
              Positioned(
                bottom: Dimens.defaultPadding,
                left: Dimens.defaultPadding,
                right: Dimens.defaultPadding,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<FoodDetailsCubit>().addFood();
                    Navigator.of(context).pop();
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
    print(state.options);
    return state.options.map((e) => Padding(
          padding: const EdgeInsets.all(Dimens.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                e.name,
                style: Theme.of(context).textTheme.headline2,
              ),
              ...e.options.map((option) => _buildOption(option, state)),
            ],
          ),
        ));
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
}
