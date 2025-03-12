import 'dart:convert';
import 'package:i_read_app/models/module.dart';
import 'package:i_read_app/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _modulesKey = 'modules';
  static const String _userProfileKey = 'userProfile';

  // Store modules as JSON string
  Future<void> storeModules(List<Module>? modules) async {
    final prefs = await SharedPreferences.getInstance();
    String modulesJson = jsonEncode(modules);
    await prefs.setString(_modulesKey, modulesJson);
  }

  // Retrieve stored modules
  Future<List<Module>> getModules() async {
    final prefs = await SharedPreferences.getInstance();
    String? modulesJson = prefs.getString(_modulesKey);
    if (modulesJson != null) {
      // Decode the JSON string into a List<dynamic>
      List<dynamic> decodedList = jsonDecode(modulesJson);

      // Convert the List<dynamic> into a List<Module>
      List<Module> modules = decodedList.map((moduleJson) => Module.fromJson(moduleJson)).toList();

      return modules;
    }
    return []; // Return an empty list if no modules are stored
  }

  // Store user profile as JSON string
  Future<void> storeUserProfile(UserProfile userProfile) async {
    final prefs = await SharedPreferences.getInstance();
    String userProfileJson = jsonEncode(userProfile.toJson());
    await prefs.setString(_userProfileKey, userProfileJson);
  }

  // Retrieve stored user profile
  Future<UserProfile?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String? userProfileJson = prefs.getString(_userProfileKey);
    if (userProfileJson != null) {
      return UserProfile.fromJson(jsonDecode(userProfileJson));
    }
    return null;
  }

  // Clear all stored data
  Future<void> clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
