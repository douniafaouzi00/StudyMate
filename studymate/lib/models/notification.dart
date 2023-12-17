import 'package:cloud_firestore/cloud_firestore.dart';


class Notifications {
  final String? id;
  final String? from_id;
  final String? to_id;
  final String? eventId;
  final String? content;
  final String? type;
  final Timestamp? time;
  final bool? view;

  Notifications(
      {this.id,
      this.from_id,
      this.to_id,
      this.eventId,
      this.content,
      this.type,
      this.view,
      this.time});

  factory Notifications.fromFirestore(Map<String, dynamic> json) {
    return Notifications(
      id: json['id'],
      from_id: json['from_id'],
      to_id: json['to_id'],
      eventId: json['eventId'],
      content: json['content'],
      type: json['type'],
      view: json['view'],
      time: json['time'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) "id": id,
      if (from_id != null) "from_id": from_id,
      if (to_id != null) "to_id": to_id,
      if (eventId != null) "eventId": eventId,
      if (content != null) "content": content,
      if (view != null) "view": view,
      if (type != null) "type": type,
      if (time != null) "time": time,
    };
  }
}
