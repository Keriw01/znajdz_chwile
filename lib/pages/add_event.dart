import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:znajdz_chwile/api_connection/api_connection.dart';
import 'package:znajdz_chwile/colors/colors.dart';
import 'package:http/http.dart' as http;
import 'package:znajdz_chwile/pages/home.dart';
import 'package:znajdz_chwile/pages/home_second.dart';
import 'package:intl/intl.dart';
import 'package:znajdz_chwile/services/local_notice_service.dart';

import '../models/event.dart';
import '../models/user.dart';
import '../users/userPreferences/user_preferences.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class AddEventPage extends StatefulWidget {
  const AddEventPage({Key? key}) : super(key: key);
  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  @override
  void initState() {
    tz.initializeTimeZones();
    super.initState();
  }

  var formKey = GlobalKey<FormState>();
  final _eventTitleController = TextEditingController();
  final _eventDescriptionController = TextEditingController();
  final _eventDateStartController = TextEditingController();
  final _eventDateEndController = TextEditingController();

  DateTime _eventDateStart = DateTime.now();
  DateTime _eventDateEnd = DateTime.now();
  bool _eventNotification = false;
  int _eventHaveNotification = 0;

  static const OutlineInputBorder borderInput = OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(20),
      ),
      borderSide: BorderSide.none);

  addEvent() async {
    Future<User?> userInfo = RememberUserPrefs.readUserInfo();
    User? currentUserInfo = await userInfo;

    Event eventModel = Event(
        1,
        currentUserInfo!.user_id,
        _eventTitleController.text.trim(),
        _eventDescriptionController.text.trim(),
        _eventDateStart,
        _eventDateEnd,
        0,
        _eventHaveNotification);
    try {
      var response =
          await http.post(Uri.parse(API.eventAdd), body: eventModel.toJson());
      if (response.statusCode == 200) {
        var responseBodyOfAddEvent = jsonDecode(response.body);
        if (responseBodyOfAddEvent["success"] == true) {
          //trzeba znalezc max id w bazie i przekazac do ID powiadomienia
          // var responseEventId = await http.post(Uri.parse(API.getLastEventId),
          //   body: {'user_id': currentUserInfo.user_id});
          // var responseOfEventId = jsonDecode(responseEventId.body);

          // if (responseOfEventId["success"] == true) {
          //  var event_id = responseOfEventId["eventData"];
          // print(event_id);
          //}

          if (_eventHaveNotification == 1) {
            String eventStartDescription =
                "Nadszedł czas na ${_eventTitleController.text}\n${_eventDescriptionController.text}";
            NotificationService().showNotification(
                1,
                _eventTitleController.text,
                eventStartDescription,
                _eventDateStart);

            String eventEndDescription =
                "Koniec czasu na ${_eventTitleController.text}\n${_eventDescriptionController.text}";
            NotificationService().showNotification(2,
                _eventTitleController.text, eventEndDescription, _eventDateEnd);
          }

          setState(() {
            _eventTitleController.clear();
            _eventDescriptionController.clear();
            _eventDateStartController.clear();
            _eventDateEndController.clear();
            _eventNotification = false;
            _eventHaveNotification = 0;
          });
          Fluttertoast.showToast(msg: "Dodano zdarzenie.");
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
    return Scaffold(
        backgroundColor: color2,
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Dodaj zdarzenie",
              style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.bold)),
          backgroundColor: color6,
        ),
        body: ListView(children: [
          Form(
            key: formKey,
            child: Column(children: [
              Padding(
                  padding: const EdgeInsets.fromLTRB(55, 50, 55, 10),
                  child: TextFormField(
                    controller: _eventTitleController,
                    keyboardType: TextInputType.text,
                    cursorColor: color8,
                    style: const TextStyle(
                        color: color8, fontFamily: 'OpenSans', fontSize: 14),
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: color1,
                      errorBorder: borderInput,
                      focusedErrorBorder: borderInput,
                      focusedBorder: borderInput,
                      enabledBorder: borderInput,
                      prefixIcon: Icon(
                        Icons.title,
                        color: color8,
                        size: 22,
                      ),
                      labelText: 'Tytuł',
                      labelStyle: TextStyle(color: color8),
                      floatingLabelStyle: TextStyle(color: color8),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Tytuł jest wymagany';
                      }
                      return null;
                    },
                  )),
              Padding(
                  padding: const EdgeInsets.fromLTRB(55, 10, 55, 10),
                  child: TextFormField(
                      controller: _eventDescriptionController,
                      keyboardType: TextInputType.text,
                      cursorColor: color8,
                      style: const TextStyle(
                          color: color8, fontFamily: 'OpenSans', fontSize: 14),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: color1,
                        errorBorder: borderInput,
                        focusedErrorBorder: borderInput,
                        focusedBorder: borderInput,
                        enabledBorder: borderInput,
                        prefixIcon: Icon(
                          Icons.description,
                          color: color8,
                          size: 22,
                        ),
                        labelText: 'Opis',
                        labelStyle: TextStyle(color: color8),
                        floatingLabelStyle: TextStyle(color: color8),
                      ))),
              Padding(
                padding: const EdgeInsets.fromLTRB(55, 10, 55, 10),
                child: TextFormField(
                  keyboardType: TextInputType.none,
                  readOnly: true,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: color1,
                    errorBorder: borderInput,
                    focusedErrorBorder: borderInput,
                    focusedBorder: borderInput,
                    enabledBorder: borderInput,
                    prefixIcon: Icon(
                      Icons.date_range,
                      color: color8,
                      size: 22,
                    ),
                    labelText: 'Data rozpoczęcia',
                    labelStyle: TextStyle(color: color8),
                    floatingLabelStyle: TextStyle(color: color8),
                  ),
                  controller: _eventDateStartController,
                  onTap: () {
                    DatePicker.showDateTimePicker(context,
                        showTitleActions: true,
                        minTime: DateTime.now(),
                        maxTime: DateTime(2030, 6, 7), onChanged: (date) {
                      _eventDateStartController.clear();
                      _eventDateStartController.text =
                          DateFormat('HH:mm dd-MM-yyyy').format(date);
                      _eventDateStart = date;
                    }, onConfirm: (date) {
                      _eventDateStartController.clear();
                      _eventDateStartController.text =
                          DateFormat('HH:mm dd-MM-yyyy').format(date);
                      _eventDateStart = date;
                    }, currentTime: DateTime.now(), locale: LocaleType.pl);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Data rozpoczęcia jest wymagana';
                    } else {
                      DateTime? eventDateStart =
                          DateFormat('HH:mm dd-MM-yyyy').parseStrict(value);
                      if (eventDateStart.isAfter(_eventDateEnd)) {
                        return 'Data rozpoczęcia musi być wcześniejsza\nniż data zakończenia';
                      } else {
                        return null;
                      }
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(55, 10, 55, 10),
                child: TextFormField(
                  keyboardType: TextInputType.none,
                  readOnly: true,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: color1,
                    errorBorder: borderInput,
                    focusedErrorBorder: borderInput,
                    focusedBorder: borderInput,
                    enabledBorder: borderInput,
                    prefixIcon: Icon(
                      Icons.date_range,
                      color: color8,
                      size: 22,
                    ),
                    labelText: 'Data zakończenia',
                    labelStyle: TextStyle(color: color8),
                    floatingLabelStyle: TextStyle(color: color8),
                  ),
                  controller: _eventDateEndController,
                  onTap: () {
                    DatePicker.showDateTimePicker(context,
                        showTitleActions: true,
                        minTime: DateTime.now(),
                        maxTime: DateTime(2030, 6, 7), onChanged: (date) {
                      _eventDateEndController.clear();
                      _eventDateEndController.text =
                          DateFormat('HH:mm dd-MM-yyyy').format(date);
                      _eventDateEnd = date;
                    }, onConfirm: (date) {
                      _eventDateEndController.clear();
                      _eventDateEndController.text =
                          DateFormat('HH:mm dd-MM-yyyy').format(date);
                      _eventDateEnd = date;
                    }, currentTime: DateTime.now(), locale: LocaleType.pl);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Data zakończenia jest wymagana';
                    } else {
                      DateTime? eventDateEnd =
                          DateFormat('HH:mm dd-MM-yyyy').parseStrict(value);
                      if (eventDateEnd.isBefore(_eventDateStart)) {
                        return 'Data zakończenia musi być późniejsza\nniż data rozpoczęcia';
                      } else {
                        return null;
                      }
                    }
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.notifications),
                  Switch(
                      activeColor: color8,
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
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    await addEvent();
                    Get.offAll(const Home());
                  }
                },
                style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.fromLTRB(75, 10, 75, 10)),
                    backgroundColor: MaterialStateProperty.all(color8),
                    shape: MaterialStateProperty.all(
                        const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0))))),
                child: const Text(
                  'Dodaj',
                  style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Segoe UI',
                      fontWeight: FontWeight.w700),
                ),
              ),
            ]),
          )
        ]));
  }
}
