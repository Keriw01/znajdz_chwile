import 'dart:convert';
import 'dart:ffi';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:znajdz_chwile/colors/colors.dart';

import '../api_connection/api_connection.dart';
import '../models/event.dart';
import '../models/stats.dart';
import '../models/user.dart';
import '../users/userPreferences/user_preferences.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  @override
  void initState() {
    super.initState();
  }

  late Stats actualStats;
  Widget legendElement(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          color: color,
        ),
        const SizedBox(
          width: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Text(title),
        )
      ],
    );
  }

  late final List<Widget> legendList = [
    legendElement("Ilość wszystkich\nzdarzeń", Colors.red),
    legendElement("Ilość zdarzeń\nukończonych", Colors.yellow),
    legendElement("Ilość zdarzeń\nnie ukończonych", Colors.blue)
  ];
  saveStatsToDatabase() async {
    Future<User?> userInfo = RememberUserPrefs.readUserInfo();
    User? currentUserInfo = await userInfo;
    var response = await http.post(Uri.parse(API.infoAboutEvents), body: {
      'user_id': currentUserInfo?.user_id.toString(),
    });
    if (response.statusCode == 200) {
      var responseBodyOfEventList = jsonDecode(response.body);
      if (responseBodyOfEventList["success"] == true) {
        actualStats = Stats(
            1,
            currentUserInfo?.user_id,
            int.parse(responseBodyOfEventList["eventData"]["amount_events"]),
            int.parse(
                responseBodyOfEventList["eventData"]["amount_ended_events"]),
            int.parse(responseBodyOfEventList["eventData"]
                ["amount_no_ended_events"]));
      }
    }
    await http.post(Uri.parse(API.saveStats), body: actualStats.toJson());
  }

  Widget generatePieChar(Stats stats) {
    List<PieChartSectionData> pieChartData = [
      PieChartSectionData(
          value: stats.amount_events.toDouble(), color: Colors.red),
      PieChartSectionData(
          value: stats.amount_ended_events.toDouble(), color: Colors.yellow),
      PieChartSectionData(
          value: stats.amount_no_ended_events.toDouble(), color: Colors.blue),
    ];
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 1,
              child: AspectRatio(
                aspectRatio: 2,
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
                flex: 1,
                child: Wrap(
                  children: legendList,
                ))
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: color2,
        body: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Center(
            child: FutureBuilder(
              future: saveStatsToDatabase(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return generatePieChar(actualStats);
                }
              },
            ),
          ),
        ));
  }
}
