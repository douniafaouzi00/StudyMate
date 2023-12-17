import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studymate/models/scheduled.dart';
import 'package:studymate/models/timeslot.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../component/utils.dart';
import '../../../models/lesson.dart';
import '../../../models/notification.dart';
import '../../../models/user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BookLessonModal extends StatefulWidget {
  final Lesson lesson;
  final Users user;

  const BookLessonModal({
    super.key,
    required this.lesson,
    required this.user,
  });

  @override
  State<BookLessonModal> createState() => _BookLessonModalState();
}

class _BookLessonModalState extends State<BookLessonModal> {
  final userStudent = FirebaseAuth.instance.currentUser!;
  bool isBusy = false;
  List<DateTime> dates = [];
  List<String> selectedTimeslot = [];
  DateTime dateShown = DateTime.now();
  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      dateShown = day;
      selectedTimeslot = [];
    });
  }

  void onPressTimeslot(String timeslot) {
    if (selectedTimeslot.contains(timeslot)) {
      setState(() {
        selectedTimeslot.remove(timeslot);
      });
    } else {
      setState(() {
        selectedTimeslot.add(timeslot);
      });
    }
  }

  List<String> getTimeslotOfDay(int day, TimeslotsWeek tsw) {
    List<String> timeslots = [];

    switch (day) {
      case 1:
        timeslots = tsw.monday.map((item) => item.toString()).toList();
        break;
      case 2:
        timeslots = tsw.tuesday.map((item) => item.toString()).toList();
        break;
      case 3:
        timeslots = tsw.wednesday.map((item) => item.toString()).toList();
        break;
      case 4:
        timeslots = tsw.thursday.map((item) => item.toString()).toList();
        break;
      case 5:
        timeslots = tsw.friday.map((item) => item.toString()).toList();
        break;
      case 6:
        timeslots = tsw.saturday.map((item) => item.toString()).toList();
        break;
      case 7:
        timeslots = tsw.sunday.map((item) => item.toString()).toList();
        break;
      default:
    }

    return timeslots;
  }

  Stream<List<Users>> readUsers() => FirebaseFirestore.instance
      .collection('users')
      .where('id', isEqualTo: userStudent.uid)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Users.fromJson(doc.data())).toList());

  Stream<List<TimeslotsWeek>> readTimeslot() => FirebaseFirestore.instance
      .collection('timeslots')
      .where('userId', isEqualTo: widget.user.id)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => TimeslotsWeek.fromJson(doc.data()))
          .toList());

  Stream<List<Scheduled>> readScheduledTutor() => FirebaseFirestore.instance
      .collection('scheduled')
      .where('tutorId', isEqualTo: widget.user.id)
      .snapshots()
      .map(((snapshot) => snapshot.docs
          .map((doc) => Scheduled.fromFirestore(doc.data()))
          .toList()));
  Stream<List<Scheduled>> readScheduledTutorStud() => FirebaseFirestore.instance
      .collection('scheduled')
      .where('studentId', isEqualTo: widget.user.id)
      .snapshots()
      .map(((snapshot) => snapshot.docs
          .map((doc) => Scheduled.fromFirestore(doc.data()))
          .toList()));
  Stream<List<Scheduled>> readScheduledStudent() => FirebaseFirestore.instance
      .collection('scheduled')
      .where('studentId', isEqualTo: userStudent.uid)
      .snapshots()
      .map(((snapshot) => snapshot.docs
          .map((doc) => Scheduled.fromFirestore(doc.data()))
          .toList()));
  Stream<List<Scheduled>> readScheduledStudentTut() =>
      FirebaseFirestore.instance
          .collection('scheduled')
          .where('tutorId', isEqualTo: userStudent.uid)
          .snapshots()
          .map(((snapshot) => snapshot.docs
              .map((doc) => Scheduled.fromFirestore(doc.data()))
              .toList()));

  bool checkTimeslotScheduled(List<Scheduled> scheduled, String timeslot) {
    for (var element in scheduled) {
      if (DateUtils.isSameDay(dateShown, element.date!.toDate())) {
        if (element.timeslot != null) {
          if (element.timeslot!.contains(timeslot)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  Future send(
      {required Scheduled scheduled, required Users userStudent}) async {
    try {
      setState(() {
        isBusy = true;
      });

      var sched = Scheduled();
      final docScheduled = FirebaseFirestore.instance.collection('scheduled');
      await docScheduled.add({}).then((DocumentReference doc) {
        sched = Scheduled(
            id: doc.id,
            lessionId: scheduled.lessionId,
            studentId: scheduled.studentId,
            title: scheduled.title,
            category: scheduled.category,
            timeslot: scheduled.timeslot,
            tutorId: scheduled.tutorId,
            date: scheduled.date,
            accepted: scheduled.accepted);
        final json = sched.toFirestore();
        docScheduled.doc(doc.id).update(json);
      });

      final docChat = FirebaseFirestore.instance.collection('notification');
      await docChat.add({}).then((DocumentReference doc) {
        var notif = Notifications(
          id: doc.id,
          from_id: sched.studentId,
          to_id: sched.tutorId,
          type: "request",
          content:
              "${scheduled.title} - ${DateFormat.yMd().format(scheduled.date!.toDate())}",
          view: false,
          eventId: sched.id,
          time: Timestamp.now(),
        );
        final json = notif.toFirestore();
        docChat.doc(doc.id).update(json);
      });
      final docUsers = FirebaseFirestore.instance.collection('users');

      await docUsers.doc(userStudent.id).update({
        'hours': userStudent.hours - scheduled.timeslot!.length,
      });
      setState(() {
        isBusy = false;
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.lessonBookedConfirm)),
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      Utils.showSnackBar(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 5),
        child: StreamBuilder<List<TimeslotsWeek>>(
            stream: readTimeslot(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text("Something went wrong!");
              } else if (snapshot.hasData) {
                if (snapshot.data != null) {
                  if (snapshot.data!.isNotEmpty) {
                    final timeslotWeek = snapshot.data!.first;
    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TableCalendar(
                          locale: "en_US",
                          rowHeight: 40,
                          headerStyle: const HeaderStyle(
                              formatButtonVisible: false, titleCentered: true),
                          availableGestures: AvailableGestures.all,
                          eventLoader: (day) {
                            List<DateTime> events = [];
                            if (dates.contains(
                                DateTime(day.year, day.month, day.day))) {
                              events.add(day);
                            }
                            return events;
                          },
                          selectedDayPredicate: (day) =>
                              isSameDay(day, dateShown),
                          focusedDay: dateShown,
                          firstDay: DateTime.now(),
                          lastDay: DateTime.utc(2025, 12, 31),
                          onDaySelected: _onDaySelected,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(AppLocalizations.of(context)!.selectTimeslotTitle,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                        const SizedBox(
                          height: 10,
                        ),
                        StreamBuilder<List<Scheduled>>(
                            stream: readScheduledTutor(),
                            builder: (context, snapshot) {
                              List<Scheduled> scheduledTutor = [];
                              List<Scheduled> scheduledTutorStud = [];
                              List<Scheduled> scheduledStudent = [];
                              List<Scheduled> scheduledStudentTut = [];
                              if (snapshot.hasError) {
                                return const Text("Something went wrong!");
                              } else if (snapshot.hasData) {
                                scheduledTutor = snapshot.data!;
                              }
                              return StreamBuilder<List<Scheduled>>(
                                  stream: readScheduledStudent(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return const Text("Something went wrong!");
                                    } else if (snapshot.hasData) {
                                      scheduledStudent = snapshot.data!;
                                    }
                                    return StreamBuilder<List<Scheduled>>(
                                        stream: readScheduledTutorStud(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasError) {
                                            return const Text(
                                                "Something went wrong!");
                                          } else if (snapshot.hasData) {
                                            scheduledTutorStud = snapshot.data!;
                                          }
                                          return StreamBuilder<List<Scheduled>>(
                                              stream: readScheduledStudentTut(),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasError) {
                                                  return const Text(
                                                      "Something went wrong!");
                                                } else if (snapshot.hasData) {
                                                  scheduledStudentTut =
                                                      snapshot.data!;
                                                }
                                                return Container(
                                                    height: 45,
                                                    child: (() {
                                                      if (getTimeslotOfDay(
                                                              dateShown.weekday,
                                                              timeslotWeek)
                                                          .isNotEmpty) {
                                                        return ListView(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          children:
                                                              getTimeslotOfDay(
                                                                      dateShown
                                                                          .weekday,
                                                                      timeslotWeek)
                                                                  .map<Container>(
                                                                      (timeslot) {
                                                            if (checkTimeslotScheduled(
                                                                scheduledStudent +
                                                                    scheduledTutor +
                                                                    scheduledStudentTut +
                                                                    scheduledTutorStud,
                                                                timeslot)) {
                                                              return Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        right: 5),
                                                                child: TextButton(
                                                                  style:
                                                                      timeslotButtonStyle(
                                                                    selectedTimeslot
                                                                        .contains(
                                                                            timeslot),
                                                                  ),
                                                                  onPressed: null,
                                                                  child: Text(
                                                                      timeslot),
                                                                ),
                                                              );
                                                            }
                                                            return Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      right: 5),
                                                              child: TextButton(
                                                                style:
                                                                    timeslotButtonStyle(
                                                                  selectedTimeslot
                                                                      .contains(
                                                                          timeslot),
                                                                ),
                                                                onPressed: () {
                                                                  onPressTimeslot(
                                                                      timeslot);
                                                                },
                                                                child: Text(
                                                                    timeslot),
                                                              ),
                                                            );
                                                          }).toList(),
                                                        );
                                                      } else {
                                                        return Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .noLessonsInDay);
                                                      }
                                                    }()));
                                              });
                                        });
                                  });
                            }),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                            "${AppLocalizations.of(context)!.creditAvailable}:",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                            AppLocalizations.of(context)!
                                                .oneCreditHour,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            StreamBuilder(
                                stream: readUsers(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return const Text('Something went wrong!');
                                  } else if (snapshot.hasData) {
                                    var ownUser = snapshot.data!.first;
                                    return Align(
                                      alignment: Alignment.centerRight,
                                      child: Row(
                                        children: [
                                          Text(
                                            ownUser.hours.toString(),
                                            style: TextStyle(fontSize: 20),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          const Icon(
                                            Icons.av_timer,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }
                                }),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Wrap(
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  primary:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                child:
                                    Text(AppLocalizations.of(context)!.closeCaps),
                              ),
                              StreamBuilder(
                                  stream: readUsers(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return const Text('Something went wrong!');
                                    } else if (snapshot.hasData) {
                                      var ownUser = snapshot.data!.first;
                                      return TextButton(
                                        onPressed: () {
                                          if (selectedTimeslot.isNotEmpty &&
                                              isBusy == false) {
                                            if (selectedTimeslot.length <=
                                                ownUser.hours) {
                                              selectedTimeslot.sort(
                                                  (String a, String b) =>
                                                      a.compareTo(b));
                                              final scheduled = Scheduled(
                                                lessionId: widget.lesson.id,
                                                studentId: userStudent.uid,
                                                title: widget.lesson.title,
                                                category: widget.lesson.category,
                                                tutorId: widget.user.id,
                                                timeslot: selectedTimeslot,
                                                date:
                                                    Timestamp.fromDate(dateShown),
                                                accepted: false,
                                              );
                                              send(
                                                  scheduled: scheduled,
                                                  userStudent: ownUser);
                                            } else {
                                              Navigator.pop(context);
    
                                              Utils.showSnackBar(
                                                  AppLocalizations.of(context)!
                                                      .noCredits);
                                            }
                                          }
                                        },
                                        style: TextButton.styleFrom(
                                          primary: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        child: Text(AppLocalizations.of(context)!
                                            .bookLessonCaps),
                                      );
                                    } else {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    }
                                  }),
                            ],
                          ),
                        ),
                        (() {
                          if (isBusy) {
                            return LinearProgressIndicator();
                          }
                          return Container();
                        }())
                      ],
                    );
                  }
                }
                return Text(AppLocalizations.of(context)!.noTimestamp);
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ),
    );
  }
}

ButtonStyle timeslotButtonStyle(bool selected) {
  ColorScheme color =
      ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 255, 82, 14));
  return IconButton.styleFrom(
    foregroundColor: selected ? color.onPrimary : color.primary,
    backgroundColor: selected ? color.primary : color.surfaceVariant,
    disabledForegroundColor: color.onSurface.withOpacity(0.38),
    disabledBackgroundColor: color.onSurface.withOpacity(0.12),
    hoverColor: selected
        ? color.onPrimary.withOpacity(0.08)
        : color.primary.withOpacity(0.08),
    focusColor: selected
        ? color.onPrimary.withOpacity(0.12)
        : color.primary.withOpacity(0.12),
    highlightColor: selected
        ? color.onPrimary.withOpacity(0.12)
        : color.primary.withOpacity(0.12),
  );
}
