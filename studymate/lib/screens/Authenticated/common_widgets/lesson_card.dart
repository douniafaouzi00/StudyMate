import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../models/lesson.dart';
import '../../../models/user.dart';
import '../../../service/storage_service.dart';
import '../Lesson/lesson_page.dart';

class LessonCard extends StatefulWidget {
  final Lesson lesson;

  const LessonCard({
    super.key,
    required this.lesson,
  });

  @override
  State<LessonCard> createState() => _LessonCardState();
}

class _LessonCardState extends State<LessonCard> {
  Users? user;

  Stream<List<Users>> readUser() => FirebaseFirestore.instance
      .collection('users')
      .where('id', isEqualTo: widget.lesson.userTutor)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Users.fromJson(doc.data())).toList());

  @override
  Widget build(BuildContext context) {
    final Storage storage = Storage();
    final isMobile = MediaQuery.of(context).size.shortestSide < 600;


    return StreamBuilder<List<Users>>(
      stream: readUser(),
      builder: ((context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Something went wrong!");
        } else if (snapshot.hasData) {
          final user = snapshot.data!.first;
          return InkWell(
            key: Key('lessonCard'),
            onTap: () {
              if (!isMobile) {
                showModalBottomSheet(
                  showDragHandle: true,
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  backgroundColor: Theme.of(context).colorScheme.background,
                  builder: (context) => Container(
                    child: LessonPage(
                      lesson: widget.lesson,
                      user: user,
                    ),
                  ),
                );
              } else {
                Navigator.of(context).push(_createRoute(LessonPage(
                  lesson: widget.lesson,
                  user: user,
                )));
              }
            },
            child: Row(
              children: [
                SizedBox(
                  height: 70,
                  width: 70,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child: FutureBuilder(
                        future: storage.downloadURL(user.profileImageURL),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Text("Something went wrong!");
                          } else if (snapshot.hasData) {
                            return Image(
                              image: NetworkImage(snapshot.data!),
                            );
                          } else {
                            return const Card(
                              shadowColor: Colors.transparent,
                              margin: EdgeInsets.zero,
                            );
                          }
                        }),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.lesson.title,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        user.firstname + " " + user.lastname,
                        overflow: TextOverflow.ellipsis,
                      ),
                      RatingBar.builder(
                        ignoreGestures: true,
                        initialRating: double.parse(user.userRating),
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 13,
                        itemPadding: const EdgeInsets.symmetric(
                            horizontal: 1.0, vertical: 5),
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (double value) {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return const Center(
              //child: CircularProgressIndicator(),
              );
        }
      }),
    );
  }
}

Route _createRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
