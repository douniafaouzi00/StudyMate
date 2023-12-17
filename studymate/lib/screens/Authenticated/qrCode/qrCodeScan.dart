import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
//import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../../component/utils.dart';
import '../../../models/notification.dart';
import '../../../models/user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QrCodeScan extends StatefulWidget {
  final String? id;
  final Users? tutor;
  final String? student;
  final String? title;

  const QrCodeScan(
      {super.key,
      required this.id,
      required this.tutor,
      required this.student,
      required this.title});

  @override
  _QrCodeScanState createState() => _QrCodeScanState();
}

class _QrCodeScanState extends State<QrCodeScan> {
  final user = FirebaseAuth.instance.currentUser!;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool isMessageValid = true;

  Barcode? result;
  bool review = false;
  bool reviewed = false;
  QRViewController? controller;
  double rating = 3;
  List<dynamic> timeslot = [];
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      if (controller != null) {
        controller!.pauseCamera();
      }
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(20.0),
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
                            child: Text(
                                AppLocalizations.of(context)!.scanQrCodeTitle,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Color.fromARGB(255, 233, 64, 87),
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ))),
                      ]),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                            AppLocalizations.of(context)!
                                .scanQrCodeScanSubTitle,
                            style: TextStyle(
                              fontFamily: "Crimson Pro",
                              fontSize: 16,
                              color: Color.fromARGB(255, 104, 104, 104),
                            )),
                      ),
                      Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(20),
                            height: 300,
                            width: 300,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: (review == false)
                                  ? QRView(
                                      key: qrKey,
                                      onQRViewCreated: _onQRViewCreated,
                                    )
                                  : Container(
                                      color: Color.fromARGB(163, 233, 64, 87),
                                      child: const Icon(Icons.qr_code,
                                          color: Colors.white, size: 50),
                                    ),
                            ),
                          ),
                          (review == true)
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Text(AppLocalizations.of(context)!.review,
                                          style: TextStyle(
                                            fontFamily: "Crimson Pro",
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          )),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      (!reviewed)
                                          ? Text(
                                              AppLocalizations.of(context)!
                                                  .leaveReview,
                                              style: TextStyle(
                                                fontFamily: "Crimson Pro",
                                                fontSize: 16,
                                                color: Color.fromARGB(
                                                    255, 104, 104, 104),
                                              ))
                                          : Text(
                                              AppLocalizations.of(context)!
                                                  .thanksReview,
                                              style: TextStyle(
                                                fontFamily: "Crimson Pro",
                                                fontSize: 16,
                                                color: Color.fromARGB(
                                                    255, 104, 104, 104),
                                              )),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      RatingBar.builder(
                                        ignoreGestures:
                                            (reviewed) ? true : false,
                                        initialRating: 3,
                                        minRating: 1,
                                        direction: Axis.horizontal,
                                        allowHalfRating: true,
                                        itemCount: 5,
                                        itemSize: 30,
                                        itemPadding: const EdgeInsets.symmetric(
                                            horizontal: 4.0),
                                        itemBuilder: (context, _) => const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        onRatingUpdate: (r) {
                                          setState(() {
                                            rating = double.parse(
                                                r.toStringAsFixed(2));
                                            ;
                                          });
                                        },
                                      ),
                                      (!reviewed)
                                          ? Padding(
                                              padding: const EdgeInsets.all(35),
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  double updateRating = 0;
                                                  if (widget.tutor!.numRating >
                                                      0) {
                                                    double number = ((widget
                                                                    .tutor!
                                                                    .numRating *
                                                                double.parse(widget
                                                                    .tutor!
                                                                    .userRating) +
                                                            rating) /
                                                        (widget.tutor!
                                                                .numRating +
                                                            1));
                                                    updateRating = double.parse(
                                                        number.toStringAsFixed(
                                                            2));
                                                  } else {
                                                    updateRating = rating;
                                                  }
                                                  FirebaseFirestore.instance
                                                      .collection("users")
                                                      .doc(widget.tutor!.id)
                                                      .update({
                                                    'userRating':
                                                        updateRating.toString(),
                                                    'numRating': widget
                                                            .tutor!.numRating +
                                                        1
                                                  });
                                                  sendNot();
                                                  setState(() {
                                                    reviewed = true;
                                                  });
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                          255, 233, 64, 87),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  padding: (size.width <= 550)
                                                      ? const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 50,
                                                          vertical: 20)
                                                      : EdgeInsets.symmetric(
                                                          horizontal:
                                                              size.width * 0.2,
                                                          vertical: 25),
                                                ),
                                                child: Text(
                                                  AppLocalizations.of(context)!
                                                      .continueText,
                                                  style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 255, 255, 255),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : SizedBox(),
                                    ],
                                  ),
                                )
                              : Container(
                                  padding: EdgeInsets.all(20),
                                  child: (isMessageValid == true)
                                      ? Text(
                                          AppLocalizations.of(context)!
                                              .centerQrCode,
                                          style: TextStyle(
                                            fontFamily: "Crimson Pro",
                                            fontSize: 16,
                                            color: Color.fromARGB(
                                                255, 104, 104, 104),
                                          ))
                                      : Text(
                                          AppLocalizations.of(context)!
                                              .scanValidQR,
                                          style: TextStyle(
                                            fontFamily: "Crimson Pro",
                                            fontSize: 16,
                                            color: Color.fromARGB(
                                                255, 233, 64, 87),
                                          ))),
                        ],
                      )
                    ]))));
  }

  Future sendNot() async {
    try {
      final docNot = FirebaseFirestore.instance.collection('notification');
      await docNot.add({}).then((DocumentReference doc) {
        var notif = Notifications(
          id: doc.id,
          from_id: widget.student,
          to_id: widget.tutor!.id,
          type: "review",
          content: widget.title,
          view: false,
          eventId: widget.id,
          time: Timestamp.now(),
        );
        final json = notif.toFirestore();
        docNot.doc(doc.id).update(json);
      });
    } on FirebaseAuthException catch (e) {
      Utils.showSnackBar(e.message);
      Navigator.of(context).pop();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      result = scanData;
      if (result != null) {
        String? data = result!.code;
        if (data!.contains("timeslot")) {
          var jsonData = json.decode(data);
          List<dynamic> selTimeslots = jsonData['timeslot'];
          String studentId = jsonData['studentId'];
          String tutId = jsonData['tutorId'];
          String scheduleId = jsonData['id'];
          if (studentId == user.uid &&
              scheduleId == widget.id &&
              tutId == widget.tutor!.id) {
            List<dynamic> newTimeslot = [];
            timeslot.forEach((element) {
              if (!selTimeslots.contains(element)) {
                newTimeslot.add(element);
              }
            });
            try {
              if (widget.tutor!.hours > 0) {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.tutor!.id)
                    .update({
                  'hours': widget.tutor!.hours + selTimeslots.length
                }).whenComplete(() {});
              }
              if (newTimeslot.isEmpty) {
                FirebaseFirestore.instance
                    .collection('scheduled')
                    .doc(widget.id)
                    .delete();
              } else {
                FirebaseFirestore.instance
                    .collection('scheduled')
                    .doc(widget.id)
                    .update({'timeslot': newTimeslot});
              }
              setState(() {
                review = true;
              });
              controller.dispose();
            } catch (e) {
              print(e);
            }
          } else {
            setState(
              () {
                isMessageValid = false;
              },
            );
          }
        }
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
