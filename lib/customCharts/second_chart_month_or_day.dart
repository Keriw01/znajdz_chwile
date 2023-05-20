
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../api_connection/api_connection.dart';
import '../colors/colors.dart';
import '../models/user.dart';
import '../users/userPreferences/user_preferences.dart';
import 'legend_for_charts.dart';

class SecondChartMonthOrDay extends StatefulWidget {
  const SecondChartMonthOrDay({super.key});
  @override
  State<SecondChartMonthOrDay> createState() => _SecondChartMonthOrDayState();
}

int monthEventAmountEnded = 0;
int dayEventAmountEnded = 0;
int monthEventAmountCreated = 0;
int dayEventAmountCreated = 0;

String monthOrDayEvent = "";
final _eventDateStartController = TextEditingController();
DateTime statsDate = DateTime.now();

final List<Widget> legendListSecond = [
  legendElement("Ilość wszystkich zdarzeń", color5),
  legendElement("Ilość zdarzeń ukończonych", color6),
];

readAmountEventMonthOrDay(String monthOrDayEvent, DateTime statsDate) async {
  Future<User?> userInfo = RememberUserPrefs.readUserInfo();
  User? currentUserInfo = await userInfo;
  if (monthOrDayEvent == "month") {
    var response =
        await http.post(Uri.parse(API.infoAboutEventsPerMonth), body: {
      'user_id': currentUserInfo?.user_id.toString(),
      'month': statsDate.month.toString(),
      'year': statsDate.year.toString()
    });
    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      if (responseBody["success"] == true) {
        monthEventAmountCreated =
            int.parse(responseBody["eventData"]["amount_events"]);
        monthEventAmountEnded =
            int.parse(responseBody["eventData"]["amount_done_events"]);
      }
    }
  } else if (monthOrDayEvent == "day") {
    var response = await http.post(Uri.parse(API.infoAboutEventsPerDay), body: {
      'user_id': currentUserInfo?.user_id.toString(),
      'day': statsDate.day.toString(),
      'month': statsDate.month.toString(),
      'year': statsDate.year.toString()
    });
    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      if (responseBody["success"] == true) {
        dayEventAmountCreated =
            int.parse(responseBody["eventData"]["amount_events"]);
        dayEventAmountEnded =
            int.parse(responseBody["eventData"]["amount_done_events"]);
      }
    }
  }
}

Widget generatePieChartSecond(String monthOrDayEvent) {
  List<PieChartSectionData> pieChartData = [];
  if (monthOrDayEvent == "month") {
    pieChartData = [
      PieChartSectionData(
          value: monthEventAmountCreated.toDouble(), color: color5),
      PieChartSectionData(
          value: monthEventAmountEnded.toDouble(), color: color6),
    ];
  } else if (monthOrDayEvent == "day") {
    pieChartData = [
      PieChartSectionData(
          value: dayEventAmountCreated.toDouble(), color: color5),
      PieChartSectionData(value: dayEventAmountEnded.toDouble(), color: color6),
    ];
  }
  return Column(
    children: [
      Row(
        children: [
          Expanded(
            flex: 1,
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 5,
                  centerSpaceRadius: 20,
                  sections: pieChartData.map((data) {
                    return PieChartSectionData(
                      value: data.value,
                      color: data.color,
                      radius: 30.0,
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          Expanded(
              flex: 2,
              child: Wrap(
                children: legendListSecond,
              ))
        ],
      ),
    ],
  );
}

const OutlineInputBorder borderInput = OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(20),
    ),
    borderSide: BorderSide.none);

class _SecondChartMonthOrDayState extends State<SecondChartMonthOrDay> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Form(
            child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 75.0, right: 75.0),
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
                  labelText: 'Data',
                  labelStyle: TextStyle(color: color8),
                  floatingLabelStyle: TextStyle(color: color8),
                ),
                controller: _eventDateStartController,
                onTap: () {
                  DatePicker.showDatePicker(context,
                      showTitleActions: true,
                      minTime: DateTime(2012, 1, 1),
                      maxTime: DateTime(2030, 6, 7), onChanged: (date) {
                    _eventDateStartController.clear();
                    _eventDateStartController.text =
                        DateFormat('dd-MM-yyyy').format(date);
                    statsDate = date;
                  }, onConfirm: (date) {
                    _eventDateStartController.clear();
                    _eventDateStartController.text =
                        DateFormat('dd-MM-yyyy').format(date);
                    statsDate = date;
                  }, currentTime: DateTime.now(), locale: LocaleType.pl);
                },
              ),
            ),
          ],
        )),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  monthOrDayEvent = "month";
                });
              },
              style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.fromLTRB(25, 10, 25, 10)),
                  backgroundColor: MaterialStateProperty.all(color8),
                  shape: MaterialStateProperty.all(const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0))))),
              child: const Text(
                'Miesiąc',
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'OpenSans',
                    fontWeight: FontWeight.w700),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  monthOrDayEvent = "day";
                });
              },
              style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.fromLTRB(25, 10, 25, 10)),
                  backgroundColor: MaterialStateProperty.all(color8),
                  shape: MaterialStateProperty.all(const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0))))),
              child: const Text(
                'Dzień',
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'OpenSans',
                    fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        FutureBuilder(
          future: readAmountEventMonthOrDay(monthOrDayEvent, statsDate),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                color: color8,
              ));
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return generatePieChartSecond(monthOrDayEvent);
            }
          },
        ),
      ],
    );
  }
}
