import 'package:flutter/material.dart';
import 'package:znajdz_chwile/services/event_service.dart';
import 'package:znajdz_chwile/services/tag_service.dart';
import '../models/event.dart';
import '../models/tag.dart';

class EventsProvider extends ChangeNotifier {
  final List<Event> _events = [];
  List<Event> get events => _events;

  final List<Tag> _tags = [];
  List<Tag> get tags => _tags;

  String _selectedTag = '';
  String get selectedTag => _selectedTag;

  int _tagId = 1;
  int get tagId => _tagId;

  String _tagName = "empty";
  String get tagName => _tagName;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final String _errorMessage = '';
  String get errorMessage => _errorMessage;

  EventsProvider() {
    _fetchEvents();
    _fetchTags();
  }

  Future<void> _fetchEvents() async {
    _isLoading = true;
    await loadEventsFromDatabase(_events, _errorMessage);
  }

  Future<void> _fetchTags() async {
    await loadTagsFromDatabase(_tags, _errorMessage);
    _isLoading = false;
    notifyListeners();
  }

  List<Event> filterEventsForDateRange(DateTime rangeStart, DateTime rangeEnd) {
    rangeEnd =
        rangeEnd.add(const Duration(hours: 23, minutes: 59, seconds: 59));
    return events
        .where((event) =>
            event.eventDateStart.isAfter(rangeStart) &&
            event.eventDateEnd.isBefore(rangeEnd))
        .toList()
      ..sort((a, b) => a.eventDateStart.compareTo(b.eventDateStart));
  }

  List<Event> filterEventsForSelectedDay(DateTime selectedDay) {
    return events
        .where((event) =>
            event.eventDateStart.day == selectedDay.day &&
            event.eventDateStart.month == selectedDay.month &&
            event.eventDateStart.year == selectedDay.year)
        .toList()
      ..sort((a, b) => a.eventDateStart.compareTo(b.eventDateStart));
  }

  void deleteEvent(Event event) {
    _events.removeWhere((element) => element.eventId == event.eventId);
    notifyListeners();
  }

  void checkEvent(Event event) {
    for (var element in events) {
      if (element.eventId == event.eventId) {
        if (element.eventIsDone == 1) {
          element.eventIsDone = 0;
        } else {
          element.eventIsDone = 1;
        }
      }
    }
    notifyListeners();
  }

  List<String> get listTagWithName {
    return _tags.map((tag) => tag.tag_name).toList();
  }

  set selectedTag(String value) {
    _selectedTag = value;
    notifyListeners();
  }

  set tagId(int value) {
    _tagId = value;
    notifyListeners();
  }

  int tagFindId(String tagName) {
    for (var element in tags) {
      if (element.tag_name == tagName) {
        tagId = element.tag_id;
        break;
      }
    }
    return tagId;
  }

  String tagFindName(int tagId) {
    String tagName = "empty";
    for (var element in tags) {
      if (element.tag_id == tagId) {
        tagName = element.tag_name;
        break;
      }
    }
    return tagName;
  }

  void addEvent(Event event) {
    events.add(event);
    notifyListeners();
  }

  void updateEvent(Event event) {
    for (var i = 0; i < events.length; i++) {
      if (events[i].eventId == event.eventId) {
        events[i] = event;
        break;
      }
    }
    notifyListeners();
  }
}
