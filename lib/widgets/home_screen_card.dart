import 'package:flutter/material.dart';

import '../theme/dimens.dart';

class HomeScreenCard extends StatelessWidget {
  const HomeScreenCard({
    Key? key,
    required this.name,
    required this.imageUrl,
  }) : super(key: key);

  final String name;
  final String imageUrl;

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
            ],
          ),
        ),
      ),
    );
  }
}
