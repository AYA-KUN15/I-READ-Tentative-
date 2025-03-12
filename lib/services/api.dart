import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:i_read_app/constant.dart';
import 'package:i_read_app/models/access_token.dart';
import 'package:i_read_app/models/answer.dart';
import 'package:i_read_app/models/module.dart';
import 'package:i_read_app/models/question.dart';
import 'package:i_read_app/models/user.dart';

class ApiService {
  // Initialize secure storage
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

 Future<AccessToken?> postGenerateToken(String email, String password) async {
  try {
    // Request body
    Map<String, String> requestBody = {
      "email": email,
      "password": password,
    };

    // Request body
    Map<String, String> requestHeader = {
      "Content-Type": 'application/json',
    };

    var url = Uri.parse('${Constants.baseUrl}/api/token');
    var response = await http
        .post(url, headers: requestHeader, body: jsonEncode(requestBody))
        .timeout(const Duration(seconds: 10)); // Set timeout to 10 seconds

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      AccessToken accessToken = AccessToken.fromJson(data);

      // Store token securely
      await _secureStorage.write(
        key: 'accessToken',
        value: accessToken.accessToken,
      );

      return accessToken;
    } else {
      log('Failed to retrieve access token. Status code: ${response.statusCode}');
      throw 'Failed to retrieve access token. Status code: ${response.statusCode}';
    }
  } catch (e) {
    log(e.toString());
    throw e.toString();
  }
}
  Future<UserProfile?> getProfile() async {
    try {
      String? accessToken = await getStoredAccessToken();
      // Request body
      Map<String, String> requestHeader = {
        "Content-Type": 'application/json',
        "Authorization": 'Bearer $accessToken',
      };

      var url = Uri.parse('${Constants.baseUrl}/api/profile');
      var response = await http.get(url, headers: requestHeader);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        UserProfile userProfile = UserProfile.fromJson(data);
        return userProfile;
      } else {
        log('Failed to retrieve profile. Status code: ${response.statusCode}');
        throw 'Failed to retrieve profile. Status code: ${response.statusCode}';
      }
    } catch (e) {
      log(e.toString());
      throw e.toString();
    }
  }

  Future<List<Module>> getModules() async {
    try {
      String? accessToken = await getStoredAccessToken();
      // Request body
      Map<String, String> requestHeader = {
        "Content-Type": 'application/json',
        "Authorization": 'Bearer $accessToken',
      };

      var url = Uri.parse('${Constants.baseUrl}/api/modules');
      var response = await http.get(url, headers: requestHeader);

      if (response.statusCode == 200) {
        final data =
            jsonDecode(response.body) as List<dynamic>; // Decoding as a List
        List<Module> modules = data
            .map((moduleJson) => Module.fromJson(moduleJson))
            .toList(); // Mapping each item in the list to a Module
        return modules; // Return the list of modules
      } else {
        log('Failed to retrieve modules. Status code: ${response.statusCode}');
        throw 'Failed to retrieve modules. Status code: ${response.statusCode}';
      }
    } catch (e) {
      log(e.toString());
      throw e.toString();
    }
  }

  Future<List<Question>?> getModuleQuestions(String moduleId) async {
    try {
      String? accessToken = await getStoredAccessToken();
      // Request body
      Map<String, String> requestHeader = {
        "Content-Type": 'application/json',
        "Authorization": 'Bearer $accessToken',
      };

      var url =
          Uri.parse('${Constants.baseUrl}/api/modules/$moduleId/questions');
      var response = await http.get(url, headers: requestHeader);

      if (response.statusCode == 200) {
        final data =
            jsonDecode(response.body) as List<dynamic>; // Decoding as a List
        List<Question> questions = data
            .map((moduleJson) => Question.fromJson(moduleJson))
            .toList(); // Mapping each item in the list to a Module
        return questions; // Return the list of modules
      } else {
        log('Failed to retrieve questions. Status code: ${response.statusCode}');
        throw 'Failed to retrieve questions. Status code: ${response.statusCode}';
      }
    } catch (e) {
      log(e.toString());
      throw e.toString();
    }
  }

  Future<Map<String,dynamic>> getQuestionAnswer(String questionId) async {
    try {
      String? accessToken = await getStoredAccessToken();
      // Request body
      Map<String, String> requestHeader = {
        "Content-Type": 'application/json',
        "Authorization": 'Bearer $accessToken',
      };

      var url =
          Uri.parse('${Constants.baseUrl}/api/questions/$questionId');
      var response = await http.get(url, headers: requestHeader);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['answer'];
      } else {
        log('Failed to retrieve questions. Status code: ${response.statusCode}');
        throw 'Failed to retrieve questions. Status code: ${response.statusCode}';
      }
    } catch (e) {
      log(e.toString());
      throw e.toString();
    }
  }

  // Retrieve token from secure storage
  Future<String?> getStoredAccessToken() async {
    return await _secureStorage.read(key: 'accessToken');
  }

  // Delete token from secure storage
  Future<void> clearAccessToken() async {
    await _secureStorage.delete(key: 'accessToken');
  }

  Future<Map<String, dynamic>> postSubmitModuleAnswer(
      String moduleId, List<Answer> answers) async {
    try {
      // Request body
      Map<String, List<Answer>> requestBody = {
        "answers": answers,
      };

      String? accessToken = await getStoredAccessToken();

      // Request body
      Map<String, String> requestHeader = {
        "Content-Type": 'application/json',
        "Authorization": 'Bearer $accessToken',
      };

      var url = Uri.parse('${Constants.baseUrl}/api/modules/$moduleId/answer');
      var response = await http.post(url,
          headers: requestHeader, body: jsonEncode(requestBody));
      print(jsonDecode(response.body));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        log('Failed to submit module answer. Status code: ${response.statusCode}');
        throw 'Failed to submit module answer. Status code: ${response.statusCode}';
      }
    } catch (e) {
      log(e.toString());
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> postAssessPronunciation(String filePath, String referenceText, questionId) async {
    try {
      String? accessToken = await getStoredAccessToken();

      Map<String, String> requestHeader = {
        "Authorization": 'Bearer $accessToken',
        "Content-Type": "multipart/form-data",
      };

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Constants.baseUrl}/api/assess/pronounciation'),
      );

      request.headers.addAll(requestHeader);

      request.files.add(
        await http.MultipartFile.fromPath(
          'audio_file',
          filePath,
        ),
      );

      request.fields['reference_text'] = referenceText;
      request.fields['question_id'] = questionId;

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await http.Response.fromStream(response);
        log('File uploaded successfully: ${responseBody.body}');
         Map<String, dynamic> data = jsonDecode(responseBody.body);
        return data;
      } else {
        log('File upload failed with status: ${response.statusCode}');
        throw 'Failed to upload file. Status code: ${response.statusCode}';
      }
    } catch (e) {
      log('Error occurred: $e');
      throw e.toString();
    }
  }
}
