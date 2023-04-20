class FaqItem {
  final String question;
  final String answer;

//<editor-fold desc="Data Methods">
  const FaqItem({
    required this.question,
    required this.answer,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FaqItem &&
          runtimeType == other.runtimeType &&
          question == other.question &&
          answer == other.answer);

  @override
  int get hashCode => question.hashCode ^ answer.hashCode;

  @override
  String toString() {
    return 'FaqItem{ question: $question, answer: $answer,}';
  }

  FaqItem copyWith({
    String? question,
    String? answer,
  }) {
    return FaqItem(
      question: question ?? this.question,
      answer: answer ?? this.answer,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'answer': answer,
    };
  }

  factory FaqItem.fromMap(Map<String, dynamic> map) {
    return FaqItem(
      question: map['question'] as String,
      answer: map['answer'] as String,
    );
  }

//</editor-fold>
}
