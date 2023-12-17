import 'package:cloud_firestore/cloud_firestore.dart';

class RecordLessonView {
  final String? id;
  final String? lessonId;
  final Timestamp? timestamp;
  final String? userId;

  RecordLessonView({
    this.id,
    this.lessonId,
    this.timestamp,
    this.userId,
  });

  factory RecordLessonView.fromFirestore(Map<String, dynamic> json) {
    return RecordLessonView(
        id: json['id'],
        lessonId: json['lessonId'],
        timestamp: json['timestamp'],
        userId: json['userId']);
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) 'id': id,
      if (lessonId != null) "lessonId": lessonId,
      if (timestamp != null) "timestamp": timestamp,
      if (userId != null) "userId": userId,
    };
  }
}
