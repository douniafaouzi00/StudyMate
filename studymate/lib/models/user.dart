class Users {
  String id;
  final String firstname;
  final String lastname;
  final String profileImageURL;
  final List<dynamic>? categoriesOfInterest;
  final String userRating;
  final int hours;
  final int numRating;

  Users({
    required this.numRating,
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.profileImageURL,
    required this.userRating,
    this.categoriesOfInterest,
    required this.hours,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstname': firstname,
        'lastname': lastname,
        'profileImage': profileImageURL,
        'userRating': userRating,
        'hours': hours,
        'numRating': numRating,
        'categoriesOfInterest': categoriesOfInterest
      };

  static Users fromJson(Map<String, dynamic> json) => Users(
      id: json['id'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      profileImageURL: json['profileImage'],
      userRating: json['userRating'],
      categoriesOfInterest: json['categoriesOfInterest'],
      hours: json['hours'],
      numRating: json['numRating']);
}
