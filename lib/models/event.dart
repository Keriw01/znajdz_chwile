// ignore_for_file: non_constant_identifier_names

class Event {
  int event_id;
  int user_id;
  String event_title;
  String event_description;
  DateTime event_date_start;
  DateTime event_date_end;
  int event_is_done = 0;
  int event_notification = 0;

  Event(
      this.event_id,
      this.user_id,
      this.event_title,
      this.event_description,
      this.event_date_start,
      this.event_date_end,
      this.event_is_done,
      this.event_notification);

  factory Event.fromJson(Map<String, dynamic> json) => Event(
      int.parse(json['event_id']),
      int.parse(json['user_id']),
      json['event_title'],
      json['event_description'],
      DateTime.parse(json['event_date_start']),
      DateTime.parse(json['event_date_end']),
      int.parse(json['event_is_done']),
      int.parse(json['event_notification']));

  Map<String, dynamic> toJson() => {
        'event_id': event_id.toString(),
        'user_id': user_id.toString(),
        'event_title': event_title,
        'event_description': event_description,
        'event_date_start': event_date_start.toString(),
        'event_date_end': event_date_end.toString(),
        'event_is_done': event_is_done.toString(),
        'event_notification': event_notification.toString(),
      };
}
