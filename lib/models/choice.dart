class Choice {
  String id;
  String text;
  String question;

  Choice({
    required this.id,
    required this.text,
    required this.question,
  });

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      question: json['question'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'question': question,
    };
  }
}
