class Book {
  final String name;
  final String url;
  final List<dynamic> author_name;
  final int first_publish_year;
  final int number_of_pages;

  Book(
      {required this.name,
      required this.url,
      required this.author_name,
      required this.first_publish_year,
      required this.number_of_pages});
}
