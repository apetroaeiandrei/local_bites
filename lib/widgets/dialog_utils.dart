import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

showPlatformDialog(
    {required BuildContext context,
    required String title,
    required String content,
    required List<Widget> actions}) {
  if (Platform.isIOS) {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: actions,
      ),
    );
  } else {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: actions,
      ),
    );
  }
}
