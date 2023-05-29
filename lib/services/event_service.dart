import 'dart:convert';
import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../api_connection/api_connection.dart';
import '../models/event.dart';
import '../models/user.dart';
import '../users/userPreferences/user_preferences.dart';

loadEventsFromDatabase(List<Event> events, String errorMessage) async {
  try {
    Future<User?> userInfo = RememberUserPrefs.readUserInfo();
    User? currentUserInfo = await userInfo;
    final response = await http.post(Uri.parse(API.eventsList), body: {
      'user_id': currentUserInfo?.user_id.toString(),
    });
    if (response.statusCode == 200) {
      var responseBodyOfEventListWithRangeDate = jsonDecode(response.body);
      if (responseBodyOfEventListWithRangeDate["success"] == true) {
        for (var jsondata in responseBodyOfEventListWithRangeDate["data"]) {
          events.add(Event.fromJson(jsondata));
        }
      }
    } else {
      errorMessage = 'Request failed with status: ${response.statusCode}';
    }
  } catch (error) {
    if (error is SocketException) {
      errorMessage = 'Network error: $error';
    } else {
      errorMessage = 'Other error: $error';
    }
  }
}

deleteEventFromDatabase(Event event) async {
  try {
    Future<User?> userInfo = RememberUserPrefs.readUserInfo();
    User? currentUserInfo = await userInfo;
    var response = await http.post(Uri.parse(API.eventDelete), body: {
      'event_id': event.eventId.toString(),
      'user_id': currentUserInfo?.user_id.toString(),
    });
    if (response.statusCode == 200) {
      var responseBodyOfEventDelete = jsonDecode(response.body);
      if (responseBodyOfEventDelete["success"] == false) {
        Fluttertoast.showToast(msg: "Nie udało się usunąć");
      }
    }
  } catch (e) {
    Fluttertoast.showToast(msg: e.toString());
  }
}

eventCheckBoxToDatabase(Event event) async {
  try {
    Future<User?> userInfo = RememberUserPrefs.readUserInfo();
    User? currentUserInfo = await userInfo;
    var response = await http.post(Uri.parse(API.eventCheck), body: {
      'user_id': currentUserInfo?.user_id.toString(),
      'event_id': event.eventId.toString(),
      'event_is_done': event.eventIsDone == 1 ? "1" : "0"
    });
    if (response.statusCode == 200) {
      var responseBodyOfEventList = jsonDecode(response.body);
      if (responseBodyOfEventList["success"] == false) {
        Fluttertoast.showToast(msg: "Nie udało się zmienić checkboxa");
      }
    }
  } catch (e) {
    Fluttertoast.showToast(msg: e.toString());
  }
}

addEventToDatabase(Event event) async {
  try {
    var response =
        await http.post(Uri.parse(API.eventAdd), body: event.toJson());
    if (response.statusCode == 200) {
      var responseBodyOfAddEvent = jsonDecode(response.body);
      if (responseBodyOfAddEvent["success"] == true) {
        Fluttertoast.showToast(msg: "Dodano zdarzenie.");
      } else {
        Fluttertoast.showToast(msg: "Błąd, spróbuj ponownie");
      }
    }
  } catch (e) {
    Fluttertoast.showToast(msg: e.toString());
  }
}
