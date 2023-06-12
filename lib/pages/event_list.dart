import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:znajdz_chwile/colors/colors.dart';
import 'package:znajdz_chwile/provider/events_provider.dart';
import '../models/event.dart';
import 'package:intl/intl.dart';
import '../services/event_service.dart';
import 'edit_event.dart';

class EventListSection extends StatefulWidget {
  final DateTime selectedDay;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final bool rangeSelect;
  const EventListSection(
      {required this.selectedDay,
      required this.rangeStart,
      required this.rangeEnd,
      required this.rangeSelect,
      super.key});

  @override
  State<EventListSection> createState() => _EventListSectionState();
}

class _EventListSectionState extends State<EventListSection> {
  @override
  Widget build(BuildContext context) {
    return Consumer<EventsProvider>(
      builder: (context, eventProvider, _) {
        if (eventProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: color8,
            ),
          );
        } else if (eventProvider.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              children: [
                const Text('An error occured:'),
                Text(eventProvider.errorMessage),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Refresh data'),
                )
              ],
            ),
          );
        } else {
          if (widget.rangeSelect == true) {
            List<Event> sortedEventsByRange = eventProvider
                .filterEventsForDateRange(widget.rangeStart, widget.rangeEnd);
            return ListView.builder(
                itemCount: sortedEventsByRange.length,
                itemBuilder: (_, index) {
                  Event event = sortedEventsByRange[index];
                  return eventCustomElementOfList(
                      context, event, widget.rangeSelect);
                });
          } else {
            List<Event> sortedEventsByDay =
                eventProvider.filterEventsForSelectedDay(widget.selectedDay);
            return ListView.builder(
                itemCount: sortedEventsByDay.length,
                itemBuilder: (_, index) {
                  Event event = sortedEventsByDay[index];
                  return eventCustomElementOfList(
                      context, event, widget.rangeSelect);
                });
          }
        }
      },
    );
  }

  Widget eventCustomElementOfList(
      BuildContext context, Event event, bool rangeSelect) {
    final provider = Provider.of<EventsProvider>(context, listen: false);
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
                    GestureDetector(
                      onTap: () {
                        provider.checkEvent(event);
                        eventCheckBoxToDatabase(event);
                      },
                      child: event.eventIsDone == 1
                          ? const Icon(
                              Icons.check_box,
                              size: 40,
                              color: color3,
                            )
                          : const Icon(
                              Icons.square,
                              size: 40,
                              color: color3,
                            ),
                    )
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
              flex: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: Row(children: [
                      if (event.eventIsDone == 1)
                        Expanded(
                          flex: 4,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Text(
                              event.eventTitle,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'OpenSans',
                                  fontWeight: FontWeight.bold,
                                  decorationThickness: 3,
                                  decoration: TextDecoration.lineThrough),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          flex: 4,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Text(
                              event.eventTitle,
                              style: const TextStyle(
                                fontSize: 18,
                                fontFamily: 'OpenSans',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                          flex: 2,
                          child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Text(
                                provider.tagFindName(event.tagId),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'OpenSans',
                                  fontWeight: FontWeight.bold,
                                ),
                              )))
                    ]),
                  ),
                  if (event.eventDateStart != event.eventDateEnd &&
                      rangeSelect == true)
                    Text(
                      "${DateFormat('HH:mm dd-MM-yyyy').format(event.eventDateStart)} - ${DateFormat('HH:mm dd-MM-yyyy').format(event.eventDateEnd)}",
                      style: const TextStyle(
                          fontSize: 10,
                          fontFamily: 'Montserrat',
                          color: color7),
                    )
                  else
                    Text(DateFormat('HH:mm').format(event.eventDateStart),
                        style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                            color: color7)),
                  Expanded(
                      flex: 4,
                      child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Text(event.eventDescription,
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
                                    "Czy napewno chcesz usunąć to wydarzenie?"),
                                actions: <Widget>[
                                  TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text(
                                        "Cofnij",
                                        style: TextStyle(color: color7),
                                      )),
                                  TextButton(
                                      onPressed: () {
                                        deleteEventFromDatabase(event)
                                            .then((result) {
                                          if (result == true) {
                                            provider.deleteEvent(event);
                                          } else {
                                            Fluttertoast.showToast(
                                                msg: "Błąd, spróbuj ponownie");
                                          }
                                        }).catchError((error) {
                                          Fluttertoast.showToast(
                                              msg: error.toString());
                                        });
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Usuń",
                                          style: TextStyle(color: color6)))
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
}
