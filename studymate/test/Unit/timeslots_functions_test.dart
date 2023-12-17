import 'package:flutter_test/flutter_test.dart';
import 'package:studymate/models/timeslot.dart';
import 'package:studymate/functions/timeslotsFunctions.dart';

void main() {
  group('time slots', () {
    test('convertListTimestampToPrint', () {
      //setup
      final time = TimeslotsWeek(
        id: 'test',
        userId: 'test',
        monday: ['07:00 - 08:00','08:00 - 09:00','09:00 - 10:00'],
        tuesday:[],
        wednesday: [],
        thursday: [],
        friday: [],
        saturday: [],
        sunday: [],
      );
      final expected =['07:00 - 10:00'];
      //do
      final result = convertListTimestampToPrint(time.monday);
      //test
      expect(result, expected);
    });
    test('getTimeslotOfDay', () {
      //setup
      final time = TimeslotsWeek(
        id: 'test',
        userId: 'test',
        monday: ['07:00 - 08:00','08:00 - 09:00','09:00 - 10:00'],
        tuesday:[],
        wednesday: [],
        thursday: [],
        friday: [],
        saturday: [],
        sunday: [],
      );
      final expected =['07:00 - 08:00','08:00 - 09:00','09:00 - 10:00'];
      //do
      final result = getTimeslotOfDay(1,time);
      //test
      expect(result, expected);
    });

  });
}