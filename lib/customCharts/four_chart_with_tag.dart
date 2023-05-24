
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../api_connection/api_connection.dart';
import '../colors/colors.dart';
import '../models/user.dart';
import '../users/userPreferences/user_preferences.dart';
import 'legend_for_charts.dart';

class FourChartWithTag extends StatefulWidget {
  const FourChartWithTag({super.key});
  @override
  State<FourChartWithTag> createState() => _FourChartWithTagState();
}

String tag = "praca";

final List<Widget> legendListSecond = [
  legendElement("Ilość wszystkich zdarzeń", color5),
  legendElement("Ilość zdarzeń ukończonych", color6),
];

Map<String, dynamic> mapTag = {
  "praca": {
    "amount_event": [0],
    "amount_ended_event": [0],
  },
  "szkola": {
    "amount_event": [0],
    "amount_ended_event": [0],
  },
  "dom": {
    "amount_event": [0],
    "amount_ended_event": [0],
  }
};

readAmountEventWithTag() async {
  Future<User?> userInfo = RememberUserPrefs.readUserInfo();
  User? currentUserInfo = await userInfo;
  var response = await http.post(Uri.parse(API.infoAboutEventsWithTag), body: {
    'user_id': currentUserInfo?.user_id.toString(),
  });
  if (response.statusCode == 200) {
    var responseBody = jsonDecode(response.body);
    if (responseBody["success"] == true) {
      mapTag["praca"]["amount_event"][0] =
          int.parse(responseBody["eventData"]["amount_events_work"]);
      mapTag["praca"]["amount_ended_event"][0] =
          int.parse(responseBody["eventData"]["amount_events_work_ended"]);
      mapTag["szkola"]["amount_event"][0] =
          int.parse(responseBody["eventData"]["amount_events_school"]);
      mapTag["szkola"]["amount_ended_event"][0] =
          int.parse(responseBody["eventData"]["amount_events_school_ended"]);
      mapTag["dom"]["amount_event"][0] =
          int.parse(responseBody["eventData"]["amount_events_home"]);
      mapTag["dom"]["amount_ended_event"][0] =
          int.parse(responseBody["eventData"]["amount_events_home_ended"]);
    }
  }
}

Widget generatePieChartFour(String tag) {
  List<PieChartSectionData> pieChartData = [];
  if (tag == "praca") {
    pieChartData = [
      PieChartSectionData(
          value: mapTag["praca"]["amount_event"][0].toDouble(), color: color5),
      PieChartSectionData(
          value: mapTag["praca"]["amount_ended_event"][0].toDouble(),
          color: color6),
    ];
  } else if (tag == "szkola") {
    pieChartData = [
      PieChartSectionData(
          value: mapTag["szkola"]["amount_event"][0].toDouble(), color: color5),
      PieChartSectionData(
          value: mapTag["szkola"]["amount_ended_event"][0].toDouble(),
          color: color6),
    ];
  } else if (tag == "dom") {
    pieChartData = [
      PieChartSectionData(
          value: mapTag["dom"]["amount_event"][0].toDouble(), color: color5),
      PieChartSectionData(
          value: mapTag["dom"]["amount_ended_event"][0].toDouble(),
          color: color6),
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

class _FourChartWithTagState extends State<FourChartWithTag> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    tag = "praca";
                  });
                },
                style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.fromLTRB(25, 10, 25, 10)),
                    backgroundColor: MaterialStateProperty.all(color8),
                    shape: MaterialStateProperty.all(
                        const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0))))),
                child: const Text(
                  'Praca',
                  style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'OpenSans',
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(5.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      tag = "szkola";
                    });
                  },
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(
                          const EdgeInsets.fromLTRB(25, 10, 25, 10)),
                      backgroundColor: MaterialStateProperty.all(color8),
                      shape: MaterialStateProperty.all(
                          const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0))))),
                  child: const Text(
                    'Szkoła',
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'OpenSans',
                        fontWeight: FontWeight.w700),
                  ),
                )),
            Padding(
                padding: const EdgeInsets.all(5.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      tag = "dom";
                    });
                  },
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(
                          const EdgeInsets.fromLTRB(25, 10, 25, 10)),
                      backgroundColor: MaterialStateProperty.all(color8),
                      shape: MaterialStateProperty.all(
                          const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0))))),
                  child: const Text(
                    'Dom',
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'OpenSans',
                        fontWeight: FontWeight.w700),
                  ),
                )),
          ],
        ),
        FutureBuilder(
          future: readAmountEventWithTag(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                color: color8,
              ));
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return generatePieChartFour(tag);
            }
          },
        ),
      ],
    );
  }
}
