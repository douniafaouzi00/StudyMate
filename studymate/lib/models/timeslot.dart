class TimeslotsWeek {
  final String? id;

  final String userId;
  List<dynamic> monday;
  List<dynamic> tuesday;
  List<dynamic> wednesday;
  List<dynamic> thursday;
  List<dynamic> friday;
  List<dynamic> saturday;
  List<dynamic> sunday;

  TimeslotsWeek({
    this.id,
    required this.userId,
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
  });

  static TimeslotsWeek fromJson(Map<String, dynamic> json) => TimeslotsWeek(
        id: json['id'],
        userId: json['userId'],
        monday: json['monday'],
        tuesday: json['tuesday'],
        wednesday: json['wednesday'],
        thursday: json['thursday'],
        friday: json['friday'],
        saturday: json['saturday'],
        sunday: json['sunday'],
      );

  Map<String, dynamic> toFirestore() {
    var map = {
      "id": id,
      "userId": userId,
      "monday": monday,
      "tuesday": tuesday,
      "wednesday": wednesday,
      "thursday": thursday,
      "friday": friday,
      "saturday": saturday,
      "sunday": sunday,
    };
    return map;
  }
}

class Week {}
