import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:znajdz_chwile/api_connection/api_connection.dart';
import 'package:znajdz_chwile/colors/colors.dart';
import 'package:http/http.dart' as http;
import 'package:znajdz_chwile/models/notification.dart';
import 'package:znajdz_chwile/pages/home.dart';
import 'package:znajdz_chwile/pages/home_second.dart';
import 'package:intl/intl.dart';

import '../models/event.dart';
import '../models/tag.dart';
import '../models/user.dart';
import '../services/local_notice_service.dart';
import '../users/userPreferences/user_preferences.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

User? currentUserInfo;

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
  late final List<Tag> tagList = [];
  List<String> tagListName = [];
  String? dropdownValue;
  int? tagId;
  DateTime _eventDateStart = DateTime.now();
  DateTime _eventDateEnd = DateTime.now();
  bool _eventNotification = false;
  int _eventHaveNotification = 0;

  @override
  void initState() {
    super.initState();
    _eventTitleController =
        TextEditingController(text: widget.event.eventTitle.toString());
    _eventDescriptionController =
        TextEditingController(text: widget.event.eventDescription.toString());
    _eventDateStartController = TextEditingController(
        text:
            DateFormat('HH:mm dd-MM-yyyy').format(widget.event.eventDateStart));
    _eventDateEndController = TextEditingController(
        text: DateFormat('HH:mm dd-MM-yyyy').format(widget.event.eventDateEnd));
    widget.event.eventNotification.toString() == "1"
        ? _eventNotification = true
        : _eventNotification = false;
    _eventDateStart = widget.event.eventDateStart;
    _eventDateEnd = widget.event.eventDateEnd;
    tagId = widget.event.tagId;
    tagListJson().then((value) {
      setState(() {
        tagList.addAll(value);
        dropdownValue = tagFindName(widget.event.tagId);
      });
    });
  }

  @override
  void dispose() {
    currentUserInfo = null;
    super.dispose();
  }

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
    int tagId = widget.event.tagId;
    for (var element in tagList) {
      if (element.tag_name == tagName) {
        tagId = element.tag_id;
      }
    }
    return tagId;
  }

  static const OutlineInputBorder borderInput = OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(20),
      ),
      borderSide: BorderSide.none);

  updateEvent(Event event) async {
    Event eventModel = Event(
        eventId: event.eventId,
        userId: event.userId,
        tagId: tagId!,
        eventTitle: _eventTitleController.text.trim(),
        eventDescription: _eventDescriptionController.text.trim(),
        eventDateStart: _eventDateStart,
        eventDateEnd: _eventDateEnd,
        eventIsDone: event.eventIsDone,
        eventNotification: _eventHaveNotification);
    try {
      var response = await http.post(Uri.parse(API.eventUpdate),
          body: eventModel.toJson());
      if (response.statusCode == 200) {
        var responseBodyOfEditEvent = jsonDecode(response.body);
        if (responseBodyOfEditEvent["success"] == true) {
        } else {
          Fluttertoast.showToast(msg: "Błąd, spróbuj ponownie");
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  updateNotifiaction(Event event) async {
//odczyt wszystkich powiadomien
    try {
      var responseNotification =
          await http.post(Uri.parse(API.readNotification), body: {
        'event_id': event.eventId.toString(),
      });
      List<NotificationEvent> notificationsList = [];
      if (responseNotification.statusCode == 200) {
        var responseOfBodyNotification = jsonDecode(responseNotification.body);
        if (responseOfBodyNotification["success"] == true) {
          for (var jsondata in responseOfBodyNotification["data"]) {
            notificationsList.add(NotificationEvent.fromJson(jsondata));
          }
          // update powiadomien
          notificationsList[0].notification_date_time = _eventDateStart;
          notificationsList[0].notification_description =
              _eventDescriptionController.text.trim();
          notificationsList[0].notification_title =
              _eventTitleController.text.trim();
          int i = 0;
          for (var notification in notificationsList) {
            if (i == 0) {
              notification.notification_date_time = _eventDateStart;
            } else {
              notification.notification_date_time = _eventDateEnd;
            }
            i++;
            notification.notification_description =
                _eventDescriptionController.text.trim();
            notification.notification_title = _eventTitleController.text.trim();
            try {
              await http.post(Uri.parse(API.updateNotification),
                  body: notification.toJson());
            } catch (e) {
              Fluttertoast.showToast(msg: e.toString());
            }
          }
        }
      }
      try {
        var responseReadNotification =
            await http.post(Uri.parse(API.readNotification), body: {
          'event_id': event.eventId.toString(),
        });
        List<NotificationEvent> notificationsListSecond = [];
        if (responseReadNotification.statusCode == 200) {
          var responseOfBodyReadNotification =
              jsonDecode(responseReadNotification.body);
          if (responseOfBodyReadNotification["success"] == true) {
            for (var jsondata in responseOfBodyReadNotification["data"]) {
              notificationsListSecond.add(NotificationEvent.fromJson(jsondata));
            }
            for (var notification in notificationsListSecond) {
              NotificationService().showNotification(
                  notification.notification_id,
                  notification.notification_title,
                  notification.notification_description,
                  notification.notification_date_time);
            }
          }
        }
      } catch (e) {
        Fluttertoast.showToast(msg: e.toString());
      }
      Fluttertoast.showToast(msg: "Edytowano zdarzenie.");
      setState(() {
        _eventTitleController.clear();
        _eventDescriptionController.clear();
        _eventDateStartController.clear();
        _eventDateEndController.clear();
        _eventNotification = false;
        _eventHaveNotification = 0;
      });
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
                menuMaxHeight: 50,
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
                    if (_eventNotification == true) {
                      await updateNotifiaction(widget.event);
                    }
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
