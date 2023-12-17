import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../service/storage_service.dart';
import '../../../models/notification.dart';
import '../../../models/user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NotificationCard extends StatelessWidget {
  final Notifications notification;
  final Users user;
  final Function callbackOpenChat;

  const NotificationCard(
      {super.key,
      required this.notification,
      required this.user,
      required this.callbackOpenChat});

  @override
  Widget build(BuildContext context) {
    final Storage storage = Storage();
    final currUser = FirebaseAuth.instance.currentUser!;

    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              height: 60,
              width: 60,
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
                        return Container();
                      }
                    }),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: (notification.type == "message")
                  ? GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        callbackOpenChat();
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(context)!.newMessage,
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 233, 64, 87),
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(
                                  notification.time!.toDate().month <
                                              Timestamp.now().toDate().month ||
                                          notification.time!.toDate().day <
                                              Timestamp.now().toDate().day
                                      ? DateFormat.yMd()
                                          .format(notification.time!.toDate())
                                      : DateFormat.Hm()
                                          .format(notification.time!.toDate()),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 47, 47, 47))),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: Text(
                                '${user.firstname} ${user.lastname}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              )),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child:
                                      (notification.content!.contains("l4t:") &&
                                              notification.content!
                                                  .contains("l0n:"))
                                          ? Text(AppLocalizations.of(context)!
                                              .sharedPosition)
                                          : Text(notification.content!)),
                            ],
                          ),
                        ],
                      ),
                    )
                  : ((notification.type == "request")
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child: RichText(
                                  text: TextSpan(
                                    text: '${user.firstname} ${user.lastname} ',
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text:
                                            '${AppLocalizations.of(context)!.notifRequestTutoring} ${notification.content}',
                                        /*QUI*/
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ],
                                  ),
                                )),
                                Text(
                                    notification.time!.toDate().month <
                                                Timestamp.now()
                                                    .toDate()
                                                    .month ||
                                            notification.time!.toDate().day <
                                                Timestamp.now().toDate().day
                                        ? DateFormat.yMd()
                                            .format(notification.time!.toDate())
                                        : DateFormat.Hm().format(
                                            notification.time!.toDate()),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                        color:
                                            Color.fromARGB(255, 47, 47, 47))),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 233, 64, 87),
                                  ),
                                  onPressed: () async {
                                    final docChat = FirebaseFirestore.instance
                                        .collection('notification');
                                    await docChat
                                        .add({}).then((DocumentReference doc) {
                                      var notif = Notifications(
                                        id: doc.id,
                                        from_id: currUser.uid,
                                        to_id: user.id,
                                        type: "accept",
                                        content: notification.content,
                                        view: false,
                                        time: Timestamp.now(),
                                      );
                                      final json = notif.toFirestore();
                                      docChat.doc(doc.id).update(json);
                                    });

                                    FirebaseFirestore.instance
                                        .collection('scheduled')
                                        .doc(notification.eventId)
                                        .update({'accepted': true});
                                    FirebaseFirestore.instance
                                        .collection('notification')
                                        .doc(notification.id)
                                        .delete();
                                  },
                                  child: Text(
                                      AppLocalizations.of(context)!.accept,
                                      style: const TextStyle(
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                      )),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                          255, 255, 255, 255),
                                      side: const BorderSide(
                                        color: Color.fromARGB(255, 233, 64, 87),
                                      )),
                                  onPressed: () async {
                                    final docChat = FirebaseFirestore.instance
                                        .collection('notification');
                                    await docChat
                                        .add({}).then((DocumentReference doc) {
                                      var notif = Notifications(
                                        id: doc.id,
                                        from_id: currUser.uid,
                                        to_id: user.id,
                                        type: "reject",
                                        content: notification.content,
                                        view: false,
                                        time: Timestamp.now(),
                                      );
                                      final json = notif.toFirestore();
                                      docChat.doc(doc.id).update(json);
                                    });

                                    FirebaseFirestore.instance
                                        .collection('scheduled')
                                        .doc(notification.eventId)
                                        .delete();
                                    FirebaseFirestore.instance
                                        .collection('notification')
                                        .doc(notification.id)
                                        .delete();
                                  },
                                  child: Text(
                                      AppLocalizations.of(context)!.reject,
                                      style: const TextStyle(
                                        color: Color.fromARGB(255, 233, 64, 87),
                                      )),
                                )
                              ],
                            ),
                          ],
                        )
                      : ((notification.type == "review")
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                  Row(
                                    children: [
                                      Expanded(
                                          child: RichText(
                                        text: TextSpan(
                                          text:
                                              '${user.firstname} ${user.lastname} ',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: AppLocalizations.of(
                                                            context)!
                                                        .leftReview +
                                                    " ${notification.content}",
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.black)),
                                          ],
                                        ),
                                      )),
                                      Text(
                                          notification.time!.toDate().month <
                                                      Timestamp.now()
                                                          .toDate()
                                                          .month ||
                                                  notification.time!
                                                          .toDate()
                                                          .day <
                                                      Timestamp.now()
                                                          .toDate()
                                                          .day
                                              ? DateFormat.yMd().format(
                                                  notification.time!.toDate())
                                              : DateFormat.Hm().format(
                                                  notification.time!.toDate()),
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 47, 47, 47))),
                                    ],
                                  ),
                                ])
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                  Row(
                                    children: [
                                      Expanded(
                                          child: RichText(
                                        text: TextSpan(
                                          text:
                                              '${user.firstname} ${user.lastname} ',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: (notification.type ==
                                                        "accept")
                                                    ? "${AppLocalizations.of(context)!.acceptedTutoring} ${notification.content}"
                                                    : "${AppLocalizations.of(context)!.rejectedTutoring} ${notification.content}",
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.black)),
                                          ],
                                        ),
                                      )),
                                      Text(
                                          notification.time!.toDate().month <
                                                      Timestamp.now()
                                                          .toDate()
                                                          .month ||
                                                  notification.time!
                                                          .toDate()
                                                          .day <
                                                      Timestamp.now()
                                                          .toDate()
                                                          .day
                                              ? DateFormat.yMd().format(
                                                  notification.time!.toDate())
                                              : DateFormat.Hm().format(
                                                  notification.time!.toDate()),
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 47, 47, 47))),
                                    ],
                                  ),
                                ]))),
            ),
          ],
        ),
        const Divider(
          color: Colors.grey,
        ),
        const SizedBox(
          height: 20,
        )
      ],
    );
  }
}
