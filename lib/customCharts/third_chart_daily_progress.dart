
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../api_connection/api_connection.dart';
import '../colors/colors.dart';
import '../models/user.dart';
import '../users/userPreferences/user_preferences.dart';
import 'legend_for_charts.dart';

class ThirdChartDailyProgress extends StatefulWidget {
  const ThirdChartDailyProgress({super.key});

  @override
  State<ThirdChartDailyProgress> createState() =>
      _ThirdChartDailyProgressState();
}

final List<Widget> legendListSecond = [
  legendElement("Ilość wszystkich zdarzeń", color5),
  legendElement("Ilość zdarzeń ukończonych", color6),
];

int todayEventAmountCreated = 0;
int todayEventAmountEnded = 0;

readAmountEventToday() async {
  Future<User?> userInfo = RememberUserPrefs.readUserInfo();
  User? currentUserInfo = await userInfo;
  DateTime now = DateTime.now();
  var response = await http.post(Uri.parse(API.infoAboutEventsPerDay), body: {
    'user_id': currentUserInfo?.user_id.toString(),
    'day': now.day.toString(),
    'month': now.month.toString(),
    'year': now.year.toString()
  });
  if (response.statusCode == 200) {
    var responseBody = jsonDecode(response.body);
    if (responseBody["success"] == true) {
      todayEventAmountCreated =
          int.parse(responseBody["eventData"]["amount_events"]);
      todayEventAmountEnded =
          int.parse(responseBody["eventData"]["amount_done_events"]);
    }
  }
}

Widget generatePieChartThird() {
  List<PieChartSectionData> pieChartData = [
    PieChartSectionData(
        value: todayEventAmountCreated.toDouble(), color: color5),
    PieChartSectionData(value: todayEventAmountEnded.toDouble(), color: color6),
  ];
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

class _ThirdChartDailyProgressState extends State<ThirdChartDailyProgress> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: readAmountEventToday(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
            color: color8,
          ));
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return generatePieChartThird();
        }
      },
    );
  }
}
