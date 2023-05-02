import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:znajdz_chwile/colors/colors.dart';
import 'package:znajdz_chwile/users/authentication/signup_screen.dart';
import 'package:znajdz_chwile/users/userPreferences/user_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../api_connection/api_connection.dart';
import '../../pages/home.dart';
import '../../models/user.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginState();
}

const OutlineInputBorder borderInput = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(20)),
    borderSide: BorderSide(color: color8, width: 1));

class _LoginState extends State<LoginScreen> {
  var formKey = GlobalKey<FormState>();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  loginUserNow() async {
    try {
      var response = await http.post(Uri.parse(API.login), body: {
        'user_email': emailController.text.trim(),
        'user_password': passwordController.text.trim()
      });
      if (response.statusCode == 200) {
        var responseBodyOfLogin = jsonDecode(response.body);
        if (responseBodyOfLogin['success'] == true) {
          User userInfo = User.fromJson(responseBodyOfLogin["userData"]);
          await RememberUserPrefs.storeUserInfo(userInfo);
          Future.delayed(const Duration(milliseconds: 0), () {
            Get.off(const Home());
          });
          setState(() {
            emailController.clear();
            passwordController.clear();
          });
          Fluttertoast.showToast(msg: "Logowanie powiodło się.");
        } else {
          Fluttertoast.showToast(msg: "Błąd, podaj poprawne dane");
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Błąd");
    }
  }

  validateUserEmail(String email, String? name) async {
    try {
      var responseValidateEmail =
          await http.post(Uri.parse(API.validateEmail), body: {
        'user_email': email.trim().toString(),
      });
      if (responseValidateEmail.statusCode == 200) {
        var responseBodyOfValidateEmail =
            jsonDecode(responseValidateEmail.body);
        if (responseBodyOfValidateEmail['emailFound'] == true) {
          loginUserWithGoogle(email, name);
        } else {
          await signUpUserWithGoogle(email, name);
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  loginUserWithGoogle(String email, String? name) async {
    User userModel = User(1, name!, email, "#");
    try {
      var responseLogin = await http.post(Uri.parse(API.loginWithGoogle),
          body: userModel.toJson());
      if (responseLogin.statusCode == 200) {
        var responseBodyOfLoginUserWithGoogle = jsonDecode(responseLogin.body);
        if (responseBodyOfLoginUserWithGoogle['success'] == true) {
          User userInfo =
              User.fromJson(responseBodyOfLoginUserWithGoogle["userData"]);
          await RememberUserPrefs.storeUserInfo(userInfo);
          Get.offAll(const Home());
          setState(() {
            emailController.clear();
            passwordController.clear();
          });
          Fluttertoast.showToast(msg: "Logowanie powiodło się.");
        }
      } else {
        Fluttertoast.showToast(msg: "Błąd, podaj poprawne dane");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  signUpUserWithGoogle(String email, String? name) async {
    User userModel = User(1, name!, email, "#");
    try {
      var responseSignUp = await http.post(Uri.parse(API.signUpWithGoogle),
          body: userModel.toJson());
      if (responseSignUp.statusCode == 200) {
        var responseBodyOfSignUpUserWithGoogle =
            jsonDecode(responseSignUp.body);
        if (responseBodyOfSignUpUserWithGoogle['success'] == true) {
          try {
            var responseGetIdUserGoogle = await http
                .post(Uri.parse(API.getIdUserGoogle), body: userModel.toJson());
            if (responseGetIdUserGoogle.statusCode == 200) {
              var responseBodyOfGetIdUserGoogle =
                  jsonDecode(responseGetIdUserGoogle.body);
              if (responseBodyOfGetIdUserGoogle['success'] == true) {
                User userModel = User(
                    int.parse(responseBodyOfGetIdUserGoogle['userId'][0]),
                    name,
                    email,
                    "#");
                await RememberUserPrefs.storeUserInfo(userModel);
                Get.offAll(const Home());
                setState(() {
                  emailController.clear();
                  passwordController.clear();
                });
              }
            }
          } catch (e) {
            Fluttertoast.showToast(msg: e.toString());
          }
        } else {
          Fluttertoast.showToast(msg: "Problem z dodaniem użytkownika Googla");
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
            constraints: const BoxConstraints(minHeight: 0),
            child: SingleChildScrollView(
              reverse: true,
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "Znajdź chwilę !",
                    style: TextStyle(
                        fontFamily: "OpenSans",
                        fontSize: 30,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 250,
                    child: SvgPicture.asset(
                        "assets/images/undraw_time_management.svg"),
                  ),
                  const SizedBox(
                    height: 20,
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
                                    const EdgeInsets.fromLTRB(55, 0, 55, 10),
                                child: TextFormField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value != null) {
                                      if (value.contains('@')) {
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
                                    const EdgeInsets.fromLTRB(55, 10, 55, 10),
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
                                padding: const EdgeInsets.only(top: 10),
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (formKey.currentState!.validate()) {
                                      loginUserNow();
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
                                    'Zaloguj',
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
                              padding: const EdgeInsets.only(top: 10),
                              child: TextButton(
                                  onPressed: () {
                                    Get.off(const SignUpScreen());
                                  },
                                  style: ButtonStyle(
                                    overlayColor: MaterialStateProperty.all(
                                        Colors.transparent),
                                    splashFactory: NoSplash.splashFactory,
                                    backgroundColor:
                                        MaterialStateProperty.all(color2),
                                  ),
                                  child: const Text(
                                    'Utwórz konto',
                                    style: TextStyle(
                                        color: color8,
                                        fontFamily: 'Segoe UI',
                                        fontSize: 12),
                                  )),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 1,
                              width: 70,
                              color: color8,
                            ),
                            const Text(" lub "),
                            Container(
                              height: 1,
                              width: 70,
                              color: color8,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                _googleSignIn.signIn().then((value) {
                                  validateUserEmail(
                                      value!.email.trim(), value.displayName);
                                });
                              },
                              icon: const Icon(
                                FontAwesomeIcons.google,
                                color: color8,
                              ),
                              splashRadius: 0.1,
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
