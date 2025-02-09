import 'package:kakao_farmer/models/user.dart';

class Notification {
  final int? id;
  final String? title;
  final String? content;
  User? user;
  final String? date;
  final String? readAt;

  Notification(
      {this.id, this.title, this.content, this.user, this.date, this.readAt});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'user': user,
      'date': date,
      'read_at': readAt
    };
  }

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        date: json['date'],
        readAt: json['read_at']);
  }
}
