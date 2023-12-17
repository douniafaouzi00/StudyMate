import 'package:cloud_firestore/cloud_firestore.dart';

class Scheduled {
  final String? id;
  final String? lessionId;
  final String? studentId;
  final String? tutorId;
  final String? title;
  final String? category;
  final List<dynamic>? timeslot;
  final Timestamp? date;
  final bool? accepted;

  Scheduled({
    this.id,
    this.lessionId,
    this.studentId,
    this.title,
    this.category,
    this.tutorId,
    this.timeslot,
    this.date,
    this.accepted,
  });

  factory Scheduled.fromFirestore(Map<String, dynamic> json) {
    return Scheduled(
        id: json['id'],
        lessionId: json['lessionId'],
        studentId: json['studentId'],
        tutorId: json['tutorId'],
        title: json['title'],
        category: json['category'],
        timeslot: json['timeslot'],
        date: json['date'],
        accepted: json['accepted']);
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) 'id': id,
      if (lessionId != null) "lessionId": lessionId,
      if (studentId != null) "studentId": studentId,
      if (tutorId != null) "tutorId": tutorId,
      if (title != null) "title": title,
      if (category != null) "category": category,
      if (timeslot != null) "timeslot": timeslot,
      if (date != null) "date": date,
      if (accepted != null) "accepted": accepted,
    };
  }
}
