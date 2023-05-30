import 'package:flutter/material.dart';
import 'package:znajdz_chwile/colors/colors.dart';
import 'package:znajdz_chwile/customCharts/first_chart.dart';
import 'package:znajdz_chwile/customCharts/second_chart_month_or_day.dart';
import 'package:znajdz_chwile/customCharts/third_chart_daily_progress.dart';
import 'package:znajdz_chwile/customCharts/four_chart_with_tag.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: color2,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(children: const [
              Text("Wykres dla bieżącego użytkownika",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              FirstChartAboutUser(),
              Padding(
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Text(
                  "Wybierz datę, miesiąc/dzień dla którego chcesz zobaczyć ilość zdarzeń wykonanych w porównaniu do wszystkich",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              SecondChartMonthOrDay(),
              SizedBox(
                height: 20,
              ),
              Text("Dzienny postęp: ",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ThirdChartDailyProgress(),
              SizedBox(
                height: 20,
              ),
              FourChartWithTag(),
            ]),
          ),
        ));
  }
}
