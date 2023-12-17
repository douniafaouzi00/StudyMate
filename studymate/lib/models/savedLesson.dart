class SavedLesson {
  final String? id;
  final String? lessonId;
  final String? userId;

  SavedLesson({
    this.id,
    this.lessonId,
    this.userId,
  });

  factory SavedLesson.fromFirestore(Map<String, dynamic> json) {
    return SavedLesson(
        id: json['id'],
        lessonId: json['lessonId'],
        userId: json['userId']);
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) 'id': id,
      if (lessonId != null) "lessonId": lessonId,
      if (userId != null) "userId": userId,
    };
  }
}
