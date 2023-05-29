import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../users/authentication/login_screen.dart';
import '../users/userPreferences/user_preferences.dart';
import '../colors/colors.dart';

final GoogleSignIn _googleSignOut = GoogleSignIn();

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color2,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            ElevatedButton(
              onPressed: () {
                RememberUserPrefs.removeUserInfo().then((value) {
                  _googleSignOut.signOut();
                  Get.offAll(const LoginScreen());
                });
              },
              style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.fromLTRB(75, 10, 75, 10)),
                  backgroundColor: MaterialStateProperty.all(color8),
                  shape: MaterialStateProperty.all(const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0))))),
              child: const Text(
                "Wyloguj",
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Segoe UI',
                    fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: const Text("Znajdz Chwilę"),
                          content: const Text(
                              "Aplikacja stworzona przez grupę projektową. © 2023"),
                          actions: <Widget>[
                            TextButton(
                              child: const Text(
                                'Cofnij',
                                style: TextStyle(color: color8),
                              ),
                              onPressed: () {
                                Get.back();
                              },
                            ),
                          ],
                        ));
              },
              style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.fromLTRB(65, 10, 65, 10)),
                  backgroundColor: MaterialStateProperty.all(color8),
                  shape: MaterialStateProperty.all(const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0))))),
              child: const Text(
                "Informacje",
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Segoe UI',
                    fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
