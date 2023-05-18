import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StatsPage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TaskListScreen(),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<String> tasks = [];
  int completedTasks = 0;
  int totalTasks = 0;
  DateTime? startDate;
  DateTime? endDate;

  void updateTaskStats() {
    // Tutaj można zaktualizować wartości completedTasks i totalTasks na podstawie danych z API
    // W tym przykładzie, losowo generujemy wartości
    completedTasks = 50; // przykładowa wartość zadań wykonanych
    totalTasks = 100; // przykładowa wartość wszystkich zadań
    setState(() {});
  }

  double calculateProgress() {
    if (totalTasks == 0) {
      return 0.0;
    }
    return completedTasks / totalTasks;
  }

  void fetchData(DateTime startDate, DateTime endDate) {
    // Tutaj można wywołać odpowiednie API i pobrać dane dla określonego zakresu czasowego
    // W tym przykładzie pomijamy to i tylko wyświetlamy zakres czasowy
    tasks.clear();
    tasks.add('Dane dla zakresu: $startDate - $endDate');
    setState(() {});
  }

  void showDateTimePickerStart(BuildContext context) {
    DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      minTime: DateTime(2000, 1, 1),
      maxTime: DateTime(2030, 6, 7),
      onChanged: (date) {},
      onConfirm: (date) {
        setState(() {
          startDate = date;
        });
      },
      currentTime: DateTime.now(),
      locale: LocaleType.pl,
    );
  }

  void showDateTimePickerEnd(BuildContext context) {
    DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      minTime: DateTime(2000, 1, 1),
      maxTime: DateTime(2030, 6, 7),
      onChanged: (date) {},
      onConfirm: (date) {
        setState(() {
          endDate = date;
        });
      },
      currentTime: DateTime.now(),
      locale: LocaleType.pl,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista Zadań'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  DateTime now = DateTime.now();
                  DateTime startDate = now.subtract(Duration(days: 7));
                  fetchData(startDate, now);
                },
                child: Text('TYDZIEŃ'),
              ),
              ElevatedButton(
                onPressed: () {
                  DateTime now = DateTime.now();
                  DateTime startDate = now.subtract(Duration(days: 31));
                  fetchData(startDate, now);
                },
                child: Text('MIESIĄC'),
              ),
              ElevatedButton(
                onPressed: () {
                  DateTime now = DateTime.now();
                  DateTime startDate = now.subtract(Duration(days: 365));
                  fetchData(startDate, now);
                },
                child: Text('ROK'),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text('Wpisz zakres czasowy:'),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  showDateTimePickerStart(context);
                },
                child: Text('Początek'),
              ),
              ElevatedButton(
                onPressed: () {
                  showDateTimePickerEnd(context);
                },
                child: Text('Koniec'),
              ),
              ElevatedButton(
                onPressed: () {
                  fetchData(startDate!, endDate!);
                },
                child: Text('OK'),
              ),
            ],
          ),
          
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(tasks[index]),
                );
              },
            ),
          ),
          SizedBox(height: 20),
          Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Text(
                'Wykonane',
                style: TextStyle(fontSize: 24, color: Colors.green),
              ),
              Text(
                completedTasks.toString(),
                style: TextStyle(fontSize: 48, color: Colors.green),
              ),
            ],
          ),
          SizedBox(width: 20),
          Column(
            children: [
              Text(
                'Niewykonane',
                style: TextStyle(fontSize: 24, color: Colors.red),
              ),
              Text(
                (totalTasks - completedTasks).toString(),
                style: TextStyle(fontSize: 48, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
      SizedBox(height: 20),
      LinearProgressIndicator(
        value: calculateProgress(),
      ),
      SizedBox(height: 20),
      ElevatedButton(
        onPressed: updateTaskStats,
        child: Text('Aktualizuj Statystyki'),
      ),
    ],
  ),
),
        ],
      ),
    );
  }
}