import 'package:i_read_app/models/materials.dart';
import 'package:i_read_app/models/question.dart';

class Module {
  String id;
  String title;
  String description;
  String difficulty;
  String category;
  String slug;
  String createdBy;
  DateTime createdAt;
  DateTime? updatedAt;
  List<Question> questionsPerModule;
  List<ModuleMaterial> materials;
  bool isLocked;
  int completed = 0;
  String fileUrl;
  Module({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.category,
    required this.slug,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    required this.questionsPerModule,
    required this.materials,
    required this.isLocked,
    required this.completed,
    required this.fileUrl,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      difficulty: json['difficulty'] ?? '',
      category: json['category'] ?? '',
      slug: json['slug'] ?? '',
      createdBy: json['created_by'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      questionsPerModule: (json['questions_per_module'] as List<dynamic>?)
              ?.map((q) => Question.fromJson(q))
              .toList() ??
          [],
      isLocked: json['isLock'] ?? false,
      completed: json['progress'] ?? 0,
      fileUrl: json['file_url'] ?? '',
      materials: (json['module_materials'] as List<dynamic>?)
              ?.map((m) => ModuleMaterial.fromJson(m))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'category': category,
      'slug': slug,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'questions_per_module': questionsPerModule.map((q) => q.toJson()).toList(),
      'isLock': isLocked,
      'completed': completed,
      'file_url': fileUrl,
      'materials': materials.map((m) => m.toJson()).toList(),
    };
  }
}
