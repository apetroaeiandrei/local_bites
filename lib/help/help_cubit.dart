import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';

import 'faq_item.dart';

part 'help_state.dart';

class HelpCubit extends Cubit<HelpState> {
  HelpCubit() : super(const HelpState(items: [])) {
    _init();
  }

  void _init() {
    rootBundle.loadString("lib/assets/json/faq.json").then((jsonStr) {
      final map = jsonDecode(jsonStr);
      final items = (map["faq"] as List)
          .map((e) => FaqItem.fromMap(e as Map<String, dynamic>))
          .toList();
      emit(state.copyWith(items: items));
    });
  }
}
