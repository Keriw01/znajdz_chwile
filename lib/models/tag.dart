class Tag {
  int tag_id;
  int user_id;
  String tag_name;
  Tag(this.tag_id, this.user_id, this.tag_name);

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
      int.parse(json['tag_id']), int.parse(json['user_id']), json['tag_name']);

  Map<String, dynamic> toJson() => {
        'tag_id': tag_id.toString(),
        'user_id': user_id.toString(),
        'tag_name': tag_name,
      };
}
