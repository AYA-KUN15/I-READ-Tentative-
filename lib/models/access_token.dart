import 'dart:convert';

class AccessToken {
  final String accessToken;
  final String refreshToken;

  AccessToken({required this.accessToken, required this.refreshToken});

  factory AccessToken.fromJson(Map<String, dynamic> json) {
    return AccessToken(
      accessToken: json['access'],
      refreshToken: json['refresh'],
    );
  }

  String toJson() =>
      jsonEncode({'access': accessToken, 'refresh': refreshToken});
}
