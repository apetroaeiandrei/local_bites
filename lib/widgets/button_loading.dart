import 'package:flutter/material.dart';

class ButtonLoading extends StatelessWidget {
  const ButtonLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        color: Colors.white,
        strokeWidth: 2,
      ),
    );
  }
}
