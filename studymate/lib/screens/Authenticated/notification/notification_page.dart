import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studymate/models/notification.dart';
import 'package:studymate/screens/Authenticated/notification/notificationCard.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../models/user.dart';

class NotificationPage extends StatefulWidget {
  final Function callbackOpenChat;
  const NotificationPage({super.key, required this.callbackOpenChat});
  @override
  _NotificationState createState() => _NotificationState();
}

class _NotificationState extends State<NotificationPage> {
  final user = FirebaseAuth.instance.currentUser!;

  Stream<List<Notifications>> readNotifications() => FirebaseFirestore.instance
      .collection('notification')
      .where('to_id', isEqualTo: user.uid)
      .orderBy('time', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Notifications.fromFirestore(doc.data()))
          .toList());

  Stream<List<Users>> readUser(String? userId) => FirebaseFirestore.instance
      .collection('users')
      .where('id', isEqualTo: userId)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Users.fromJson(doc.data())).toList());

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double h = size.height;
    return Scaffold(
        //appBar: AppBar(),
        body: SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              Row(children: <Widget>[
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      size: 20,
                    )),
                Expanded(
                    child: Text(AppLocalizations.of(context)!.notifications,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ))),
              ]),
              SizedBox(
                height: h * 0.9,
                child: StreamBuilder<List<Notifications>>(
                    stream: readNotifications(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text('Something went wrong!');
                      } else if (snapshot.hasData) {
                        final notifications = snapshot.data!;
                        if (notifications.isNotEmpty) {
                          return ListView(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              children: notifications.map(buildNot).toList());
                        } else {
                          return SizedBox();
                        }
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    }),
              )
            ],
          )),
    ));
  }

  Widget buildNot(Notifications not) {
    return StreamBuilder<List<Users>>(
        stream: readUser(not.from_id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong!');
          } else if (snapshot.hasData) {
            final users = snapshot.data!;
            if (not.view == false) {
              FirebaseFirestore.instance
                  .collection('notification')
                  .doc(not.id)
                  .update({'view': true});
            }
            return NotificationCard(
              notification: not,
              user: users.first,
              callbackOpenChat: widget.callbackOpenChat,
            );
          } else {
            return SizedBox();
          }
        });
  }
}
