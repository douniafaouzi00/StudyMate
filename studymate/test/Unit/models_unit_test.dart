import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studymate/models/category.dart';
import 'package:studymate/models/chat.dart';
import 'package:studymate/models/lesson.dart';
import 'package:studymate/models/msg.dart';
import 'package:studymate/models/notification.dart';
import 'package:studymate/models/recordLessonViewed.dart';
import 'package:studymate/models/savedLesson.dart';
import 'package:studymate/models/scheduled.dart';
import 'package:studymate/models/timeslot.dart';
import 'package:studymate/models/user.dart';

void main() {
  group('Users', () {
    test('toJson() should return a valid JSON map', () {
      final user = Users(
        id: '123',
        firstname: 'John',
        lastname: 'Doe',
        profileImageURL: 'https://example.com/profile.jpg',
        userRating: '4.5',
        categoriesOfInterest: ['sports', 'technology'],
        hours: 10,
        numRating: 50,
      );

      final json = user.toJson();

      expect(json['id'], '123');
      expect(json['firstname'], 'John');
      expect(json['lastname'], 'Doe');
      expect(json['profileImage'], 'https://example.com/profile.jpg');
      expect(json['userRating'], '4.5');
      expect(json['categoriesOfInterest'], ['sports', 'technology']);
      expect(json['hours'], 10);
      expect(json['numRating'], 50);
    });

    test('fromJson() should create a valid Users object from JSON', () {
      final json = {
        'id': '123',
        'firstname': 'John',
        'lastname': 'Doe',
        'profileImage': 'https://example.com/profile.jpg',
        'userRating': '4.5',
        'categoriesOfInterest': ['sports', 'technology'],
        'hours': 10,
        'numRating': 50,
      };

      final user = Users.fromJson(json);

      expect(user.id, '123');
      expect(user.firstname, 'John');
      expect(user.lastname, 'Doe');
      expect(user.profileImageURL, 'https://example.com/profile.jpg');
      expect(user.userRating, '4.5');
      expect(user.categoriesOfInterest, ['sports', 'technology']);
      expect(user.hours, 10);
      expect(user.numRating, 50);
    });
  });
  group('TimeslotsWeek', () {
    test('fromJson() should create a valid TimeslotsWeek object from JSON', () {
      final json = {
        'id': '123',
        'userId': '456',
        'monday': [1, 2, 3],
        'tuesday': [4, 5, 6],
        'wednesday': [7, 8, 9],
        'thursday': [10, 11, 12],
        'friday': [13, 14, 15],
        'saturday': [16, 17, 18],
        'sunday': [19, 20, 21],
      };

      final timeslotsWeek = TimeslotsWeek.fromJson(json);

      expect(timeslotsWeek.id, '123');
      expect(timeslotsWeek.userId, '456');
      expect(timeslotsWeek.monday, [1, 2, 3]);
      expect(timeslotsWeek.tuesday, [4, 5, 6]);
      expect(timeslotsWeek.wednesday, [7, 8, 9]);
      expect(timeslotsWeek.thursday, [10, 11, 12]);
      expect(timeslotsWeek.friday, [13, 14, 15]);
      expect(timeslotsWeek.saturday, [16, 17, 18]);
      expect(timeslotsWeek.sunday, [19, 20, 21]);
    });

    test('toFirestore() should return a valid Firestore map', () {
      final timeslotsWeek = TimeslotsWeek(
        id: '123',
        userId: '456',
        monday: [1, 2, 3],
        tuesday: [4, 5, 6],
        wednesday: [7, 8, 9],
        thursday: [10, 11, 12],
        friday: [13, 14, 15],
        saturday: [16, 17, 18],
        sunday: [19, 20, 21],
      );

      final firestoreMap = timeslotsWeek.toFirestore();

      expect(firestoreMap['id'], '123');
      expect(firestoreMap['userId'], '456');
      expect(firestoreMap['monday'], [1, 2, 3]);
      expect(firestoreMap['tuesday'], [4, 5, 6]);
      expect(firestoreMap['wednesday'], [7, 8, 9]);
      expect(firestoreMap['thursday'], [10, 11, 12]);
      expect(firestoreMap['friday'], [13, 14, 15]);
      expect(firestoreMap['saturday'], [16, 17, 18]);
      expect(firestoreMap['sunday'], [19, 20, 21]);
    });
  });

  group('Scheduled', () {
    test(
        'fromFirestore() should create a valid Scheduled object from Firestore data',
        () {
      final firestoreData = {
        'id': '123',
        'lessionId': '456',
        'studentId': '789',
        'tutorId': '987',
        'title': 'Math Lesson',
        'category': 'Mathematics',
        'timeslot': ['10:00 AM', '11:00 AM'],
        'date': Timestamp.fromDate(DateTime(2023, 7, 12)),
        'accepted': true,
      };

      final scheduled = Scheduled.fromFirestore(firestoreData);

      expect(scheduled.id, '123');
      expect(scheduled.lessionId, '456');
      expect(scheduled.studentId, '789');
      expect(scheduled.tutorId, '987');
      expect(scheduled.title, 'Math Lesson');
      expect(scheduled.category, 'Mathematics');
      expect(scheduled.timeslot, ['10:00 AM', '11:00 AM']);
      expect(scheduled.date, Timestamp.fromDate(DateTime(2023, 7, 12)));
      expect(scheduled.accepted, true);
    });

    test('toFirestore() should return a valid Firestore map', () {
      final scheduled = Scheduled(
        id: '123',
        lessionId: '456',
        studentId: '789',
        tutorId: '987',
        title: 'Math Lesson',
        category: 'Mathematics',
        timeslot: ['10:00 AM', '11:00 AM'],
        date: Timestamp.fromDate(DateTime(2023, 7, 12)),
        accepted: true,
      );

      final firestoreMap = scheduled.toFirestore();

      expect(firestoreMap['id'], '123');
      expect(firestoreMap['lessionId'], '456');
      expect(firestoreMap['studentId'], '789');
      expect(firestoreMap['tutorId'], '987');
      expect(firestoreMap['title'], 'Math Lesson');
      expect(firestoreMap['category'], 'Mathematics');
      expect(firestoreMap['timeslot'], ['10:00 AM', '11:00 AM']);
      expect(firestoreMap['date'], Timestamp.fromDate(DateTime(2023, 7, 12)));
      expect(firestoreMap['accepted'], true);
    });
  });

  group('SavedLesson', () {
    test(
        'fromFirestore() should create a valid SavedLesson object from Firestore data',
        () {
      final firestoreData = {
        'id': '123',
        'lessonId': '456',
        'userId': '789',
      };

      final savedLesson = SavedLesson.fromFirestore(firestoreData);

      expect(savedLesson.id, '123');
      expect(savedLesson.lessonId, '456');
      expect(savedLesson.userId, '789');
    });

    test('toFirestore() should return a valid Firestore map', () {
      final savedLesson = SavedLesson(
        id: '123',
        lessonId: '456',
        userId: '789',
      );

      final firestoreMap = savedLesson.toFirestore();

      expect(firestoreMap['id'], '123');
      expect(firestoreMap['lessonId'], '456');
      expect(firestoreMap['userId'], '789');
    });
  });

  group('RecordLessonView', () {
    test(
        'fromFirestore() should create a valid RecordLessonView object from Firestore data',
        () {
      final firestoreData = {
        'id': '123',
        'lessonId': '456',
        'timestamp': Timestamp.fromDate(DateTime(2023, 7, 12)),
        'userId': '789',
      };

      final recordLessonView = RecordLessonView.fromFirestore(firestoreData);

      expect(recordLessonView.id, '123');
      expect(recordLessonView.lessonId, '456');
      expect(recordLessonView.timestamp,
          Timestamp.fromDate(DateTime(2023, 7, 12)));
      expect(recordLessonView.userId, '789');
    });

    test('toFirestore() should return a valid Firestore map', () {
      final recordLessonView = RecordLessonView(
        id: '123',
        lessonId: '456',
        timestamp: Timestamp.fromDate(DateTime(2023, 7, 12)),
        userId: '789',
      );

      final firestoreMap = recordLessonView.toFirestore();

      expect(firestoreMap['id'], '123');
      expect(firestoreMap['lessonId'], '456');
      expect(
          firestoreMap['timestamp'], Timestamp.fromDate(DateTime(2023, 7, 12)));
      expect(firestoreMap['userId'], '789');
    });
  });

  group('Notifications', () {
    test(
        'fromFirestore() should create a valid Notifications object from Firestore data',
        () {
      final firestoreData = {
        'id': '123',
        'from_id': '456',
        'to_id': '789',
        'eventId': 'abc',
        'content': 'Notification content',
        'type': 'info',
        'view': true,
        'time': Timestamp.fromDate(DateTime(2023, 7, 12)),
      };

      final notifications = Notifications.fromFirestore(firestoreData);

      expect(notifications.id, '123');
      expect(notifications.from_id, '456');
      expect(notifications.to_id, '789');
      expect(notifications.eventId, 'abc');
      expect(notifications.content, 'Notification content');
      expect(notifications.type, 'info');
      expect(notifications.view, true);
      expect(notifications.time, Timestamp.fromDate(DateTime(2023, 7, 12)));
    });

    test('toFirestore() should return a valid Firestore map', () {
      final notifications = Notifications(
        id: '123',
        from_id: '456',
        to_id: '789',
        eventId: 'abc',
        content: 'Notification content',
        type: 'info',
        view: true,
        time: Timestamp.fromDate(DateTime(2023, 7, 12)),
      );

      final firestoreMap = notifications.toFirestore();

      expect(firestoreMap['id'], '123');
      expect(firestoreMap['from_id'], '456');
      expect(firestoreMap['to_id'], '789');
      expect(firestoreMap['eventId'], 'abc');
      expect(firestoreMap['content'], 'Notification content');
      expect(firestoreMap['type'], 'info');
      expect(firestoreMap['view'], true);
      expect(firestoreMap['time'], Timestamp.fromDate(DateTime(2023, 7, 12)));
    });
  });
  group('Msg', () {
    test('fromFirestore() should create a valid Msg object from Firestore data',
        () {
      final firestoreData = {
        'id': '123',
        'chatId': '456',
        'from_uid': '789',
        'content': 'Message content',
        'addtime': Timestamp.fromDate(DateTime(2023, 7, 12)),
        'view': true,
      };

      final msg = Msg.fromFirestore(firestoreData);

      expect(msg.id, '123');
      expect(msg.chatId, '456');
      expect(msg.from_uid, '789');
      expect(msg.content, 'Message content');
      expect(msg.addtime, Timestamp.fromDate(DateTime(2023, 7, 12)));
      expect(msg.view, true);
    });

    test('toFirestore() should return a valid Firestore map', () {
      final msg = Msg(
        id: '123',
        chatId: '456',
        from_uid: '789',
        content: 'Message content',
        addtime: Timestamp.fromDate(DateTime(2023, 7, 12)),
        view: true,
      );

      final firestoreMap = msg.toFirestore();

      expect(firestoreMap['id'], '123');
      expect(firestoreMap['chatId'], '456');
      expect(firestoreMap['from_uid'], '789');
      expect(firestoreMap['content'], 'Message content');
      expect(
          firestoreMap['addtime'], Timestamp.fromDate(DateTime(2023, 7, 12)));
      expect(firestoreMap['view'], true);
    });
  });
  group('Lesson', () {
    test('fromJson() should create a valid Lesson object from JSON', () {
      final json = {
        'id': '123',
        'title': 'Math Lesson',
        'location': 'Virtual',
        'description': 'Learn math concepts',
        'userTutor': 'John Doe',
        'category': 'Mathematics',
      };

      final lesson = Lesson.fromJson(json);

      expect(lesson.id, '123');
      expect(lesson.title, 'Math Lesson');
      expect(lesson.location, 'Virtual');
      expect(lesson.description, 'Learn math concepts');
      expect(lesson.userTutor, 'John Doe');
      expect(lesson.category, 'Mathematics');
    });

    test('toFirestore() should return a valid Firestore map', () {
      final lesson = Lesson(
        id: '123',
        title: 'Math Lesson',
        location: 'Virtual',
        description: 'Learn math concepts',
        userTutor: 'John Doe',
        category: 'Mathematics',
      );

      final firestoreMap = lesson.toFirestore();

      expect(firestoreMap['id'], '123');
      expect(firestoreMap['title'], 'Math Lesson');
      expect(firestoreMap['location'], 'Virtual');
      expect(firestoreMap['description'], 'Learn math concepts');
      expect(firestoreMap['userTutor'], 'John Doe');
      expect(firestoreMap['category'], 'Mathematics');
    });
  });

  group('Chat', () {
    test(
        'fromFirestore() should create a valid Chat object from Firestore data',
        () {
      final firestoreData = {
        'member': ['user1', 'user2'],
        'id': '123',
        'from_uid': 'user1',
        'last_msg': 'Hello',
        'last_time': Timestamp.fromDate(DateTime(2023, 7, 12)),
        'view': true,
        'num_msg': 5,
      };

      final chat = Chat.fromFirestore(firestoreData);

      expect(chat.member, ['user1', 'user2']);
      expect(chat.id, '123');
      expect(chat.from_uid, 'user1');
      expect(chat.last_msg, 'Hello');
      expect(chat.last_time, Timestamp.fromDate(DateTime(2023, 7, 12)));
      expect(chat.view, true);
      expect(chat.num_msg, 5);
    });

    test('toFirestore() should return a valid Firestore map', () {
      final chat = Chat(
        member: ['user1', 'user2'],
        id: '123',
        from_uid: 'user1',
        last_msg: 'Hello',
        last_time: Timestamp.fromDate(DateTime(2023, 7, 12)),
        view: true,
        num_msg: 5,
      );

      final firestoreMap = chat.toFirestore();

      expect(firestoreMap['member'], ['user1', 'user2']);
      expect(firestoreMap['id'], '123');
      expect(firestoreMap['from_uid'], 'user1');
      expect(firestoreMap['last_msg'], 'Hello');
      expect(
          firestoreMap['last_time'], Timestamp.fromDate(DateTime(2023, 7, 12)));
      expect(firestoreMap['view'], true);
      expect(firestoreMap['num_msg'], 5);
    });
  });
  group('Category', () {
    test('fromJson() should create a valid Category object from JSON', () {
      final json = {
        'name': 'Mathematics',
        'imageURL': 'https://example.com/math.png',
      };

      final category = Category.fromJson(json);

      expect(category.name, 'Mathematics');
      expect(category.imageURL, 'https://example.com/math.png');
    });
  });
}
