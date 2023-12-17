import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studymate/models/notification.dart';
import 'package:studymate/models/user.dart';
import 'package:studymate/screens/Authenticated/qrCode/qrCodeGenerate.dart';
import 'package:studymate/screens/Authenticated/qrCode/qrCodeScan.dart';

import '../../../service/storage_service.dart';
import '../NextScheduled/next_scheduled.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ClassCard extends StatelessWidget {
  final String? id;
  final String? title;
  //final String? tutorId;
  //final String? studentId;
  //final String? firstname;
  //final String? lastname;
  final Users tutor;
  final Users student;
  //final String? userImageURL;
  final Timestamp? date;
  final List<dynamic>? timeslot;
  final bool isTutor;
  final bool? lessonPage;
  const ClassCard(
      {super.key,
      //this.tutorId,
      //this.studentId,
      required this.id,
      required this.title,
      //required this.firstname,
      //required this.lastname,
      //required this.userImageURL,
      required this.student,
      required this.tutor,
      required this.date,
      required this.timeslot,
      required this.isTutor,
      required this.lessonPage});

  Future<void> _showMyDialog(BuildContext context) async {
    final currUser = FirebaseAuth.instance.currentUser!;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.delete),
          content: SingleChildScrollView(
            child: Text(AppLocalizations.of(context)!.deleteMessage),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.confirm),
              onPressed: () async {
                FirebaseFirestore.instance
                    .collection("scheduled")
                    .doc(id)
                    .delete();
                FirebaseFirestore.instance
                    .collection("users")
                    .doc(student.id)
                    .update({"hours": student.hours + timeslot!.length});
                final docChat =
                    FirebaseFirestore.instance.collection('notification');
                await docChat.add({}).then((DocumentReference doc) {
                  var notif = Notifications(
                    id: doc.id,
                    from_id: currUser.uid,
                    to_id: (currUser.uid == student.id) ? tutor.id : student.id,
                    type: "response",
                    content:
                        " deleted the ${(isTutor) ? "tutoring" : "lesson"} on ${DateFormat.yMd().format(date!.toDate())}",
                    view: false,
                    time: Timestamp.now(),
                  );
                  final json = notif.toFirestore();
                  docChat.doc(doc.id).update(json);
                });

                Navigator.pop(context, true);
              },
            ),
            
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Storage storage = Storage();

    return Card(
      elevation: 5,
      
      surfaceTintColor: Colors.white,
      child: Container(
        height: 200,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(children: [
                SizedBox(
                  height: 70,
                  width: 70,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child: FutureBuilder(
                        future: (isTutor)
                            ? storage.downloadURL(student.profileImageURL)
                            : storage.downloadURL(tutor.profileImageURL),
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
                const SizedBox(width: 20),
                Expanded(
                    child: Column(children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title!,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                              color: Color.fromARGB(255, 233, 64, 87),
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            _showMyDialog(context);
                          },
                          icon: const Icon(Icons.delete,
                              color: Color.fromARGB(255, 233, 64, 87), size: 20)),
                      IconButton(
                          onPressed: () {
                            if (isTutor) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => QrCodeGenerate(
                                            id: id,
                                            studentId: student.id,
                                          )));
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => QrCodeScan(
                                            id: id,
                                            tutor: tutor,
                                            student: student.id,
                                            title: title,
                                          )));
                            }
                          },
                          icon: const Icon(Icons.qr_code,
                              color: Color.fromARGB(255, 233, 64, 87), size: 20)),
                    ],
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Row(
                    children: [
                      Text(
                        (isTutor)
                            ? "${AppLocalizations.of(context)!.student}:  "
                            : "${AppLocalizations.of(context)!.tutor}:  ",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: (isTutor)
                            ? Text("${student.firstname} ${student.lastname}")
                            : Text("${tutor.firstname} ${tutor.lastname}"),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "${AppLocalizations.of(context)!.date}:   ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Text(DateFormat.yMd().format(date!.toDate())),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 10),
                    height: 40,
                    child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,
                                childAspectRatio: 0.3,
                                mainAxisSpacing: 2),
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: timeslot!.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: const Color.fromARGB(255, 233, 64, 87),
                                    width: 1)),
                            child: Center(
                              child: Text(
                                timeslot![index],
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          );
                        }),
                  )
                ]))
              ]),
              (lessonPage != null && lessonPage == false)
                  ? Container(
                      height: 35,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                            onPressed: () {
                              isTutor == false
                                  ? Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const NextScheduled(
                                                isTutoring: false,
                                              )))
                                  : Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const NextScheduled(
                                                isTutoring: true,
                                              )));
                            },
                            child: Text(
                              AppLocalizations.of(context)!.seeNext,
                              textAlign: TextAlign.right,
                            )),
                      ),
                    )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
