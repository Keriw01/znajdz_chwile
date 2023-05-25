import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:znajdz_chwile/api_connection/api_connection.dart';
import 'package:znajdz_chwile/colors/colors.dart';
import 'package:http/http.dart' as http;
import 'package:znajdz_chwile/pages/home.dart';
import 'package:znajdz_chwile/pages/home_second.dart';
import 'package:intl/intl.dart';

import '../models/event.dart';
import '../models/tag.dart';
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
  late final List<Tag> tagList = [];
  List<String> tagListName = [];
  String? dropdownValue;
  int? tagId;

  Future<List<Tag>> tagListJson() async {
    Future<User?> userInfo = RememberUserPrefs.readUserInfo();
    User? currentUserInfo = await userInfo;

    var response = await http.post(Uri.parse(API.tagsList), body: {
      'user_id': currentUserInfo?.user_id.toString(),
    });
    List<Tag> tagList = [];
    if (response.statusCode == 200) {
      var responseBodyOfTagList = jsonDecode(response.body);
      if (responseBodyOfTagList['success'] == true) {
        for (var jsondata in responseBodyOfTagList["data"]) {
          tagList.add(Tag.fromJson(jsondata));
        }
      }
    }
    return tagList;
  }

  List<String> tagWithNameList() {
    List<String> listTagWithName = [];
    for (var element in tagList) {
      listTagWithName.add(element.tag_name);
    }
    return listTagWithName;
  }

  String tagFindName(int tagId) {
    String tagName = "empty";
    for (var element in tagList) {
      if (element.tag_id == tagId) {
        tagName = element.tag_name;
      }
    }
    return tagName;
  }

  int tagFindId(String tagName) {
    int tagId = widget.event.tag_id;
    for (var element in tagList) {
      if (element.tag_name == tagName) {
        tagId = element.tag_id;
      }
    }
    return tagId;
  }

  @override
  void initState() {
    super.initState();
    _eventTitleController =
        TextEditingController(text: widget.event.event_title.toString());
    _eventDescriptionController =
        TextEditingController(text: widget.event.event_description.toString());
    _eventDateStartController = TextEditingController(
        text: DateFormat('HH:mm dd-MM-yyyy')
            .format(widget.event.event_date_start));
    _eventDateEndController = TextEditingController(
        text:
            DateFormat('HH:mm dd-MM-yyyy').format(widget.event.event_date_end));
    widget.event.event_notification.toString() == "1"
        ? _eventNotification = true
        : _eventNotification = false;
    _eventDateStart = widget.event.event_date_start;
    _eventDateEnd = widget.event.event_date_end;
    tagId = widget.event.tag_id;
    tagListJson().then((value) {
      setState(() {
        tagList.addAll(value);
        dropdownValue = tagFindName(widget.event.tag_id);
      });
    });
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
        tagId!,
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
              DropdownButton<String>(
                value: dropdownValue,
                elevation: 16,
                menuMaxHeight: 100,
                onChanged: (String? value) {
                  setState(() {
                    dropdownValue = value!;
                    tagId = tagFindId(value);
                  });
                },
                items: tagWithNameList()
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
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
                    await updateEvent(widget.event);
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
