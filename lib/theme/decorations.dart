import 'package:flutter/material.dart';
import 'package:local/theme/wl_colors.dart';

BoxDecoration backgroundDecoration = const BoxDecoration(
    gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [WlColors.backgroundStart, WlColors.backgroundEnd]));

OutlineInputBorder outlineInputBorder() => OutlineInputBorder(
      borderSide:
          const BorderSide(style: BorderStyle.solid, color: Colors.white),
      borderRadius: BorderRadius.circular(10),
    );

InputDecoration textFieldDecoration(String hintText) => InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(90.0),
      ),
      filled: true,
      fillColor: Colors.white70,
      hintText: hintText,
    );
