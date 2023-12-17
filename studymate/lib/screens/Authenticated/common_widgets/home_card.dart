import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studymate/screens/Authenticated/common_widgets/card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../models/scheduled.dart';
import '../../../models/user.dart';

class HomeCard extends StatefulWidget {
  final User user;
  final bool isTutoring;
  final Scheduled scheduled;
  const HomeCard(
      {super.key,
      required this.user,
      required this.isTutoring,
      required this.scheduled});
  @override
  State<HomeCard> createState() => _HomeCardState();
}

class _HomeCardState extends State<HomeCard> {
  Stream<List<Users>> readUser(String? userId) => FirebaseFirestore.instance
      .collection('users')
      .where('id', isEqualTo: userId)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Users.fromJson(doc.data())).toList());

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.isTutoring
                    ? AppLocalizations.of(context)!.nextTutoringTitle
                    : AppLocalizations.of(context)!.nextLessonTitle,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            StreamBuilder(
                stream: readUser(widget.scheduled.studentId),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var students = snapshot.data!;
                    return StreamBuilder(
                        stream: readUser(widget.scheduled.tutorId),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            var tutors = snapshot.data!;
                            return ClassCard(
                                tutor: tutors.first,
                                student: students.first,
                                id: widget.scheduled.id,
                                date: widget.scheduled.date,
                                title: widget.scheduled.title,
                                timeslot: widget.scheduled.timeslot,
                                isTutor: widget.isTutoring,
                                lessonPage: false);
                          } else if (snapshot.hasError) {
                            return Text(snapshot.error.toString());
                          } else {
                            return const SizedBox();
                          }
                        });
                  } else if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  } else {
                    return const SizedBox();
                  }
                }),
          ],
        ),
      ),
    );
  }
}
