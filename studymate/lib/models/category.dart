class Category {
  final String name;
  final String imageURL;

  Category({
    required this.name,
    required this.imageURL,
  });
  static Category fromJson(Map<String, dynamic> json) => Category(
        name: json['name'],
        imageURL: json['imageURL'],
      );
}
