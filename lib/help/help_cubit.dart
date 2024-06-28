import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';

import 'faq_item.dart';

part 'help_state.dart';

class HelpCubit extends Cubit<HelpState> {
  HelpCubit() : super(const HelpState(items: [])) {
    _init();
  }

  static const String defaultFaqPath = "lib/assets/json/faq.json";

  Future<void> _init() async {
    final languageCode = Platform.localeName.split("_")[0];
    final stringPath = "lib/assets/json/faq_$languageCode.json";
    String jsonStr = "";
    try {
      jsonStr = await rootBundle.loadString(stringPath);
    } catch (e) {
      jsonStr = await rootBundle.loadString(defaultFaqPath);
    }

    final map = jsonDecode(jsonStr);
    final items = (map["faq"] as List)
        .map((e) => FaqItem.fromMap(e as Map<String, dynamic>))
        .toList();
    emit(state.copyWith(items: items));
  }
}
