import 'package:i_read_app/models/choice.dart';

class Question {
  String id;
  String text;
  String questionType;
  String module;
  DateTime createdAt;
  DateTime? updatedAt;
  List<Choice> choices;

  Question({
    required this.id,
    required this.text,
    required this.questionType,
    required this.module,
    required this.createdAt,
    this.updatedAt,
    required this.choices,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? '', // Fallback to an empty string
      text: json['text'] ?? '',
      questionType: json['question_type'] ?? '',
      module: json['module'] ?? '',
      choices: (json['choices'] as List<dynamic>?)
              ?.map((c) => Choice.fromJson(c))
              .toList() ??
          [], // Fallback to an empty list
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(), // If null, use the current date-time
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null, // Handle null for updated_at
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'question_type': questionType,
      'module': module,
      'choices': choices.map((c) => c.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(), // updated_at can be null
    };
  }
}
