import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:znajdz_chwile/users/authentication/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Znajdz Chwilę',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(builder: (context, dataSnapShot) {
        return const LoginScreen();
      }),
    );
  }
}
