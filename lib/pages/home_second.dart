import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:znajdz_chwile/users/authentication/login_screen.dart';
import 'package:znajdz_chwile/users/userPreferences/current_user.dart';
import 'package:znajdz_chwile/users/userPreferences/user_preferences.dart';

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
      ],
    );
  }
}
