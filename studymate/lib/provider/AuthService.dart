import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studymate/screens/Authenticated/authenticated.dart';

import '../models/user.dart';
import '../screens/Authenticated/FirstLogin/setUser.dart';

class AuthService extends StatelessWidget {
  Stream<List<Users>> readUser(String userId) => FirebaseFirestore.instance
      .collection('users')
      .where('id', isEqualTo: userId)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Users.fromJson(doc.data())).toList());

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
        stream: readUser(user.uid),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Scomething went wrong!'));
          } else if (snapshot.hasData) {
            var user = snapshot.data;
            if (user!.isNotEmpty &&
                user.first.categoriesOfInterest!.isNotEmpty) {
              return Authenticated();
            }
          }
          return SetUser();
        });
  }
}
