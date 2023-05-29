class Event {
  int eventId;
  int userId;
  int tagId;
  String eventTitle;
  String eventDescription;
  DateTime eventDateStart;
  DateTime eventDateEnd;
  int eventIsDone;
  int eventNotification;

  Event(
      {required this.eventId,
      required this.userId,
      required this.tagId,
      required this.eventTitle,
      required this.eventDescription,
      required this.eventDateStart,
      required this.eventDateEnd,
      this.eventIsDone = 0,
      this.eventNotification = 0});

  factory Event.fromJson(Map<String, dynamic> json) => Event(
      eventId: int.parse(json['event_id'] as String),
      userId: int.parse(json['user_id'] as String),
      tagId: int.parse(json['tag_id'] as String),
      eventTitle: json['event_title'] as String,
      eventDescription: json['event_description'] as String,
      eventDateStart: DateTime.parse(json['event_date_start'] as String),
      eventDateEnd: DateTime.parse(json['event_date_end'] as String),
      eventIsDone: int.parse(json['event_is_done'] as String),
      eventNotification: int.parse(json['event_notification'] as String));

  Map<String, dynamic> toJson() => {
        'event_id': eventId.toString(),
        'user_id': userId.toString(),
        'tag_id': tagId.toString(),
        'event_title': eventTitle,
        'event_description': eventDescription,
        'event_date_start': eventDateStart.toString(),
        'event_date_end': eventDateEnd.toString(),
        'event_is_done': eventIsDone.toString(),
        'event_notification': eventNotification.toString(),
      };
}
