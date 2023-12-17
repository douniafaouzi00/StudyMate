import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:studymate/component/utils.dart';
import 'package:studymate/models/category.dart';
import 'package:studymate/models/recordLessonViewed.dart';
import 'package:studymate/models/savedLesson.dart';
import 'package:studymate/models/timeslot.dart';

import 'package:studymate/models/chat.dart';
import 'package:studymate/screens/Authenticated/Lesson/booklesson.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/lesson.dart';
import '../../../models/user.dart';
import '../../../service/storage_service.dart';
import '../Chat/chat_msg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LessonPage extends StatefulWidget {
  final Lesson lesson;
  final Users user;
  const LessonPage({super.key, required this.lesson, required this.user});
  @override
  _LessonState createState() => _LessonState();
}

class _LessonState extends State<LessonPage> {
  final userFirebase = FirebaseAuth.instance.currentUser!;
  final userLog = FirebaseAuth.instance.currentUser!;
  bool isBusy = false;

  @override
  void initState() {
    super.initState();
    final record = RecordLessonView(
        lessonId: widget.lesson.id,
        timestamp: Timestamp.fromDate(DateTime.now()),
        userId: userLog.uid);
    sendRecord(record: record);
  }

  Stream<List<Category>> readCategory() => FirebaseFirestore.instance
      .collection('categories')
      .where('name', isEqualTo: widget.lesson.category)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Category.fromJson(doc.data())).toList());

  Stream<List<TimeslotsWeek>> readTimeslot() => FirebaseFirestore.instance
      .collection('timeslots')
      .where('userId', isEqualTo: widget.user.id)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => TimeslotsWeek.fromJson(doc.data()))
          .toList());

  Stream<List<SavedLesson>> readSavedLesson() => FirebaseFirestore.instance
      .collection('savedLessons')
      .where('lessonId', isEqualTo: widget.lesson.id)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => SavedLesson.fromFirestore(doc.data()))
          .toList());

  List<String> convertListTimestampToPrint(List<dynamic> list) {
    List<String> timeToPrint = [];
    String? firstTimestamp;
    //Se c'è solo un elemento nel vettore
    if (list.length == 1) {
      timeToPrint.add(list[0]);
    }
    //Se ce ne sono almeno 2
    else {
      //Qui gestisco tutti gli elementi del vettore tranne l'ultimo
      for (var i = 0; i < list.length - 1; i++) {
        String x = list[i];
        String y = list[i + 1];
        int xInt = int.parse(x.substring(0, 2));
        int yInt = int.parse(y.substring(0, 2));

        //Se è il timestamp successivo
        if (xInt == (yInt - 1)) {
          //Se era vuoto (e quindi avevo aggiunto già un elemento nella lista) aggiungo l'attuale valore
          //altrimenti scorri il vettore
          firstTimestamp ??= x.substring(0, 5);
        }
        //Se il non è il timestamp successivo
        else {
          if (firstTimestamp == null) {
            timeToPrint.add(x);
          } else {
            timeToPrint.add(firstTimestamp + " - " + x.substring(8, 13));
            firstTimestamp = null;
          }
        }
      }
      //Uscito dalla lista rimarrà l'ultimo
      //Se era vuoto vuol dire che avevo già aggiunto in timeToPrint
      if (firstTimestamp == null) {
        timeToPrint.add(list[list.length - 1]);
      } else {
        String x = list[list.length - 1];
        timeToPrint.add(firstTimestamp + " - " + x.substring(8, 13));
      }
    }
    return timeToPrint;
  }

  Future sendRecord({required RecordLessonView record}) async {
    try {
      String docId = "";
      final docRecord =
          FirebaseFirestore.instance.collection('recordLessonsViewed');
      final json = record.toFirestore();
      await docRecord.add(json).then((DocumentReference doc) {
        docId = doc.id;
      });

      await docRecord.doc(docId).update({'id': docId});
    } on FirebaseAuthException catch (e) {
      Utils.showSnackBar(e.message);
    }
  }

  Future saveLesson({required SavedLesson savedLesson}) async {
    setState(() {
      isBusy = true;
    });
    try {
      String docId = "";
      final docRecord = FirebaseFirestore.instance.collection('savedLessons');
      final json = savedLesson.toFirestore();
      await docRecord.add(json).then((DocumentReference doc) {
        docId = doc.id;
      });

      await docRecord.doc(docId).update({'id': docId});
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

  Future removeSavedLesson({required String savedLessonId}) async {
    setState(() {
      isBusy = true;
    });
    try {
      final docRecord = FirebaseFirestore.instance.collection('savedLessons');

      await docRecord.doc(savedLessonId).delete();
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
    final Storage storage = Storage();


    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            elevation: 0,
            toolbarHeight: 70,
            automaticallyImplyLeading: false,
            //Buttons top
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop(context);
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10.0),
                        topLeft: Radius.circular(10.0),
                        bottomLeft: Radius.circular(10.0),
                        bottomRight: Radius.circular(10.0),
                      ),
                      color: Color.fromARGB(211, 255, 255, 255),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 40,
                        width: 40,
                        child: Center(
                          child: Icon(
                            Icons.arrow_back_ios_new,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  constraints: const BoxConstraints(maxWidth: 200),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10.0),
                      topLeft: Radius.circular(10.0),
                      bottomLeft: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0),
                    ),
                    color: Color.fromARGB(211, 255, 255, 255),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          height: 40,
                          width: 40,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(35),
                            child: FutureBuilder(
                                future: storage
                                    .downloadURL(widget.user.profileImageURL),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return const Text("Something went wrong!");
                                  } else if (snapshot.hasData) {
                                    return Image(
                                      image: NetworkImage(snapshot.data!),
                                    );
                                  } else {
                                    return Card(
                                      margin: EdgeInsets.zero,
                                    );
                                  }
                                }),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.user.firstname +
                                  " " +
                                  widget.user.lastname,
                              overflow: TextOverflow.fade,
                              maxLines: 1,
                              softWrap: false,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 46, 46, 46),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            //Buttons chat, like, booking
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(70),
              child: Container(
                height: 100,
                child: Stack(
                  children: [
                    Positioned(
                      top: 50,
                      right: 0,
                      left: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(50.0),
                            topLeft: Radius.circular(50.0),
                          ),
                          color: Theme.of(context).colorScheme.background,
                        ),
                        height: 50,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      left: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment
                            .center, //Center Row contents horizontally,

                        children: [
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: IconButton(
                                icon: const Icon(Icons.message_outlined),
                                onPressed: () {
                                  Users receiver = widget.user;
                                  send(receiver);
                                },
                                style: messageButtonStyle()),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          SizedBox(
                            width: 90,
                            height: 90,
                            child: IconButton(
                              icon: const Icon(
                                Icons.check_outlined,
                                size: 50,
                              ),
                              onPressed: () {
                                showModalBottomSheet(
                                    showDragHandle: true,
                                    context: context,
                                    isScrollControlled: true,
                                    useSafeArea: true,
                                    elevation: 1,
                                    builder: (context) => BookLessonModal(
                                        user: widget.user,
                                        lesson: widget.lesson));
                              },
                              style: bookLessonButtonStyle(),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: StreamBuilder<List<SavedLesson>>(
                                stream: readSavedLesson(),
                                builder: ((context, snapshot) {
                                  if (snapshot.hasError) {
                                    return IconButton(
                                      isSelected: false,
                                      icon: const Icon(
                                        Icons.error,
                                        size: 25,
                                      ),
                                      onPressed: () {},
                                      style: savedButtonStyle(false),
                                    );
                                  } else if (snapshot.hasData) {
                                    //If saved
                                    if (snapshot.data!.isNotEmpty) {
                                      final savedLesson = snapshot.data!.first;
                                      return IconButton(
                                        isSelected: true,
                                        icon: const Icon(
                                          Icons.favorite_outline,
                                          size: 25,
                                        ),
                                        selectedIcon: const Icon(
                                          Icons.favorite,
                                          size: 25,
                                        ),
                                        onPressed: () {
                                          if (!isBusy) {
                                            removeSavedLesson(
                                                savedLessonId: savedLesson.id!);
                                          }
                                        },
                                        style: savedButtonStyle(true),
                                      );
                                    }
                                    //If not saved
                                    else {
                                      return IconButton(
                                        isSelected: false,
                                        icon: const Icon(
                                          Icons.favorite_outline,
                                          size: 25,
                                        ),
                                        selectedIcon: const Icon(
                                          Icons.favorite,
                                          size: 25,
                                        ),
                                        onPressed: () {
                                          if (!isBusy) {
                                            final savedLesson = SavedLesson(
                                                lessonId: widget.lesson.id,
                                                userId: userLog.uid);
                                            saveLesson(
                                                savedLesson: savedLesson);
                                          }
                                        },
                                        style: savedButtonStyle(false),
                                      );
                                    }
                                  } else {
                                    return IconButton(
                                      isSelected: false,
                                      icon: const Icon(
                                        Icons.favorite_outline,
                                        size: 25,
                                      ),
                                      selectedIcon: const Icon(
                                        Icons.favorite,
                                        size: 25,
                                      ),
                                      onPressed: () {},
                                      style: savedButtonStyle(false),
                                    );
                                  }
                                })),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            pinned: true,
            collapsedHeight: 100,
            expandedHeight: 280,
            //Background
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 3,
                      color: Theme.of(context).colorScheme.background,
                    ),
                  ),
                ),
                child: StreamBuilder<List<Category>>(
                    stream: readCategory(),
                    builder: ((context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text("Something went wrong!");
                      } else if (snapshot.hasData) {
                        final category = snapshot.data!.first;
                        return FutureBuilder(
                            future: storage.downloadURL(category.imageURL),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return const Text("Something went wrong!");
                              } else if (snapshot.hasData) {
                                return Image.network(
                                  snapshot.data!,
                                  fit: BoxFit.cover,
                                );
                              } else {
                                return Container();
                              }
                            });
                      } else {
                        return const Center(
                            //child: CircularProgressIndicator(),
                            );
                      }
                    })),
              ),
            ),
          ),
          //BODY LESSON
          SliverToBoxAdapter(
            child: Container(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 10, 40, 40),
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.lesson.title,
                            style: const TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            widget.lesson.category,
                            style: const TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          /*
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "Location",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "Milano, MI",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(10.0),
                                          topLeft: Radius.circular(10.0),
                                          bottomLeft: Radius.circular(10.0),
                                          bottomRight: Radius.circular(10.0),
                                        ),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                      ),
                                      width: 100,
                                      height: 50,
                                      padding: const EdgeInsets.all(10),
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Icons.pin_drop,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text("1 km")
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                
                                const SizedBox(
                                  height: 25,
                                ),
                                */
                          Text(
                            AppLocalizations.of(context)!.date,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          Wrap(
                            children: [
                              StreamBuilder<List<TimeslotsWeek>>(
                                  stream: readTimeslot(),
                                  builder: ((context, snapshot) {
                                    if (snapshot.hasError) {
                                      return const Text(
                                          "Something went wrong!");
                                    } else if (snapshot.hasData) {
                                      if (snapshot.data != null) {
                                        if (snapshot.data!.isNotEmpty) {
                                          final timeslotWeek =
                                              snapshot.data!.first;
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: (() {
                                                  //Se c'è almeno un elemento nel vettore
                                                  List<String> toPrint = [];
                                                  if (timeslotWeek
                                                      .monday.isNotEmpty) {
                                                    toPrint =
                                                        convertListTimestampToPrint(
                                                            timeslotWeek
                                                                .monday);
                                                  }
                                                  return toPrint.isNotEmpty
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  0, 0, 0, 15),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                flex: 4,
                                                                child: Text(
                                                                  "${AppLocalizations.of(context)!.monday}:",
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 6,
                                                                child: Column(
                                                                  children: toPrint
                                                                      .map<Text>(
                                                                          ((e) {
                                                                    return Text(
                                                                        e);
                                                                  })).toList(),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : Padding(
                                                          padding: EdgeInsets
                                                              .fromLTRB(
                                                                  0, 0, 0, 15),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                flex: 4,
                                                                child: Text(
                                                                  "${AppLocalizations.of(context)!.monday}:",
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 6,
                                                                child: Column(
                                                                  children: [
                                                                    Text(AppLocalizations.of(
                                                                            context)!
                                                                        .noLessons)
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                }()),
                                              ),
                                              Container(
                                                child: (() {
                                                  //Se c'è almeno un elemento nel vettore
                                                  List<String> toPrint = [];
                                                  if (timeslotWeek
                                                      .tuesday.isNotEmpty) {
                                                    toPrint =
                                                        convertListTimestampToPrint(
                                                            timeslotWeek
                                                                .tuesday);
                                                  }
                                                  return toPrint.isNotEmpty
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  0, 0, 0, 15),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                flex: 4,
                                                                child: Text(
                                                                  "${AppLocalizations.of(context)!.tuesday}:",
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 6,
                                                                child: Column(
                                                                  children: toPrint
                                                                      .map<Text>(
                                                                          ((e) {
                                                                    return Text(
                                                                        e);
                                                                  })).toList(),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : Padding(
                                                          padding: EdgeInsets
                                                              .fromLTRB(
                                                                  0, 0, 0, 15),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                flex: 4,
                                                                child: Text(
                                                                  "${AppLocalizations.of(context)!.tuesday}:",
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 6,
                                                                child: Column(
                                                                  children: [
                                                                    Text(AppLocalizations.of(
                                                                            context)!
                                                                        .noLessons)
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                }()),
                                              ),
                                              Container(
                                                child: (() {
                                                  //Se c'è almeno un elemento nel vettore
                                                  List<String> toPrint = [];
                                                  if (timeslotWeek
                                                      .wednesday.isNotEmpty) {
                                                    toPrint =
                                                        convertListTimestampToPrint(
                                                            timeslotWeek
                                                                .wednesday);
                                                  }
                                                  return toPrint.isNotEmpty
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  0, 0, 0, 15),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                flex: 4,
                                                                child: Text(
                                                                  "${AppLocalizations.of(context)!.wednesday}:",
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 6,
                                                                child: Column(
                                                                  children: toPrint
                                                                      .map<Text>(
                                                                          ((e) {
                                                                    return Text(
                                                                        e);
                                                                  })).toList(),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : Padding(
                                                          padding: EdgeInsets
                                                              .fromLTRB(
                                                                  0, 0, 0, 15),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                flex: 4,
                                                                child: Text(
                                                                  "${AppLocalizations.of(context)!.wednesday}:",
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 6,
                                                                child: Column(
                                                                  children: [
                                                                    Text(AppLocalizations.of(
                                                                            context)!
                                                                        .noLessons)
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                }()),
                                              ),
                                              Container(
                                                child: (() {
                                                  //Se c'è almeno un elemento nel vettore
                                                  List<String> toPrint = [];
                                                  if (timeslotWeek
                                                      .thursday.isNotEmpty) {
                                                    toPrint =
                                                        convertListTimestampToPrint(
                                                            timeslotWeek
                                                                .thursday);
                                                  }
                                                  return toPrint.isNotEmpty
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  0, 0, 0, 15),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                flex: 4,
                                                                child: Text(
                                                                  "${AppLocalizations.of(context)!.thursday}:",
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 6,
                                                                child: Column(
                                                                  children: toPrint
                                                                      .map<Text>(
                                                                          ((e) {
                                                                    return Text(
                                                                        e);
                                                                  })).toList(),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : Padding(
                                                          padding: EdgeInsets
                                                              .fromLTRB(
                                                                  0, 0, 0, 15),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                flex: 4,
                                                                child: Text(
                                                                  "${AppLocalizations.of(context)!.thursday}:",
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 6,
                                                                child: Column(
                                                                  children: [
                                                                    Text(AppLocalizations.of(
                                                                            context)!
                                                                        .noLessons)
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                }()),
                                              ),
                                              Container(
                                                child: (() {
                                                  //Se c'è almeno un elemento nel vettore
                                                  List<String> toPrint = [];
                                                  if (timeslotWeek
                                                      .friday.isNotEmpty) {
                                                    toPrint =
                                                        convertListTimestampToPrint(
                                                            timeslotWeek
                                                                .friday);
                                                  }
                                                  return toPrint.isNotEmpty
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  0, 0, 0, 15),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                flex: 4,
                                                                child: Text(
                                                                  "${AppLocalizations.of(context)!.friday}:",
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 6,
                                                                child: Column(
                                                                  children: toPrint
                                                                      .map<Text>(
                                                                          ((e) {
                                                                    return Text(
                                                                        e);
                                                                  })).toList(),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : Padding(
                                                          padding: EdgeInsets
                                                              .fromLTRB(
                                                                  0, 0, 0, 15),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                flex: 4,
                                                                child: Text(
                                                                  "${AppLocalizations.of(context)!.friday}:",
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 6,
                                                                child: Column(
                                                                  children: [
                                                                    Text(AppLocalizations.of(
                                                                            context)!
                                                                        .noLessons)
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                }()),
                                              ),
                                              Container(
                                                child: (() {
                                                  //Se c'è almeno un elemento nel vettore
                                                  List<String> toPrint = [];
                                                  if (timeslotWeek
                                                      .saturday.isNotEmpty) {
                                                    toPrint =
                                                        convertListTimestampToPrint(
                                                            timeslotWeek
                                                                .saturday);
                                                  }
                                                  return toPrint.isNotEmpty
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  0, 0, 0, 15),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                flex: 4,
                                                                child: Text(
                                                                  "${AppLocalizations.of(context)!.saturday}:",
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 6,
                                                                child: Column(
                                                                  children: toPrint
                                                                      .map<Text>(
                                                                          ((e) {
                                                                    return Text(
                                                                        e);
                                                                  })).toList(),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : Padding(
                                                          padding: EdgeInsets
                                                              .fromLTRB(
                                                                  0, 0, 0, 15),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                flex: 4,
                                                                child: Text(
                                                                  "${AppLocalizations.of(context)!.saturday}:",
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 6,
                                                                child: Column(
                                                                  children: [
                                                                    Text(AppLocalizations.of(
                                                                            context)!
                                                                        .noLessons)
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                }()),
                                              ),
                                              Container(
                                                child: (() {
                                                  //Se c'è almeno un elemento nel vettore
                                                  List<String> toPrint = [];
                                                  if (timeslotWeek
                                                      .sunday.isNotEmpty) {
                                                    toPrint =
                                                        convertListTimestampToPrint(
                                                            timeslotWeek
                                                                .sunday);
                                                  }
                                                  return toPrint.isNotEmpty
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  0, 0, 0, 15),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                flex: 4,
                                                                child: Text(
                                                                  "${AppLocalizations.of(context)!.sunday}:",
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 6,
                                                                child: Column(
                                                                  children: toPrint
                                                                      .map<Text>(
                                                                          ((e) {
                                                                    return Text(
                                                                        e);
                                                                  })).toList(),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : Padding(
                                                          padding: EdgeInsets
                                                              .fromLTRB(
                                                                  0, 0, 0, 15),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                flex: 4,
                                                                child: Text(
                                                                  "${AppLocalizations.of(context)!.sunday}:",
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 6,
                                                                child: Column(
                                                                  children: [
                                                                    Text(AppLocalizations.of(
                                                                            context)!
                                                                        .noLessons)
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                }()),
                                              ),
                                            ],
                                          );
                                        }
                                      }
                                      return Text(AppLocalizations.of(context)!
                                          .noTimestamp);
                                    } else {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                  })),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            AppLocalizations.of(context)!.about,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            widget.lesson.description,
                            style: const TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          Text(
                            AppLocalizations.of(context)!.userRating,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          RatingBar.builder(
                            ignoreGestures: true,
                            initialRating: double.parse(widget.user.userRating),
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 20,
                            itemPadding: const EdgeInsets.symmetric(
                                horizontal: 4.0, vertical: 5.0),
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (double value) {},
                          ),
                          SizedBox(
                            height: 20,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Stream<List<Chat>> readChat(String user) => FirebaseFirestore.instance
      .collection('chat')
      .where('member', arrayContains: user)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Chat.fromFirestore(doc.data())).toList());

  Future send(Users reciver) async {
    try {
      List<Chat> chats1 = await readChat(reciver.id).first;
      List<Chat> chats2 = await readChat(userFirebase.uid).first;
      Chat chat = Chat();
      chats1.forEach((element1) {
        chats2.forEach((element2) {
          if (element1.id == element2.id) {
            chat = element1;
          }
        });
      });
      if (chat.id == null) {
        final docChat = FirebaseFirestore.instance.collection('chat');
        List<String> member = [reciver.id, userFirebase.uid];
        await docChat.add({}).then((DocumentReference doc) {
          chat = Chat(member: member, num_msg: 0, last_msg: "", id: doc.id);
          final json = chat.toFirestore();
          docChat.doc(doc.id).update(json);
        });
      }
      // ignore: use_build_context_synchronously
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChatMsg(
                    chat: chat,
                    reciver: reciver,
                    isNewWindows: true,
                  )));
    } on FirebaseAuthException catch (e) {
      Utils.showSnackBar(e.message);
      Navigator.of(context).pop();
    }
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

ButtonStyle savedButtonStyle(bool selected) {
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

ButtonStyle messageButtonStyle() {
  ColorScheme color =
      ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 168, 168, 168));
  return IconButton.styleFrom(
    foregroundColor: color.primary,
    backgroundColor: color.surfaceVariant,
    disabledForegroundColor: color.onSurface.withOpacity(0.38),
    disabledBackgroundColor: color.onSurface.withOpacity(0.12),
    hoverColor: color.primary.withOpacity(0.08),
    focusColor: color.primary.withOpacity(0.12),
    highlightColor: color.primary.withOpacity(0.12),
  );
}

ButtonStyle bookLessonButtonStyle() {
  ColorScheme color =
      ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 0, 215, 36));
  return IconButton.styleFrom(
    foregroundColor: color.primary,
    backgroundColor: color.surfaceVariant,
    disabledForegroundColor: color.onSurface.withOpacity(0.38),
    disabledBackgroundColor: color.onSurface.withOpacity(0.12),
    hoverColor: color.primary.withOpacity(0.08),
    focusColor: color.primary.withOpacity(0.12),
    highlightColor: color.primary.withOpacity(0.12),
  );
}
