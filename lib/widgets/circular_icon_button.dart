import 'package:flutter/material.dart';

class CircularIconButton extends StatelessWidget {
  const CircularIconButton({Key? key, required this.icon, required this.onTap}) : super(key: key);
  final IconData icon;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).iconTheme.color!.withOpacity(0.1),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Icon(icon),
      ),
    );
  }
}
