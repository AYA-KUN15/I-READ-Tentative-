class Answer {
  String questionId;
  String answer;
  bool correct;

  Answer({required this.questionId, required this.answer, this.correct = false});

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      questionId: json['question_id'] ?? '',
      answer: json['answer'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'answer': answer,
      'correct': correct,
    };
  }
}
