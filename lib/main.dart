import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:znajdz_chwile/pages/home.dart';
import 'package:znajdz_chwile/services/local_notice_service.dart';
import 'package:znajdz_chwile/users/authentication/login_screen.dart';
import 'package:znajdz_chwile/users/userPreferences/user_preferences.dart';

import 'provider/events_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotification();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => EventsProvider()),
      ],
      child: ChangeNotifierProvider(
        create: (context) => EventsProvider(),
        child: GetMaterialApp(
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
        ),
      ),
    );
  }
}
