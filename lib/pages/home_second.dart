import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:znajdz_chwile/users/authentication/login_screen.dart';
import 'package:znajdz_chwile/users/userPreferences/current_user.dart';
import 'package:znajdz_chwile/users/userPreferences/user_preferences.dart';

import '../api_connection/api_connection.dart';
import '../users/model/event.dart';

class HomeSecond extends StatefulWidget {
  const HomeSecond({super.key});

  @override
  State<HomeSecond> createState() => _HomeSecondState();
}

class _HomeSecondState extends State<HomeSecond> {
  final CurrentUser _currentUser = Get.put(CurrentUser());

  Widget userInfo(String userData) {
    return Row(
      children: [Text(userData)],
    );
  }

  addEvent() async {
    Event eventModel =
        Event(1, _currentUser.user.user_id, titleEventController.text.trim());
    if (titleEventController.text != "") {
      try {
        var response =
            await http.post(Uri.parse(API.addEvent), body: eventModel.toJson()
                //'userId': _currentUser.user.user_id.toString(),
                //'eventTitle': titleEventController.text,
                );
        if (response.statusCode == 200) {
          var responseBodyOfAddEvent = jsonDecode(response.body);
          if (responseBodyOfAddEvent["success"] == true) {
            Fluttertoast.showToast(msg: "Dodano zdarzenie.");
            setState(() {
              titleEventController.clear();
            });
          } else {
            Fluttertoast.showToast(msg: "Błąd, spróbuj ponownie");
          }
        }
      } catch (e) {
        Fluttertoast.showToast(msg: e.toString());
      }
    } else {
      Fluttertoast.showToast(msg: "Pole nie może być puste!");
    }
  }

  var formKey = GlobalKey<FormState>();

  var titleEventController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        userInfo(_currentUser.user.user_name),
        userInfo(_currentUser.user.user_email),
        userInfo(_currentUser.user.user_id.toString()),
        ElevatedButton(
            onPressed: () {
              RememberUserPrefs.removeUserInfo().then((value) {
                Get.off(const LoginScreen());
              });
            },
            child: const Text("Wyloguj")),
        Form(
            child: Column(
          children: [
            TextFormField(
              controller: titleEventController,
            ),
            ElevatedButton(
                onPressed: () {
                  addEvent();
                },
                child: const Text("Dodaj")),
          ],
        ))
      ],
    );
  }
}
