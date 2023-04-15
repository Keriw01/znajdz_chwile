import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:znajdz_chwile/api_connection/api_connection.dart';
import 'package:znajdz_chwile/colors/colors.dart';
import 'package:znajdz_chwile/pages/edit_event.dart';
import 'package:znajdz_chwile/users/userPreferences/user_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../models/event.dart';
import '../models/user.dart';

class HomeSecond extends StatefulWidget {
  const HomeSecond({super.key});

  @override
  State<HomeSecond> createState() => _HomeSecondState();
}

class _HomeSecondState extends State<HomeSecond> {
  DateTime _selectedDay = DateTime.now();
  var _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  final List<Event> eventList = [];

  Widget dateHeader(DateTime date) {
    String formattedDate =
        "${DateFormat.d('pl-PL').format(date)} ${DateFormat.EEEE('pl-PL').format(date)}, ${DateFormat.MMMM('pl-PL').format(date)}";

    return Text(
      formattedDate,
      style: const TextStyle(
          fontSize: 22, fontFamily: 'OpenSans', fontWeight: FontWeight.w600),
    );
  }

  eventCheckBoxHandle(Event event) async {
    Future<User?> userInfo = RememberUserPrefs.readUserInfo();
    User? currentUserInfo = await userInfo;
    var response = await http.post(Uri.parse(API.eventCheck), body: {
      'user_id': currentUserInfo?.user_id.toString(),
      'event_id': event.event_id.toString(),
      'event_is_done': event.event_is_done == 1 ? "0" : "1"
    });
    if (response.statusCode == 200) {
      var responseBodyOfEventList = jsonDecode(response.body);
      if (responseBodyOfEventList["success"] == false) {
        Fluttertoast.showToast(msg: "Nie udało się zmienić checkboxa");
      }
    }

    setState(() {
      eventListJson().then((value) {
        setState(() {
          eventList.clear();
          eventList.addAll(value);
        });
      });
    });
  }

  deleteEvent(Event event) async {
    Future<User?> userInfo = RememberUserPrefs.readUserInfo();
    User? currentUserInfo = await userInfo;
    var response = await http.post(Uri.parse(API.eventDelete), body: {
      'user_id': currentUserInfo?.user_id.toString(),
      'event_id': event.event_id.toString(),
    });
    if (response.statusCode == 200) {
      var responseBodyOfEventList = jsonDecode(response.body);
      if (responseBodyOfEventList["success"] == false) {
        Fluttertoast.showToast(msg: "Nie udało się usunąć");
      }
    }

    setState(() {
      eventListJson().then((value) {
        setState(() {
          eventList.clear();
          eventList.addAll(value);
        });
      });
    });
  }

  Widget eventCustomElementOfList(Event event) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 15.0),
      child: Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)), color: color3),
        width: MediaQuery.of(context).size.width,
        height: 80,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: const BoxDecoration(
                    color: color6,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        bottomLeft: Radius.circular(20.0))),
                height: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    event.event_is_done == 1
                        ? GestureDetector(
                            onTap: () {
                              eventCheckBoxHandle(event);
                            },
                            child: const Icon(
                              Icons.check_box,
                              size: 40,
                              color: color3,
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              eventCheckBoxHandle(event);
                            },
                            child: const Icon(
                              Icons.square,
                              size: 40,
                              color: color3,
                            ),
                          ),
                  ],
                ),
              ),
            ),
            const Expanded(
              flex: 2,
              child: Icon(
                Icons.calendar_today,
                size: 30,
              ),
            ),
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    event.event_title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'OpenSans',
                        fontWeight: FontWeight.bold),
                  ),
                  event.event_date_start != event.event_date_end
                      ? Text(
                          "${DateFormat('HH:mm').format(event.event_date_start)} - ${DateFormat('HH:mm dd-MM-yyyy').format(event.event_date_end)}",
                          style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Montserrat',
                              color: color7),
                        )
                      : Text(DateFormat('HH:mm').format(event.event_date_start),
                          //"${event.event_date_start.hour}:${event.event_date_start.minute}",
                          style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Montserrat',
                              color: color7)),
                  Expanded(
                      child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Text(event.event_description,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Segoe UI',
                                  color: color7))))
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Usuwanie wydarzenia"),
                                content: const Text(
                                    "Czy napewno chcesz usunąc to wydarzenie?"),
                                actions: <Widget>[
                                  TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Cofnij")),
                                  TextButton(
                                      onPressed: () {
                                        deleteEvent(event);
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Usuń"))
                                ],
                              );
                            });
                      },
                      child: const Icon(
                        Icons.delete,
                        size: 30,
                      ))
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.to(() => EditEventPage(
                            event: event,
                          ));
                    },
                    child: const Icon(
                      Icons.more_vert,
                      size: 30,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<List<Event>> eventListJson() async {
    Future<User?> userInfo = RememberUserPrefs.readUserInfo();
    User? currentUserInfo = await userInfo;
    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDay);
    var response = await http.post(Uri.parse(API.eventsList), body: {
      'user_id': currentUserInfo?.user_id.toString(),
      'event_date_start': formattedDate
    });
    List<Event> eventList = [];
    if (response.statusCode == 200) {
      var responseBodyOfEventList = jsonDecode(response.body);
      if (responseBodyOfEventList["success"] == true) {
        for (var jsondata in responseBodyOfEventList["data"]) {
          eventList.add(Event.fromJson(jsondata));
        }
      }
    }

    return eventList;
  }

  @override
  void initState() {
    eventListJson().then((value) {
      setState(() {
        eventList.addAll(value);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('pl_PL', null);
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
              color: color6,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0))),
          child: TableCalendar(
            locale: 'pl_PL',
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            availableCalendarFormats: const {
              CalendarFormat.week: 'Tydzień',
              CalendarFormat.twoWeeks: '2 Tygodnie',
              CalendarFormat.month: 'Miesiąc',
            },
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                eventListJson().then((value) {
                  setState(() {
                    eventList.clear();
                    eventList.addAll(value);
                  });
                });
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: const CalendarStyle(
                withinRangeTextStyle: TextStyle(color: Colors.red),
                outsideTextStyle:
                    TextStyle(color: Color.fromARGB(193, 151, 151, 151)),
                weekendTextStyle: TextStyle(color: color7),
                defaultTextStyle: TextStyle(color: Colors.black),
                todayDecoration:
                    BoxDecoration(color: color7, shape: BoxShape.circle),
                todayTextStyle: TextStyle(color: Colors.white),
                selectedDecoration:
                    BoxDecoration(color: color2, shape: BoxShape.circle),
                selectedTextStyle: TextStyle(color: Colors.black)),
            daysOfWeekStyle:
                DaysOfWeekStyle(weekdayStyle: TextStyle(color: Colors.black)),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
          child: dateHeader(_focusedDay),
        ),
        Expanded(
          child: ListView.builder(
            itemBuilder: (context, index) {
              return eventCustomElementOfList(eventList[index]);
            },
            itemCount: eventList.length,
          ),
        ),
      ],
    );
  }
}
