class NotificationEvent {
  int notification_id;
  int event_id;
  String notification_title;
  String notification_description;
  DateTime notification_date_time;

  NotificationEvent(
      this.notification_id,
      this.event_id,
      this.notification_title,
      this.notification_description,
      this.notification_date_time);

  factory NotificationEvent.fromJson(Map<String, dynamic> json) =>
      NotificationEvent(
          int.parse(json['notification_id']),
          int.parse(json['event_id']),
          json['notification_title'],
          json['notification_description'],
          DateTime.parse(json['notification_date_time']));

  Map<String, dynamic> toJson() => {
        'notification_id': notification_id.toString(),
        'event_id': event_id.toString(),
        'notification_title': notification_title,
        'notification_description': notification_description,
        'notification_date_time': notification_date_time.toString(),
      };
}
