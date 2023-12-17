import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:studymate/models/user.dart';
import 'package:studymate/screens/Authenticated/Chat/share_position.dart';
import 'dart:math';

import 'custom_shape.dart';

class ReciviedMessage extends StatelessWidget {
  final String? message;
  final Users reciver;
  final Timestamp? addTime;
  const ReciviedMessage(
      {super.key, this.message, this.addTime, required this.reciver});

  @override
  Widget build(BuildContext context) {
    String pos = message!;
    double latitude = 0.0;
    double longitude = 0.0;
    if (pos.contains("l4t:") &&
        pos.contains("l0n:") &&
        pos.contains(";") &&
        pos.length > 9) {
      try {
        latitude = double.parse(pos.substring(4, pos.indexOf(";")));
        longitude = double.parse(pos.substring(pos.indexOf(";") + 5));
      } catch (e) {
        print(e);
      }
    }
    return Padding(
      padding: const EdgeInsets.only(right: 18.0, left: 18, top: 15, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          const SizedBox(height: 30),
          messageTextGroup(context, latitude, longitude),
        ],
      ),
    );
  }

  Widget messageTextGroup(
          BuildContext context, double latitude, double longitude) =>
      Flexible(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(pi),
            child: CustomPaint(
              painter: CustomShape(Color.fromARGB(255, 242, 210, 210)),
            ),
          ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 242, 210, 210),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                (message!.contains("l4t:") &&
                        message!.contains("l0n:") &&
                        message!.contains(";") &&
                        message!.length > 9)
                    ? InkWell(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SharePosition(
                                      latitude: latitude,
                                      longitude: longitude,
                                      reciver: reciver,
                                    ))),
                        child: Container(
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color.fromARGB(255, 255, 255, 255)),
                          child: Icon(Icons.map_rounded,
                              color: Color.fromARGB(255, 233, 64, 87),
                              size: 30),
                        ))
                    : Text(
                        message!,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 14),
                      ),
                Text(
                  DateFormat.Hm().format(addTime!.toDate()),
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                  textAlign: TextAlign.left,
                ),
              ]),
            ),
          ),
        ],
      ));
}
