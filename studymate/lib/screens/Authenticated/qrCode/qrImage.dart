import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRImage extends StatelessWidget {
  const QRImage(this.controller,
      {super.key,
      required this.tutorId,
      required this.studentId,
      required this.id});

  final List<String> controller;
  final String tutorId;
  final String studentId;
  final String? id;

  @override
  Widget build(BuildContext context) {
    String data = "";
    if (controller.isNotEmpty) {
      data =
          '{"id":"$id","studentId":"$studentId", "tutorId":"$tutorId","timeslot": [';
      if (controller.length > 1) {
        for (int i = 0; i < controller.length - 1; i++) {
          data += '"${controller[i]}",';
        }
        data += '"${controller[controller.length - 1]}"';
      } else {
        data += '"${controller[0]}"';
      }

      data += "]}";
    }
    return Center(
      child: (data != "")
          ? QrImageView(
              data: data,
              size: 280,
              version: QrVersions.auto,
            )
          : SizedBox(),
    );
  }
}
