import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:znajdz_chwile/api_connection/api_connection.dart';
import 'package:znajdz_chwile/colors/colors.dart';
import 'package:znajdz_chwile/users/authentication/login_screen.dart';

import '../../models/user.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _LoginState();
}

const OutlineInputBorder borderInput = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(20)),
    borderSide: BorderSide(color: color8, width: 1));

class _LoginState extends State<SignUpScreen> {
  var formKey = GlobalKey<FormState>();
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  validateUserEmail() async {
    try {
      var response = await http.post(Uri.parse(API.validateEmail), body: {
        'user_email': emailController.text.trim(),
      });
      if (response.statusCode ==
          200) // HTTP 200 OK success status of connection with api to server
      {
        var responseBodyOfValidateEmail = jsonDecode(response.body);
        if (responseBodyOfValidateEmail['emailFound'] == true) {
          Fluttertoast.showToast(msg: "Email jest już używany!");
        } else {
          registerAndSaveUserRecord();
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  registerAndSaveUserRecord() async {
    User userModel = User(1, nameController.text.trim(),
        emailController.text.trim(), passwordController.text.trim());
    try {
      var response =
          await http.post(Uri.parse(API.signUp), body: userModel.toJson());
      if (response.statusCode == 200) {
        var responseBodyOfSignUp = jsonDecode(response.body);
        if (responseBodyOfSignUp['success'] == true) {
          Fluttertoast.showToast(msg: "Rejestracja powiodła się.");
          setState(() {
            nameController.clear();
            emailController.clear();
            passwordController.clear();
          });
        } else {
          Fluttertoast.showToast(msg: "Błąd, spróbuj ponownie");
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: color2,
        body: LayoutBuilder(builder: (context, cons) {
          return ConstrainedBox(
            constraints: BoxConstraints(minHeight: cons.maxHeight),
            child: SingleChildScrollView(
              reverse: true,
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Znajdź chwilę !",
                    style: TextStyle(
                        fontFamily: "OpenSans",
                        fontSize: 30,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 200,
                    child: SvgPicture.asset(
                        "assets/images/undraw_time_management.svg"),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    decoration: const BoxDecoration(),
                    child: Column(
                      children: [
                        Form(
                          key: formKey,
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(55, 0, 55, 5),
                                child: TextFormField(
                                  controller: nameController,
                                  validator: (value) {
                                    if (value != null) {
                                      if (value.isEmpty) {
                                        return 'Wprowadź nazwę';
                                      }
                                      return null;
                                    }
                                    return null;
                                  },
                                  cursorColor: color8,
                                  style: const TextStyle(
                                      color: color8,
                                      fontFamily: 'OpenSans',
                                      fontSize: 14),
                                  decoration: const InputDecoration(
                                    filled: true,
                                    fillColor: color1,
                                    errorBorder: borderInput,
                                    focusedErrorBorder: borderInput,
                                    focusedBorder: borderInput,
                                    enabledBorder: borderInput,
                                    prefixIcon: Icon(
                                      Icons.person,
                                      color: color8,
                                      size: 22,
                                    ),
                                    labelText: 'Wpisz swoją nazwę',
                                    labelStyle: TextStyle(color: color8),
                                    floatingLabelStyle:
                                        TextStyle(color: color8),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(55, 15, 55, 5),
                                child: TextFormField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value != null) {
                                      if (value.contains('@') &&
                                          value.trim().length >= 7) {
                                        return null;
                                      }
                                      return 'Wprowadź poprawny adres e-mail';
                                    }
                                    return null;
                                  },
                                  cursorColor: color8,
                                  style: const TextStyle(
                                      color: color8,
                                      fontFamily: 'OpenSans',
                                      fontSize: 14),
                                  decoration: const InputDecoration(
                                    filled: true,
                                    fillColor: color1,
                                    errorBorder: borderInput,
                                    focusedErrorBorder: borderInput,
                                    focusedBorder: borderInput,
                                    enabledBorder: borderInput,
                                    prefixIcon: Icon(
                                      Icons.email,
                                      color: color8,
                                      size: 22,
                                    ),
                                    labelText: 'Wpisz swój e-mail',
                                    labelStyle: TextStyle(color: color8),
                                    floatingLabelStyle:
                                        TextStyle(color: color8),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(55, 15, 55, 5),
                                child: TextFormField(
                                  controller: passwordController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Hasło jest wymagane';
                                    }
                                    if (value.trim().length < 8) {
                                      return 'Hasło musi mieć co najmniej 8 znaków';
                                    }
                                    return null;
                                  },
                                  cursorColor: color8,
                                  style: const TextStyle(
                                      color: color8,
                                      fontFamily: 'OpenSans',
                                      fontSize: 14),
                                  decoration: const InputDecoration(
                                    filled: true,
                                    fillColor: color1,
                                    errorBorder: borderInput,
                                    focusedErrorBorder: borderInput,
                                    focusedBorder: borderInput,
                                    enabledBorder: borderInput,
                                    prefixIcon: Icon(
                                      Icons.lock,
                                      color: color8,
                                      size: 22,
                                    ),
                                    labelText: 'Wpisz swoje hasło',
                                    labelStyle: TextStyle(color: color8),
                                    floatingLabelStyle:
                                        TextStyle(color: color8),
                                  ),
                                  obscureText: true,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (formKey.currentState!.validate()) {
                                      validateUserEmail();
                                    }
                                  },
                                  style: ButtonStyle(
                                      padding:
                                          MaterialStateProperty.all<EdgeInsets>(
                                              const EdgeInsets.fromLTRB(
                                                  75, 10, 75, 10)),
                                      backgroundColor:
                                          MaterialStateProperty.all(color8),
                                      shape: MaterialStateProperty.all(
                                          const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20.0))))),
                                  child: const Text(
                                    'Zarejestruj',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontFamily: 'Segoe UI',
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: ((context) =>
                                                const LoginScreen())));
                                    //Get.to(const LoginScreen());
                                  },
                                  style: ButtonStyle(
                                    overlayColor: MaterialStateProperty.all(
                                        Colors.transparent),
                                    splashFactory: NoSplash.splashFactory,
                                    backgroundColor:
                                        MaterialStateProperty.all(color2),
                                  ),
                                  child: RichText(
                                      text: const TextSpan(
                                          style: TextStyle(
                                              color: color8, fontSize: 12),
                                          children: <TextSpan>[
                                        TextSpan(
                                          text: 'Posiadasz już konto? ',
                                        ),
                                        TextSpan(
                                          text: 'Zaloguj się tutaj',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600),
                                        )
                                      ]))),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
