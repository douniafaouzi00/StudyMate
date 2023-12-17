import 'package:cloud_firestore/cloud_firestore.dart';

class Msg {
  final String? id;
  final String? chatId;
  final String? from_uid;
  final String? content;
  final Timestamp? addtime;
  final bool view;

  Msg({
    this.id,
    this.chatId,
    this.from_uid,
    this.content,
    this.addtime,
    this.view = false,
  });

  factory Msg.fromFirestore(Map<String, dynamic> json) {
    return Msg(
        id: json['id'],
        chatId: json['chatId'],
        from_uid: json['from_uid'],
        content: json['content'],
        addtime: json['addtime'],
        view: json['view']);
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) 'id': id,
      if (chatId != null) "chatId": chatId,
      if (from_uid != null) "from_uid": from_uid,
      if (content != null) "content": content,
      if (addtime != null) "addtime": addtime,
      "view": view,
    };
  }
}
