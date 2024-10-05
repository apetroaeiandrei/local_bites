import 'package:cloud_firestore/cloud_firestore.dart';

enum FeedbackSuggestions { food, packaging, delivery, app, time }

extension FeedbackSuggestionsHelper on FeedbackSuggestions {
  String toSimpleString() => toString().split(".")[1];

  static FeedbackSuggestions fromString(String string) =>
      FeedbackSuggestions.values
          .firstWhere((e) => e.toSimpleString() == string);
}

class FeedbackModel {
  final String id;
  final String userName;
  final String userPhone;
  final String orderId;
  final String comment;
  final DateTime orderDate;
  final bool seen;
  final bool isPositive;
  final List<FeedbackSuggestions> suggestions;

  static _suggestionsFromJson(Map<String, dynamic> json) {
    final List<dynamic> suggestions = json['suggestions'];
    return suggestions
        .map((e) => FeedbackSuggestionsHelper.fromString(e))
        .toList();
  }

  static List<String> _suggestionsToJson(
      List<FeedbackSuggestions> suggestions) {
    return suggestions.map((e) => e.toSimpleString()).toList();
  }

//<editor-fold desc="Data Methods">
  const FeedbackModel({
    required this.id,
    required this.userName,
    required this.userPhone,
    required this.orderId,
    required this.comment,
    required this.orderDate,
    required this.seen,
    required this.isPositive,
    required this.suggestions,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedbackModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userName == other.userName &&
          userPhone == other.userPhone &&
          orderId == other.orderId &&
          comment == other.comment &&
          orderDate == other.orderDate &&
          seen == other.seen &&
          isPositive == other.isPositive &&
          suggestions == other.suggestions);

  @override
  int get hashCode =>
      id.hashCode ^
      userName.hashCode ^
      userPhone.hashCode ^
      orderId.hashCode ^
      comment.hashCode ^
      orderDate.hashCode ^
      seen.hashCode ^
      isPositive.hashCode ^
      suggestions.hashCode;

  @override
  String toString() {
    return 'FeedbackModel{' +
        ' id: $id,' +
        ' userName: $userName,' +
        ' userPhone: $userPhone,' +
        ' orderId: $orderId,' +
        ' comment: $comment,' +
        ' orderDate: $orderDate,' +
        ' seen: $seen,' +
        ' isPositive: $isPositive,' +
        ' suggestions: $suggestions,' +
        '}';
  }

  FeedbackModel copyWith({
    String? id,
    String? userName,
    String? userPhone,
    String? orderId,
    String? comment,
    DateTime? orderDate,
    bool? seen,
    bool? isPositive,
    List<FeedbackSuggestions>? suggestions,
  }) {
    return FeedbackModel(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      orderId: orderId ?? this.orderId,
      comment: comment ?? this.comment,
      orderDate: orderDate ?? this.orderDate,
      seen: seen ?? this.seen,
      isPositive: isPositive ?? this.isPositive,
      suggestions: suggestions ?? this.suggestions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userName': userName,
      'userPhone': userPhone,
      'orderId': orderId,
      'comment': comment,
      'orderDate': orderDate,
      'seen': seen,
      'isPositive': isPositive,
      'suggestions': _suggestionsToJson(suggestions),
    };
  }

  factory FeedbackModel.fromMap(Map<String, dynamic> map) {
    return FeedbackModel(
      id: map['id'] as String,
      userName: map['userName'] as String,
      userPhone: map['userPhone'] as String,
      orderId: map['orderId'] as String,
      comment: map['comment'] as String,
      orderDate: (map['orderDate'] as Timestamp).toDate(),
      seen: map['seen'] as bool,
      isPositive: map['isPositive'] as bool,
      suggestions: _suggestionsFromJson(map),
    );
  }

//</editor-fold>
}
