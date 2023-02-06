import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';
import '../generated/l10n.dart';

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

showAppVersionDialog({required BuildContext context, required String message}) {
  final storeUrl =
      Platform.isIOS ? Constants.appStoreUrl : Constants.googlePlayUrl;
  showPlatformDialog(
      context: context,
      title: S.of(context).app_version_dialog_title,
      content: message,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            launchUrl(
              Uri.parse(storeUrl),
              mode: LaunchMode.externalApplication,
            );
          },
          child: Text(S.of(context).generic_ok),
        ),
      ]);
}
