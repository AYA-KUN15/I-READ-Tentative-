
class UserProfile {
  String id;
  String username;
  String email;
  String firstName;
  String lastName;
  String middleName;
  bool isStaff;
  bool isActive;
  int experience;
  int rank;
  List<CompletedModule> completedModules;
  String section;
  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.isStaff,
    required this.isActive,
    required this.experience,
    required this.rank,
    required this.completedModules,
    this.section = '',
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      middleName: json['middle_name'] ?? '',
      isStaff: json['is_staff'],
      isActive: json['is_active'],
      experience: json['experience'],
      rank: json['rank'],
      completedModules: (json['completed_modules'] as List)
          .map((module) => CompletedModule.fromJson(module))
          .toList(),
      section: json['section'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "username": username,
      "email": email,
      "first_name": firstName,
      "last_name": lastName,
      "middle_name": middleName,
      "is_staff": isStaff,
      "is_active": isActive,
      "experience": experience,
      "rank": rank,
      "completed_modules":
          completedModules.map((module) => module.toJson()).toList(),
      "section": section,
    };
  }
}

class CompletedModule {
  String moduleTitle;
  int pointsEarned;

  CompletedModule({
    required this.moduleTitle,
    required this.pointsEarned,
  });

  factory CompletedModule.fromJson(Map<String, dynamic> json) {
    return CompletedModule(
      moduleTitle: json['module_title'],
      pointsEarned: json['points_earned'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "module_title": moduleTitle,
      "points_earned": pointsEarned,
    };
  }
}
