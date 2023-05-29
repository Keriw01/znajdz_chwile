import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../api_connection/api_connection.dart';
import '../models/tag.dart';
import '../models/user.dart';
import '../users/userPreferences/user_preferences.dart';

loadTagsFromDatabase(List<Tag> tags, String errorMessage) async {
  try {
    Future<User?> userInfo = RememberUserPrefs.readUserInfo();
    User? currentUserInfo = await userInfo;

    var response = await http.post(Uri.parse(API.tagsList), body: {
      'user_id': currentUserInfo?.user_id.toString(),
    });
    if (response.statusCode == 200) {
      var responseBodyOfTagList = jsonDecode(response.body);
      if (responseBodyOfTagList['success'] == true) {
        for (var jsondata in responseBodyOfTagList["data"]) {
          tags.add(Tag.fromJson(jsondata));
        }
      }
    }
  } catch (error) {
    if (error is SocketException) {
      errorMessage = 'Network error: $error';
    } else {
      errorMessage = 'Other error: $error';
    }
  }
}
