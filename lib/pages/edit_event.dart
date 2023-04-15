import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:znajdz_chwile/api_connection/api_connection.dart';
import 'package:znajdz_chwile/colors/colors.dart';
import 'package:http/http.dart' as http;

import '../models/event.dart';
import '../models/user.dart';
import '../users/userPreferences/user_preferences.dart';

class EditEventPage extends StatefulWidget {
  const EditEventPage({Key? key, required this.event}) : super(key: key);
  final Event event;
  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  var formKey = GlobalKey<FormState>();
  late TextEditingController _eventTitleController;
  late TextEditingController _eventDescriptionController;
  late TextEditingController _eventDateStartController;
  late TextEditingController _eventDateEndController;

  DateTime _eventDateStart = DateTime.now();
  DateTime _eventDateEnd = DateTime.now();
  bool _eventNotification = false;
  int _eventHaveNotification = 0;

  @override
  void initState() {
    super.initState();
    _eventTitleController =
        TextEditingController(text: widget.event.event_title.toString());
    _eventDescriptionController =
        TextEditingController(text: widget.event.event_description.toString());
    _eventDateStartController =
        TextEditingController(text: widget.event.event_date_start.toString());
    _eventDateEndController =
        TextEditingController(text: widget.event.event_date_end.toString());
    widget.event.event_notification.toString() == "1"
        ? _eventNotification = true
        : _eventNotification = false;
  }

  static const OutlineInputBorder borderInput = OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(20),
      ),
      borderSide: BorderSide.none);

  updateEvent(Event event) async {
    Event eventModel = Event(
        event.event_id,
        event.user_id,
        _eventTitleController.text.trim(),
        _eventDescriptionController.text.trim(),
        _eventDateStart,
        _eventDateEnd,
        event.event_is_done,
        _eventHaveNotification);
    try {
      var response = await http.post(Uri.parse(API.eventUpdate),
          body: eventModel.toJson());
      if (response.statusCode == 200) {
        var responseBodyOfEditEvent = jsonDecode(response.body);
        if (responseBodyOfEditEvent["success"] == true) {
          Fluttertoast.showToast(msg: "Edytowano zdarzenie.");
          setState(() {
            _eventTitleController.clear();
            _eventDescriptionController.clear();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: color2,
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Edytuj zdarzenie",
              style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.bold)),
          backgroundColor: color6,
        ),
        body: ListView(children: [
          Form(
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
                      ))),
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
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(55, 10, 55, 10),
                child: TextFormField(
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
                onPressed: () {
                  updateEvent(widget.event);
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
                  'Zapisz',
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
