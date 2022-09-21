import 'package:flutter/material.dart';

import '../generated/l10n.dart';
import '../theme/dimens.dart';

class MentionsScreen extends StatefulWidget {
  const MentionsScreen({Key? key}) : super(key: key);

  @override
  State<MentionsScreen> createState() => _MentionsScreenState();
}

class _MentionsScreenState extends State<MentionsScreen> {
  final _textController = TextEditingController();

  @override
  void didChangeDependencies() {
    final args = ModalRoute
        .of(context)
        ?.settings
        .arguments as String?;
    _textController.text = args ?? "";
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S
            .of(context)
            .mentions_title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(Dimens.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              S
                  .of(context)
                  .mentions_headline,
              style: Theme
                  .of(context)
                  .textTheme
                  .headline3,
            ),
            const SizedBox(height: Dimens.space_16),
            Expanded(
              child: TextField(
                controller: _textController,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: S
                      .of(context)
                      .mentions_placeholder,
                  hintMaxLines: 10,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(3.0),
                    ),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                  const EdgeInsets.only(right: 50, left: 10, top: 10),
                  fillColor: Colors.black.withOpacity(0.04),
                  filled: true,
                ),
                maxLines: null,
                expands: true,
              ),
            ),
            const SizedBox(height: Dimens.space_30),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(_textController.text);
              },
              child: Text(S
                  .of(context)
                  .mentions_save),
            ),
            const SafeArea(
              child: SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
