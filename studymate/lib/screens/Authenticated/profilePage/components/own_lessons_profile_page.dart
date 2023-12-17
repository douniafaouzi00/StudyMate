import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studymate/screens/Authenticated/profilePage/components/edit_lesson_page.dart';

import '../../../../component/utils.dart';
import '../../../../functions/routingAnimation.dart';
import '../../../../models/category.dart';
import '../../../../models/lesson.dart';
import '../../../../service/storage_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OwnLessonsProfilePage extends StatefulWidget {
  @override
  State<OwnLessonsProfilePage> createState() => _OwnLessonsProfilePageState();
}

class _OwnLessonsProfilePageState extends State<OwnLessonsProfilePage> {
  final user = FirebaseAuth.instance.currentUser!;
  final Storage storage = Storage();
  bool isBusy = false;

  Stream<List<Lesson>> readOwnLessons(String userId) =>
      FirebaseFirestore.instance
          .collection('lessons')
          .where('userTutor', isEqualTo: userId)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => Lesson.fromJson(doc.data())).toList());
  Stream<List<Category>> readCategory(String category) => FirebaseFirestore
      .instance
      .collection('categories')
      .where('name', isEqualTo: category)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Category.fromJson(doc.data())).toList());

  Future deleteLessons({required String lessonId}) async {
    ///DEVO RICORDARE DI ELIMINARE IN CASCATA TUTTO lessons, recordlessons, saved lessons, scheduled
    setState(() {
      isBusy = true;
    });
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('savedLessons')
          .where('lessonId', isEqualTo: lessonId)
          .get();
      snapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
      snapshot = await FirebaseFirestore.instance
          .collection('recordLessonsViewed')
          .where('lessonId', isEqualTo: lessonId)
          .get();
      snapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
      snapshot = await FirebaseFirestore.instance
          .collection('scheduled')
          .where('lessionId', isEqualTo: lessonId)
          .get();
      snapshot.docs.forEach((doc) {
        doc.reference.delete();
      });

      final docRecord = FirebaseFirestore.instance.collection('lessons');
      await docRecord.doc(lessonId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.lessonDeleted),
        ),
      );
      setState(() {
        isBusy = false;
      });
    } on FirebaseAuthException catch (e) {
      Utils.showSnackBar(e.message);
      setState(() {
        isBusy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.shortestSide < 600;

    if (isBusy) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return StreamBuilder<List<Lesson>>(
        stream: readOwnLessons(user.uid),
        builder: ((context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Something went wrong!");
          } else if (snapshot.hasData) {
            final lessons = snapshot.data!;
            if (lessons.isNotEmpty) {
              return GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  childAspectRatio: 35 / 9,
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                ),
                itemCount: lessons.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Center(
                      child: ListTile(
                            //titleAlignment: titleAlignment,
                            leading: StreamBuilder<List<Category>>(
                                stream: readCategory(lessons[index].category),
                                builder: ((context, snapshot) {
                                  if (snapshot.hasError) {
                                    return const CircleAvatar(
                                      child: Text('E'),
                                    );
                                  } else if (snapshot.hasData) {
                                    final category = snapshot.data!.first;
                                    return FutureBuilder(
                                        future:
                                            storage.downloadURL(category.imageURL),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasError) {
                                            return const CircleAvatar(
                                              child: Text('E'),
                                            );
                                          } else if (snapshot.hasData) {
                                            return CircleAvatar(
                                              backgroundImage:
                                                  NetworkImage(snapshot.data!),
                                            );
                                          } else {
                                            return const CircleAvatar();
                                          }
                                        });
                                  } else {
                                    return const CircleAvatar();
                                  }
                                })),
                            title: Text(
                              lessons[index].title,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (String? value) {
                                if (value == 'edit') {
                                  if (isMobile) {
                                    Navigator.of(context)
                                        .push(createRoute(EditLessonPage(
                                      isBottomModal: false,
                                      lesson: lessons[index],
                                    )));
                                  } else {
                                    showModalBottomSheet(
                                      showDragHandle: true,
                                      context: context,
                                      isScrollControlled: true,
                                      useSafeArea: true,
                                      builder: (context) => Container(
                                        child: EditLessonPage(
                                          isBottomModal: true,
                                          lesson: lessons[index],
                                        ),
                                      ),
                                    );
                                  }
                                } else if (value == 'delete') {
                                  showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) => AlertDialog(
                                      title: Text(AppLocalizations.of(context)!
                                          .deleteLessonTitle),
                                      content: Text(AppLocalizations.of(context)!
                                          .deleteLessonSubTitle),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, 'Cancel'),
                                          child: Text(
                                              AppLocalizations.of(context)!.cancel),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            if (!isBusy) {
                                              deleteLessons(lessonId: lessons[index].id!);
                                              Navigator.pop(context, 'Ok');
                                            }
                                          },
                                          child: Text(
                                              AppLocalizations.of(context)!.ok),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit),
                                      SizedBox(width: 16),
                                      Text(
                                          AppLocalizations.of(context)!.editLesson),
                                    ],
                                  ),
                                ),
                                PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete),
                                      SizedBox(width: 16),
                                      Text(AppLocalizations.of(context)!
                                          .deleteLesson),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                    ),
                  );
                },
              );
            } else {
              return Text(AppLocalizations.of(context)!.noOwnLesson);
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }));
  }
}
