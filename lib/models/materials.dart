class ModuleMaterial {
  String id;
  DateTime createdAt;
  DateTime? updatedAt;
  String name;
  String path;
  String fileUrl;
  String slug;

  ModuleMaterial({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    required this.name,
    required this.path,
    required this.fileUrl,
    required this.slug,
  });

  factory ModuleMaterial.fromJson(Map<String, dynamic> json) {
    return ModuleMaterial(
      id: json['id'] ?? '',
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      name: json['name'] ?? '',
      path: json['path'] ?? '',
      fileUrl: json['file_url'] ?? '',
      slug: json['slug'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'name': name,
      'path': path,
      'file_url': fileUrl,
      'slug': slug,
    };
  }
}
