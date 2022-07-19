import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local/home/home_cubit.dart';

import '../generated/l10n.dart';
import '../routes.dart';
import '../theme/dimens.dart';
import '../widgets/home_screen_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (BuildContext context, HomeState state) {
        switch (state.status) {
          case HomeStatus.profileIncomplete:
            Navigator.of(context).pushNamed(Routes.profile);
            break;
          case HomeStatus.initial:
            break;
          case HomeStatus.loaded:
            break;
          case HomeStatus.loading:
            // TODO: Handle this case.
            break;
          case HomeStatus.restaurantsError:
            // TODO: Handle this case.
            break;
          case HomeStatus.error:
            // TODO: Handle this case.
            break;
        }
      },
      builder: (BuildContext context, HomeState state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).home_welcome),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.settings);
                },
              ),
            ],
          ),
          body: ListView.builder(
              itemCount: state.restaurants.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _getAddressZone(context, state);
                } else {
                  return _getRestaurantCard(context, state, index - 1);
                }
              }),
        );
      },
    );
  }

  Widget _getAddressZone(BuildContext context, HomeState state) {
    return Padding(
      padding: const EdgeInsets.all(Dimens.defaultPadding),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context)
              .pushNamed(Routes.address)
              .then((value) => context.read<HomeCubit>().init());
        },
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.address ?? S.of(context).home_address_empty,
                style: Theme.of(context).textTheme.headline5,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const Icon(Icons.keyboard_arrow_down),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getRestaurantCard(BuildContext context, HomeState state, int i) {
    final restaurant = state.restaurants[i];
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed(Routes.restaurant, arguments: restaurant);
      },
      child: HomeScreenCard(
        imageUrl: restaurant.imageUrl,
        name: restaurant.name,
      ),
    );
  }
}
