// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:znajdz_chwile/colors/colors.dart';
import 'package:znajdz_chwile/pages/event_list.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class HomeSecond extends StatefulWidget {
  const HomeSecond({super.key});

  @override
  State<HomeSecond> createState() => _HomeSecondState();
}

class _HomeSecondState extends State<HomeSecond> {
  var _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  bool rangeSelect = false;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  CalendarFormat _calendarFormat = CalendarFormat.twoWeeks;

  Widget dateHeader(DateTime dateSelected) {
    String formattedDate =
        "${DateFormat.d('pl-PL').format(dateSelected)} ${DateFormat.EEEE('pl-PL').format(dateSelected)}, ${DateFormat.MMMM('pl-PL').format(dateSelected)}";

    return Text(
      formattedDate,
      style: const TextStyle(
          fontSize: 22, fontFamily: 'OpenSans', fontWeight: FontWeight.w600),
    );
  }

  Widget dateRangeHeader(DateTime dateRangeStart, DateTime dateRangeEnd) {
    String formattedDate =
        "${DateFormat.d('pl-PL').format(dateRangeStart)} ${DateFormat.EEEE('pl-PL').format(dateRangeStart)}, ${DateFormat.MMMM('pl-PL').format(dateRangeStart)} - ${DateFormat.d('pl-PL').format(dateRangeEnd)} ${DateFormat.EEEE('pl-PL').format(dateRangeEnd)}, ${DateFormat.MMMM('pl-PL').format(dateRangeEnd)}";

    return Text(
      formattedDate,
      style: const TextStyle(
          fontSize: 16, fontFamily: 'OpenSans', fontWeight: FontWeight.w600),
    );
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('pl_PL', null);
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
                color: color6,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0))),
            child: TableCalendar(
              availableGestures: AvailableGestures.none,
              locale: 'pl_PL',
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              rangeStartDay: _rangeStart,
              rangeEndDay: _rangeEnd,
              rangeSelectionMode: _rangeSelectionMode,
              calendarFormat: _calendarFormat,
              availableCalendarFormats: const {
                CalendarFormat.week: 'Miesiąc',
                CalendarFormat.twoWeeks: 'Tydzień',
                CalendarFormat.month: '2 Tygodnie',
              },
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _rangeStart = null;
                    _rangeEnd = null;
                    rangeSelect = false;
                    _rangeSelectionMode = RangeSelectionMode.toggledOff;
                  });
                }
              },
              onRangeSelected: (start, end, focusedDay) {
                setState(() {
                  _selectedDay = start;
                  rangeSelect = true;
                  _focusedDay = focusedDay;
                  _rangeStart = start;
                  _rangeEnd = end;
                  _rangeSelectionMode = RangeSelectionMode.toggledOn;
                });
                if (end != null) {
                  rangeSelect = true;
                } else {
                  rangeSelect = false;
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
                  tablePadding: EdgeInsets.only(bottom: 25),
                  outsideTextStyle:
                      TextStyle(color: Color.fromARGB(193, 151, 151, 151)),
                  weekendTextStyle: TextStyle(color: color7),
                  defaultTextStyle: TextStyle(color: Colors.black),
                  todayDecoration:
                      BoxDecoration(color: color7, shape: BoxShape.circle),
                  todayTextStyle: TextStyle(color: Colors.white),
                  selectedDecoration:
                      BoxDecoration(color: color2, shape: BoxShape.circle),
                  selectedTextStyle: TextStyle(color: Colors.black),
                  rangeStartDecoration:
                      BoxDecoration(color: color2, shape: BoxShape.circle),
                  rangeStartTextStyle: TextStyle(color: Colors.black),
                  rangeEndDecoration:
                      BoxDecoration(color: color2, shape: BoxShape.circle),
                  rangeEndTextStyle: TextStyle(color: Colors.black),
                  withinRangeDecoration:
                      BoxDecoration(color: color2, shape: BoxShape.circle),
                  withinRangeTextStyle: TextStyle(color: Colors.black),
                  rangeHighlightColor: color2),
              daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.black)),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
            child: (_rangeStart != null &&
                    _rangeEnd != null &&
                    rangeSelect == true)
                ? dateRangeHeader(_rangeStart!, _rangeEnd!)
                : dateHeader(_focusedDay),
          ),
          Expanded(
              child: EventListSection(
            selectedDay: _selectedDay ?? DateTime.now(),
            rangeStart: _rangeStart ?? DateTime.now(),
            rangeEnd: _rangeEnd ?? DateTime.now(),
            rangeSelect: rangeSelect,
          )),
        ],
      ),
    );
  }
}
