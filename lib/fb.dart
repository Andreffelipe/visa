import 'dart:convert';
import 'package:http/http.dart' as http;

import 'engine/simple-auth.dart';
import 'engine/visa.dart';
import 'auth-data.dart';
import 'engine/oauth.dart';

class FaceBookAuth implements Visa{
  final baseUrl = 'https://www.facebook.com/v8.0/dialog/oauth';
  SimpleAuth visa;

  FaceBookAuth(){
    var baseProfileUrl = 'https://graph.facebook.com/me';

    visa = SimpleAuth(
        baseUrl: baseUrl,
        getAuthData: (Map <String, String> data) async {
          final String token = data[OAuth.TOKEN_KEY];
          final String profileUrl = '$baseProfileUrl'
              '?access_token=$token'
              '&fields=first_name,last_name,email';

          var profileResponse = await http.get(profileUrl);
          var profileJson = Map<String, dynamic>.from(
              json.decode(profileResponse.body)
          );

          return authData(profileJson, data);
        }
    );
  }

  @override
  AuthData authData(
      Map<String, dynamic> json,
      Map<String, String>data
      ){
    final String accessToken = data[OAuth.TOKEN_KEY];
    final String profileImgUrl = 'https://graph.facebook.com/me/picture'
        '?type=large'
        '&access_token=$accessToken';

    return AuthData(
        clientID: data['clientID'],
        accessToken: accessToken,
        userID: json['id'] as String,
        firstName: json['first_name'] as String,
        lastName: json['last_name'] as String,
        email: json['email'] as String,
        profileImgUrl: profileImgUrl,
        response: data,
        userJson: json
    );
  }
}
