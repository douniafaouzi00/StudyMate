class Lesson {
  final String? id;
  final String title;
  final String location;
  final String description;
  final String userTutor;
  final String category;

  Lesson({
    this.id,
    required this.title,
    required this.location,
    required this.description,
    required this.userTutor,
    required this.category,
  });
  static Lesson fromJson(Map<String, dynamic> json) => Lesson(
        id: json['id'],
        title: json['title'],
        location: json['location'],
        description: json['description'],
        userTutor: json['userTutor'],
        category: json['category'],
      );

  Map<String, dynamic> toFirestore() {
    return {
      "id": id,
      "title": title,
      "location": location,
      "description": description,
      "userTutor": userTutor,
      "category": category,
    };
  }
}
