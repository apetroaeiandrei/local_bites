import 'package:flutter/material.dart';

import '../generated/l10n.dart';
import '../theme/dimens.dart';

class HomeScreenCard extends StatelessWidget {
  const HomeScreenCard({
    Key? key,
    required this.name,
    required this.imageUrl,
    required this.open,
  }) : super(key: key);

  final String name;
  final String imageUrl;
  final bool open;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      constraints: const BoxConstraints(maxHeight: Dimens.homeCardHeight),
      child: Card(
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimens.cardCornerRadius)),
        elevation: Dimens.profileCardElevation,
        child: Container(
          color: Colors.white,
          child: Stack(
            fit: StackFit.expand,
            //crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
              Center(
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.headline1!.copyWith(
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 4
                          ..color = Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
              Center(
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.headline1!.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                ),
              ),
              Visibility(
                visible: !open,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black,
                      ],
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Text(
                        S.of(context).home_restaurant_closed,
                        style: Theme.of(context).textTheme.headline3!.copyWith(
                              color: Theme.of(context).colorScheme.surface,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
