import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:znajdz_chwile/pages/home.dart';
import 'package:znajdz_chwile/services/local_notice_service.dart';
import 'package:znajdz_chwile/users/authentication/login_screen.dart';
import 'package:znajdz_chwile/users/userPreferences/user_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotification();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Znajdz Chwilę',
      home: FutureBuilder(
          future: RememberUserPrefs.readUserInfo(),
          builder: (context, dataSnapShot) {
            if (dataSnapShot.data == null) {
              return const LoginScreen();
            } else {
              return const Home();
            }
          }),
    );
  }
}
