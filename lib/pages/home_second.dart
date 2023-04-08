import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:znajdz_chwile/users/authentication/login_screen.dart';
import 'package:znajdz_chwile/users/userPreferences/current_user.dart';
import 'package:znajdz_chwile/users/userPreferences/user_preferences.dart';
import 'package:znajdz_chwile/services/local_notice_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../api_connection/api_connection.dart';
import '../model/event.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final CurrentUser _currentUser = Get.put(CurrentUser());

class HomeSecond extends StatefulWidget {
  const HomeSecond({super.key});

  @override
  State<HomeSecond> createState() => _HomeSecondState();
}

class _HomeSecondState extends State<HomeSecond> {
  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
  }

  addEvent() async {
    Event eventModel = Event(
        1,
        _currentUser.user.user_id,
        _eventTitleController.text.trim(),
        _eventDescriptionController.text.trim(),
        _eventDateStart,
        _eventDateEnd,
        0,
        _eventHaveNotification);
    if (_eventTitleController.text != "") {
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
              _eventTitleController.clear();
              _eventDescriptionController.clear();
              _eventDateController.clear();
              _eventDateStartController.clear();
              _eventDateEndController.clear();
              _eventNotification = false;
              _eventHaveNotification = 0;
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

  final _eventTitleController = TextEditingController();
  final _eventDescriptionController = TextEditingController();
  final _eventDateController = TextEditingController();

  final _eventDateStartController = TextEditingController();
  DateTime _eventDateStart = DateTime.now();
  final _eventDateEndController = TextEditingController();
  DateTime _eventDateEnd = DateTime.now();
  bool _eventNotification = false;
  int _eventHaveNotification = 0;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Obx(() => Text(_currentUser.user.user_name)),
        Obx(() => Text(_currentUser.user.user_email)),
        Obx(() => Text(_currentUser.user.user_id.toString())),
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
              decoration: const InputDecoration(labelText: "Tytuł"),
              controller: _eventTitleController,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "Opis"),
              controller: _eventDescriptionController,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "Data rozpoczecia"),
              controller: _eventDateStartController,
              onTap: () {
                /*DatePicker.showPicker(context, showTitleActions: true,
                    onChanged: (date) {
                  print('change $date in time zone ' +
                      date.timeZoneOffset.inHours.toString());
                }, onConfirm: (date) {
                  print('confirm $date');
                },
                    pickerModel: CustomPicker(
                        currentTime: DateTime.now(), locale: LocaleType.pl),
                    locale: LocaleType.pl);*/

                DatePicker.showDateTimePicker(context,
                    showTitleActions: true,
                    minTime: DateTime.now(),
                    maxTime: DateTime(2030, 6, 7), onChanged: (date) {
                  _eventDateStartController.clear();
                  _eventDateStartController.text =
                      "${date.day}-${date.month}-${date.year}  ${date.hour}:${date.minute}";
                  _eventDateStart = date;
                }, onConfirm: (date) {
                  _eventDateStartController.clear();
                  _eventDateStartController.text =
                      "${date.day}-${date.month}-${date.year}  ${date.hour}:${date.minute}";
                  _eventDateStart = date;
                }, currentTime: DateTime.now(), locale: LocaleType.pl);
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "Data zakonczenia"),
              controller: _eventDateEndController,
              onTap: () {
                DatePicker.showDateTimePicker(context,
                    showTitleActions: true,
                    minTime: DateTime.now(),
                    maxTime: DateTime(2030, 6, 7), onChanged: (date) {
                  _eventDateEndController.clear();
                  _eventDateEndController.text =
                      "${date.day}-${date.month}-${date.year}  ${date.hour}:${date.minute}";
                  _eventDateEnd = date;
                }, onConfirm: (date) {
                  _eventDateEndController.clear();
                  _eventDateEndController.text =
                      "${date.day}-${date.month}-${date.year}  ${date.hour}:${date.minute}";
                  _eventDateEnd = date;
                }, currentTime: DateTime.now(), locale: LocaleType.pl);
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.notifications),
                Switch(
                    value: _eventNotification,
                    onChanged: (value) {
                      setState(() {
                        _eventNotification = value;
                        if (value == false) {
                          _eventHaveNotification = 0;
                        } else {
                          _eventHaveNotification = 1;
                        }
                      });
                    }),
              ],
            ),
            ElevatedButton(
                onPressed: () {
                  /*addEvent();
                  String eventStartDescription =
                      "Nadszedł czas na ${_eventTitleController.text}\n${_eventDescriptionController.text}";
                  NotificationService().showNotification(
                      1,
                      _eventTitleController.text,
                      eventStartDescription,
                      _eventDateStart);

                  String eventEndDescription =
                      "Koniec czasu na ${_eventTitleController.text}\n${_eventDescriptionController.text}";
                  NotificationService().showNotification(
                      2,
                      _eventTitleController.text,
                      eventEndDescription,
                      _eventDateEnd);*/
                  print(_currentUser.user.user_name);
                },
                child: const Text("Dodaj")),
          ],
        ))
      ],
    );
  }
}
