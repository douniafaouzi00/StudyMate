import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final List<dynamic>? member;
  final String? id;
  final String? from_uid;
  final String? last_msg;
  final Timestamp? last_time;
  final bool? view;
  final int? num_msg;

  Chat({
    this.from_uid,
    this.last_msg,
    this.last_time,
    this.view,
    this.member,
    this.num_msg,
    this.id,
  });

  factory Chat.fromFirestore(Map<String, dynamic> json) {
    return Chat(
      member: json['member'],
      last_msg: json['last_msg'],
      last_time: json['last_time'],
      view: json['view'],
      from_uid: json['from_uid'],
      num_msg: json['num_msg'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) "id": id,
      if (member != null) "member": member,
      if (last_msg != null) "last_msg": last_msg,
      if (last_time != null) "last_time": last_time,
      if (view != null) "view": view,
      if (num_msg != null) "num_msg": num_msg,
      if (from_uid != null) "from_uid": from_uid,
    };
  }
}
