// ignore_for_file: non_constant_identifier_names

class Event {
  int event_id;
  int user_id;
  String event_title;

  Event(this.event_id, this.user_id, this.event_title);

  factory Event.fromJson(Map<String, dynamic> json) => Event(
      int.parse(json['event_id']),
      int.parse(json['user_id']),
      json['event_title']);

  Map<String, dynamic> toJson() => {
        'event_id': event_id.toString(),
        'user_id': user_id.toString(),
        'event_title': event_title,
      };
}
