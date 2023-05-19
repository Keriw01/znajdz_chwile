// ignore_for_file: non_constant_identifier_names

class Stats {
  int statistics_id;
  int? user_id;
  int amount_events;
  int amount_ended_events;
  int amount_no_ended_events;

  Stats(
    this.statistics_id,
    this.user_id,
    this.amount_events,
    this.amount_ended_events,
    this.amount_no_ended_events,
  );

  factory Stats.fromJson(Map<String, dynamic> json) => Stats(
        int.parse(json['statistics_id']),
        int.parse(json['user_id']),
        int.parse(json['amount_events']),
        int.parse(json['amount_ended_events']),
        int.parse(json['amount_no_ended_events']),
      );

  Map<String, dynamic> toJson() => {
        'statistics_id': statistics_id.toString(),
        'user_id': user_id.toString(),
        'amount_events': amount_events.toString(),
        'amount_ended_events': amount_ended_events.toString(),
        'amount_no_ended_events': amount_no_ended_events.toString(),
      };
}
