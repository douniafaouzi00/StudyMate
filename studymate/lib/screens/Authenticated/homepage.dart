import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:studymate/functions/routingAnimation.dart';
import 'package:studymate/models/lesson.dart';
import 'package:studymate/models/scheduledHome.dart';
import 'package:studymate/models/user.dart';
import 'package:studymate/screens/Authenticated/Search/search_page.dart';
import 'package:studymate/screens/Authenticated/common_widgets/home_card.dart';
import '../../models/notification.dart';
import 'package:studymate/screens/Authenticated/common_widgets/lesson_card.dart';
import 'package:studymate/screens/Authenticated/notification/notification_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/scheduled.dart';

class HomePage extends StatefulWidget {
  final bool isSearching;
  final Function callbackOpenChat;

  const HomePage(
      {super.key, required this.isSearching, required this.callbackOpenChat});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final user = FirebaseAuth.instance.currentUser!;

  Stream<List<Lesson>> readLessons(String userId) => FirebaseFirestore.instance
      .collection('lessons')
      .where('userTutor', isNotEqualTo: userId)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Lesson.fromJson(doc.data())).toList());

  Stream<List<Users>> readUser(String userId) => FirebaseFirestore.instance
      .collection('users')
      .where('id', isEqualTo: userId)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Users.fromJson(doc.data())).toList());

  Stream<List<Scheduled>> readScheduledTutoring() => FirebaseFirestore.instance
      .collection('scheduled')
      .where('tutorId', isEqualTo: user.uid)
      .where('accepted', isEqualTo: true)
      .where('date',
          isGreaterThan: Timestamp.fromDate(DateTime.utc(
                  DateTime.now().year, DateTime.now().month, DateTime.now().day)
              .subtract(const Duration(days: 1))))
      .orderBy('date', descending: false)
      .limit(1)
      .snapshots()
      .map(((snapshot) => snapshot.docs
          .map((doc) => Scheduled.fromFirestore(doc.data()))
          .toList()));
  Stream<List<Scheduled>> readScheduledLesson() => FirebaseFirestore.instance
      .collection('scheduled')
      .where('studentId', isEqualTo: user.uid)
      .where('accepted', isEqualTo: true)
      .where('date',
          isGreaterThan: Timestamp.fromDate(DateTime.utc(
                  DateTime.now().year, DateTime.now().month, DateTime.now().day)
              .subtract(const Duration(days: 1))))
      .orderBy('date', descending: false)
      .limit(1)
      .snapshots()
      .map(((snapshot) => snapshot.docs
          .map((doc) => Scheduled.fromFirestore(doc.data()))
          .toList()));
/*
  Stream<List<Chat>> readMessages() => FirebaseFirestore.instance
      .collection('chat')
      .where('member', arrayContains: user.uid)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Chat.fromFirestore(doc.data())).toList());
*/
  Stream<List<Notifications>> readNot() => FirebaseFirestore.instance
      .collection('notification')
      .where('to_id', isEqualTo: user.uid)
      .where('view', isEqualTo: false)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Notifications.fromFirestore(doc.data()))
          .toList());

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        widget.isSearching
            ? Expanded(
                flex: 3,
                child: SearchPage(),
              )
            : SizedBox(),
        widget.isSearching
            ? const VerticalDivider(thickness: 1, width: 1)
            : SizedBox(),
        Expanded(
          flex: 7,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 20),
                //Header
                Container(
                  child: Row(children: <Widget>[
                    Expanded(
                      flex: 9,
                      child: Text(AppLocalizations.of(context)!.welcome,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                    StreamBuilder(
                        stream: readNot(),
                        builder: ((context, snapshot) {
                          if (snapshot.hasData) {
                            List<Notifications> notifications = snapshot.data!;
                            if (notifications.isNotEmpty) {
                              return IconButton(
                                key: const Key('notificationButton'),
                                icon: badges.Badge(
                                  position:
                                      BadgePosition.topEnd(top: 0, end: 0),
                                  showBadge: true,
                                  child: const Icon(
                                    Icons.notifications,
                                    color: Colors.grey,
                                    size: 25.0,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context)
                                      .push(createRoute(NotificationPage(
                                    callbackOpenChat: widget.callbackOpenChat,
                                  )));
                                },
                              );
                            }
                          }
                          return IconButton(
                            key: const Key('notificationButton'),
                            icon: badges.Badge(
                              position: BadgePosition.topEnd(top: 0, end: 0),
                              showBadge: false,
                              child: const Icon(
                                Icons.notifications,
                                color: Colors.grey,
                                size: 25.0,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context)
                                  .push(createRoute(NotificationPage(
                                callbackOpenChat: widget.callbackOpenChat,
                              )));
                            },
                          );
                        })),
                  ]),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      StreamBuilder(
                        stream: readScheduledTutoring(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            var scheduleTutor = snapshot.data!;
                            return StreamBuilder(
                              stream: readScheduledLesson(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  var scheduleLesson = snapshot.data!;
                                  List<ScheduledHome> schedules = [];
                                  if (scheduleTutor.isNotEmpty) {
                                    schedules.add(ScheduledHome(
                                        scheduled: scheduleTutor.first,
                                        type: 'Tutor'));
                                  }
                                  if (scheduleLesson.isNotEmpty) {
                                    schedules.add(ScheduledHome(
                                        scheduled: scheduleLesson.first,
                                        type: 'Lesson'));
                                  }
                                  return GridView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    gridDelegate:
                                        const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 400,
                                      childAspectRatio: 3 / 2.2,
                                      mainAxisSpacing: 10.0,
                                      crossAxisSpacing: 10.0,
                                    ),
                                    itemCount: schedules.length,
                                    itemBuilder: (context, index) {
                                      if (schedules[index].type == 'Tutor') {
                                        return HomeCard(
                                          user: user,
                                          isTutoring: true,
                                          scheduled: schedules[index].scheduled,
                                        );
                                      } else if (schedules[index].type ==
                                          'Lesson') {
                                        return HomeCard(
                                          user: user,
                                          isTutoring: false,
                                          scheduled: schedules[index].scheduled,
                                        );
                                      }
                                      return null;
                                    },
                                  );
                                } else if (snapshot.hasError) {
                                  return Text(snapshot.error.toString());
                                } else {
                                  return const SizedBox();
                                }
                              },
                            );
                          } else if (snapshot.hasError) {
                            return Text(snapshot.error.toString());
                          } else {
                            return const SizedBox();
                          }
                        },
                      ),
/*
                      (w < 600)
                          ? Column(
                              children: [
                                //--------------------
                                //Your next lesson
                                HomeCard(
                                  user: user,
                                  isTutoring: false,
                                ),
                                //--------------------
                                //Your next tutoring
                                HomeCard(
                                  user: user,
                                  isTutoring: true,
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                //--------------------
                                //Your next lesson
                                HomeCard(
                                  user: user,
                                  isTutoring: false,
                                ),

                                //--------------------
                                //Your next tutoring

                                HomeCard(
                                  user: user,
                                  isTutoring: true,
                                ),
                              ],
                            ),
*/
                      //--------------------\
                      //Suggested for you
                      const SizedBox(height: 20),
                      Text(AppLocalizations.of(context)!.suggestedTitle,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          )),
                      const SizedBox(height: 10),
                      Text(AppLocalizations.of(context)!.suggestedSubTitle,
                          style: const TextStyle(
                            fontSize: 13,
                          )),
                      const SizedBox(height: 30),
                      StreamBuilder<List<Users>>(
                        stream: readUser(user.uid),
                        builder: ((context, snapshot) {
                          if (snapshot.hasError) {
                            return const Text("Something went wrong!");
                          } else if (snapshot.hasData) {
                            final categories =
                                snapshot.data!.first.categoriesOfInterest;

                            return StreamBuilder<List<Lesson>>(
                                stream: readLessons(user.uid),
                                builder: ((context, snapshot) {
                                  if (snapshot.hasError) {
                                    return const Text("Something went wrong!");
                                  } else if (snapshot.hasData) {
                                    List<Lesson> lessons = snapshot.data!;
                                    lessons.removeWhere((item) =>
                                        !categories!.contains(item.category));

                                    if (lessons.length == 0) {
                                      return Text(AppLocalizations.of(context)!
                                          .noLessons);
                                    } else {
                                      return GridView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        gridDelegate:
                                            const SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent: 400,
                                          childAspectRatio: 35 / 9,
                                          mainAxisSpacing: 10.0,
                                          crossAxisSpacing: 10.0,
                                        ),
                                        itemCount: lessons.length,
                                        itemBuilder: (context, index) {
                                          return LessonCard(
                                            lesson: lessons[index],
                                          );
                                        },
                                      );
                                    }
                                  } else {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                }));
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        }),
                      ),

                      //-------------------
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class FilledCardExample extends StatelessWidget {
  const FilledCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceVariant,
        child: const SizedBox(
          height: 300,
          child: Center(child: Text('Filled Card')),
        ),
      ),
    );
  }
}

class NextFilledCardExample extends StatelessWidget {
  const NextFilledCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceVariant,
        child: const SizedBox(
          height: 100,
          child: Center(child: Text('Filled Card')),
        ),
      ),
    );
  }
}

class SmallFilledCardExample extends StatelessWidget {
  const SmallFilledCardExample({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceVariant,
        child: const SizedBox(
          height: 70,
          width: 70,
        ),
      ),
    );
  }
}
