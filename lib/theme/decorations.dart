import 'package:flutter/material.dart';

OutlineInputBorder outlineInputBorder() => OutlineInputBorder(
      borderSide:
          const BorderSide(style: BorderStyle.solid, color: Colors.white),
      borderRadius: BorderRadius.circular(10),
    );

InputDecoration textFieldDecoration({required String label, String? error}) =>
    InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      labelText: label,
      errorText: error,
    );
