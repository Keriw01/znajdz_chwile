import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../users/authentication/login_screen.dart';
import '../users/userPreferences/user_preferences.dart';

final GoogleSignIn _googleSignOut = GoogleSignIn();

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
            onPressed: () {
              RememberUserPrefs.removeUserInfo().then((value) {
                _googleSignOut.signOut();
                Get.offAll(const LoginScreen());
              });
            },
            child: const Text("Wyloguj")),
      ),
    );
  }
}
