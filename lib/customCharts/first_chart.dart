
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../api_connection/api_connection.dart';
import '../colors/colors.dart';
import '../models/stats.dart';
import '../models/user.dart';
import '../users/userPreferences/user_preferences.dart';
import 'legend_for_charts.dart';

class FirstChartAboutUser extends StatefulWidget {
  const FirstChartAboutUser({super.key});

  @override
  State<FirstChartAboutUser> createState() => _FirstChartAboutUserState();
}

late Stats actualStats;

final List<Widget> legendList = [
  legendElement("Ilość wszystkich zdarzeń", color5),
  legendElement("Ilość zdarzeń ukończonych", color6),
  legendElement("Ilość zdarzeń nie ukończonych", color4)
];

saveStatsToDatabase() async {
  Future<User?> userInfo = RememberUserPrefs.readUserInfo();
  User? currentUserInfo = await userInfo;
  var response = await http.post(Uri.parse(API.infoAboutEvents), body: {
    'user_id': currentUserInfo?.user_id.toString(),
  });
  if (response.statusCode == 200) {
    var responseBodyOfEventCount = jsonDecode(response.body);
    if (responseBodyOfEventCount["success"] == true) {
      actualStats = Stats(
          1,
          currentUserInfo!.user_id,
          int.parse(responseBodyOfEventCount["eventData"]["amount_events"]),
          int.parse(
              responseBodyOfEventCount["eventData"]["amount_ended_events"]),
          int.parse(
              responseBodyOfEventCount["eventData"]["amount_no_ended_events"]));
    }
  }
  await http.post(Uri.parse(API.saveStats), body: actualStats.toJson());
}

Widget generatePieChar(Stats stats) {
  List<PieChartSectionData> pieChartData = [
    PieChartSectionData(value: stats.amount_events.toDouble(), color: color5),
    PieChartSectionData(
        value: stats.amount_ended_events.toDouble(), color: color6),
    PieChartSectionData(
        value: stats.amount_no_ended_events.toDouble(), color: color4),
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
                children: legendList,
              ))
        ],
      ),
    ],
  );
}

class _FirstChartAboutUserState extends State<FirstChartAboutUser> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: saveStatsToDatabase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
            color: color8,
          ));
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return generatePieChar(actualStats);
        }
      },
    );
  }
}
