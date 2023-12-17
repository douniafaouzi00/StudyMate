import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studymate/models/recordLessonViewed.dart';
import 'package:studymate/screens/Authenticated/Search/widgets/autocomplete_searchbar_searchpage.dart';
import 'package:studymate/screens/Authenticated/Search/widgets/category_card.dart';
import 'package:studymate/screens/Authenticated/common_widgets/lesson_card.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../models/book.dart';
import '../../../models/category.dart';
import '../../../models/lesson.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SearchPage extends StatefulWidget {
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final userLog = FirebaseAuth.instance.currentUser!;
  String? selectedCategory;
  String? selectedLesson;
  String? input;
  List<Book> bookView = [];
  bool isBusyBook = false;
  Stream<List<RecordLessonView>> readRecordLesson() =>
      FirebaseFirestore.instance
          .collection('recordLessonsViewed')
          .where('userId', isEqualTo: userLog.uid)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => RecordLessonView.fromFirestore(doc.data()))
              .toList());

  Stream<List<Category>> readCategory() => FirebaseFirestore.instance
      .collection('categories')
      .orderBy('name')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Category.fromJson(doc.data())).toList());

  Stream<List<Lesson>> readAllLessons() => FirebaseFirestore.instance
      .collection('lessons')
      .where('userTutor', isNotEqualTo: userLog.uid)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Lesson.fromJson(doc.data())).toList());

  Stream<List<Lesson>> readLessonsById(String lessonId) =>
      FirebaseFirestore.instance
          .collection('lessons')
          .where('id', isEqualTo: lessonId)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => Lesson.fromJson(doc.data())).toList());

  Stream<List<Lesson>> readLessonsByCategory(String category) =>
      FirebaseFirestore.instance
          .collection('lessons')
          .where('userTutor', isNotEqualTo: userLog.uid)
          .where('category', isEqualTo: category)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => Lesson.fromJson(doc.data())).toList());

  Stream<List<Lesson>> readLessonsByTitle(String title) =>
      FirebaseFirestore.instance
          .collection('lessons')
          .where('userTutor', isNotEqualTo: userLog.uid)
          .where('title', isEqualTo: title)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => Lesson.fromJson(doc.data())).toList());

  Stream<List<Lesson>> readLessonsByCategoryTitle(
          String category, String title) =>
      FirebaseFirestore.instance
          .collection('lessons')
          .where('userTutor', isNotEqualTo: userLog.uid)
          .where('category', isEqualTo: category)
          .where('title', isEqualTo: title)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => Lesson.fromJson(doc.data())).toList());

  Future<List<Book>> _fetchData(String value) async {
    setState(() {
      isBusyBook = true;
    });
    List<Book> books = [];
    if (value != "") {
      List<String> values = value.split(RegExp(r"\s+"));
      String name = "";
      values.forEach((element) {
        name += "$element+";
      });
      final String apiUrl =
          'https://openlibrary.org/search.json?q=${name.substring(0, name.length - 1)}';
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data["docs"];
        int i = 0;
        loop:
        for (final element in list) {
          if (element["ebook_access"] == "borrowable" &&
              element["has_fulltext"] == true) {
            Book temp = Book(
                name: (element["title"] != null) ? element["title"] : "",
                url: (element["key"] != null) ? element["key"] : "",
                author_name: (element["author_name"] != null)
                    ? element["author_name"]
                    : [],
                first_publish_year: (element["first_publish_year"] != null)
                    ? element["first_publish_year"]
                    : 0,
                number_of_pages: (element["number_of_pages_median"] != null)
                    ? element["number_of_pages_median"]
                    : 0);
            if (!books.contains(temp)) {
              books.add(temp);
              i++;
            }
          }
          if (i == 10) {
            break loop;
          }
        }

        // Process and use the fetched data as per your requirements
      } else {
        print('Error: ${response.statusCode}');
      }
    }
    setState(() {
      isBusyBook = false;
    });
    return books;
  }

  showAlertDialog(BuildContext context, String? title, String? msg) {
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(title!),
      content: Text(msg!),
      actions: [
        okButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _openURL(Uri url) async {
    if (await canLaunchUrl(url)) {
      launchUrl(url);
    } else {
      showAlertDialog(context, "Error", 'Could not launch $url');
    }
  }

  Widget bookCard(Book book) {
    return InkWell(
      onTap: () {
        final String apiUrl = 'https://openlibrary.org${book.url}';
        Uri url = Uri.parse(apiUrl);
        _openURL(url);
      },
      child: Row(
        children: [
          SizedBox(
            height: 70,
            width: 70,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: Container(
                  color: Color.fromARGB(50, 233, 64, 87),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    size: 30,
                    color: Color.fromARGB(255, 233, 64, 87),
                  ),
                )),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.name,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(
                  (book.author_name.isNotEmpty && book.author_name[0] == input!)
                      ? "${book.author_name[0]}"
                      : "unkwnown",
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "year:${book.first_publish_year}",
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: StreamBuilder<List<Lesson>>(
          stream: selectedCategory == null
              ? readAllLessons()
              : readLessonsByCategory(selectedCategory!),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text("Something went wrong!");
            } else if (snapshot.hasData) {
              var lessons = snapshot.data!;
              List<String> lessonsTitle = [];
              for (var element in lessons) {
                lessonsTitle.add(element.title);
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.search,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          )),
                      AutocompleteSearchbarSearchPage(
                        lessonsTitle: lessonsTitle,
                        onTypedCallback: ((value) async {
                          List<Book> b = await _fetchData(value);
                          selectedLesson = value;
                          input = value;
                          if (mounted) {
                            setState(() {
                              bookView = b;
                            });
                          }
                        }),
                        onSelectedCallback: ((p0) {
                          setState(() {
                            selectedLesson = p0;
                          });
                        }),
                        onCleanCallback: () {
                          setState(() {
                            selectedLesson = null;
                            bookView = [];
                          });
                        },
                      ),
                    ],
                  ),
                  (isBusyBook)
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : Expanded(
                          child: ListView(
                            children: [
                              const SizedBox(height: 10),
                              //Title category
                              Text(AppLocalizations.of(context)!.categories,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                              //Category filter
                              SizedBox(
                                height: 180.0,
                                child: StreamBuilder<List<Category>>(
                                  stream: readCategory(),
                                  builder: ((context, snapshot) {
                                    if (snapshot.hasError) {
                                      return const Text(
                                          "Something went wrong!");
                                    } else if (snapshot.hasData) {
                                      final categories = snapshot.data!;
                                      return ListView(
                                        scrollDirection: Axis.horizontal,
                                        children: categories
                                            .map((category) => InkWell(
                                                  onTap: (() {
                                                    if (selectedCategory ==
                                                        category.name) {
                                                      setState(() {
                                                        selectedCategory = null;
                                                      });
                                                    } else {
                                                      setState(() {
                                                        selectedCategory =
                                                            category.name;
                                                      });
                                                      ;
                                                    }
                                                  }),
                                                  child: CategoryCard(
                                                    name: category.name,
                                                    url: category.imageURL,
                                                    selected:
                                                        selectedCategory ==
                                                            category.name,
                                                  ),
                                                ))
                                            .toList(),
                                      );
                                    } else {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                  }),
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Divider(
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 20),
                              (() {
                                //RECENT LESSONS
                                if (selectedCategory == null &&
                                    selectedLesson == null) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      //Recent
                                      Text(AppLocalizations.of(context)!.recent,
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 10),
                                      StreamBuilder<List<RecordLessonView>>(
                                          stream: readRecordLesson(),
                                          builder: ((context, snapshot) {
                                            if (snapshot.hasError) {
                                              return const Text(
                                                  "Something went wrong!");
                                            } else if (snapshot.hasData) {
                                              final recordLesson =
                                                  snapshot.data!;
                                              //Controllo se ci sono due record con lo stesso lesson id e li rimuovo
                                              List<RecordLessonView>
                                                  elementToRemove = [];
                                              int index = 0;
                                              for (var element
                                                  in recordLesson) {
                                                int i = 0;
                                                bool toRemove = false;
                                                while (i < index && !toRemove) {
                                                  if (recordLesson
                                                          .elementAt(i)
                                                          .lessonId ==
                                                      element.lessonId) {
                                                    toRemove = true;
                                                  }
                                                  i++;
                                                }
                                                if (toRemove) {
                                                  elementToRemove.add(element);
                                                }
                                                index++;
                                              }
                                              for (var element
                                                  in elementToRemove) {
                                                recordLesson.remove(element);
                                              }
                                              //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                                              if (recordLesson.length >= 1) {
                                                return StreamBuilder<
                                                        List<Lesson>>(
                                                    stream: readAllLessons(),
                                                    builder:
                                                        ((context, snapshot) {
                                                      if (snapshot.hasError) {
                                                        return const Text(
                                                            "Something went wrong!");
                                                      } else if (snapshot
                                                          .hasData) {
                                                        List<Lesson> lessons =
                                                            snapshot.data!;

                                                        // Estrae solo gli ID dalla listaId
                                                        final listaIdString =
                                                            recordLesson
                                                                .map((oggetto) =>
                                                                    oggetto
                                                                        .lessonId)
                                                                .toList();

                                                        // Filtra gli oggetti con ID presenti nella listaId
                                                        lessons.retainWhere(
                                                            (oggetto) =>
                                                                listaIdString
                                                                    .contains(
                                                                        oggetto
                                                                            .id));

                                                        // Ordina la lista degli oggetti in base all'ordine della listaId
                                                        lessons.sort((a, b) {
                                                          int indexA =
                                                              listaIdString
                                                                  .indexOf(
                                                                      a.id);
                                                          int indexB =
                                                              listaIdString
                                                                  .indexOf(
                                                                      b.id);
                                                          return indexA
                                                              .compareTo(
                                                                  indexB);
                                                        });

                                                        if (lessons.length >=
                                                            1) {
                                                          return GridView
                                                              .builder(
                                                            physics:
                                                                const NeverScrollableScrollPhysics(),
                                                            shrinkWrap: true,
                                                            gridDelegate:
                                                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                                              maxCrossAxisExtent:
                                                                  400,
                                                              childAspectRatio:
                                                                  35 / 9,
                                                              mainAxisSpacing:
                                                                  10.0,
                                                              crossAxisSpacing:
                                                                  10.0,
                                                            ),
                                                            itemCount:
                                                                lessons.length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              return LessonCard(
                                                                lesson: lessons[
                                                                    index],
                                                              );
                                                            },
                                                          );
                                                        } else {
                                                          return Container();
                                                        }
                                                      } else {
                                                        return const Center(
                                                            //child: CircularProgressIndicator(),
                                                            );
                                                      }
                                                    }));
                                              } else {
                                                return Column(
                                                  children: [
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    Center(
                                                      child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .noLessons),
                                                    ),
                                                  ],
                                                );
                                              }
                                            } else {
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            }
                                          }))
                                    ],
                                  );
                                }
                                //CATEGORY SELECTED
                                else if (selectedCategory != null &&
                                    selectedLesson == null) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(selectedCategory!,
                                          style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold)),
                                      StreamBuilder<List<Lesson>>(
                                          stream: readLessonsByCategory(
                                              selectedCategory!),
                                          builder: ((context, snapshot) {
                                            if (snapshot.hasError) {
                                              return const Text(
                                                  "Something went wrong!");
                                            } else if (snapshot.hasData) {
                                              if (snapshot.data!.length >= 1) {
                                                final lessons = snapshot.data!;
                                                return GridView.builder(
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  gridDelegate:
                                                      const SliverGridDelegateWithMaxCrossAxisExtent(
                                                    maxCrossAxisExtent: 400,
                                                    childAspectRatio: 35 / 9,
                                                    mainAxisSpacing: 10.0,
                                                    crossAxisSpacing: 10.0,
                                                  ),
                                                  itemCount: lessons.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return LessonCard(
                                                      lesson: lessons[index],
                                                    );
                                                  },
                                                );
                                              } else {
                                                return Column(
                                                  children: [
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    Center(
                                                      child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .noLessons),
                                                    ),
                                                  ],
                                                );
                                              }
                                            } else {
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            }
                                          })),
                                    ],
                                  );
                                }
                                //LESSON NAME SELECTED
                                else if (selectedCategory == null &&
                                    selectedLesson != null) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(selectedLesson!,
                                          style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold)),
                                      StreamBuilder<List<Lesson>>(
                                          stream: readLessonsByTitle(
                                              selectedLesson!),
                                          builder: ((context, snapshot) {
                                            if (snapshot.hasError) {
                                              return const Text(
                                                  "Something went wrong!");
                                            } else if (snapshot.hasData) {
                                              if (snapshot.data!.length >= 1) {
                                                final lessons = snapshot.data!;
                                                return GridView.builder(
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  gridDelegate:
                                                      const SliverGridDelegateWithMaxCrossAxisExtent(
                                                    maxCrossAxisExtent: 400,
                                                    childAspectRatio: 35 / 9,
                                                    mainAxisSpacing: 10.0,
                                                    crossAxisSpacing: 10.0,
                                                  ),
                                                  itemCount: lessons.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return LessonCard(
                                                      lesson: lessons[index],
                                                    );
                                                  },
                                                );
                                              } else {
                                                return Column(
                                                  children: [
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    Center(
                                                      child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .noLessons),
                                                    ),
                                                  ],
                                                );
                                              }
                                            } else {
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            }
                                          })),
                                    ],
                                  );
                                }
                                //LESSON NAME AND CATEGORY SELECTED
                                else if (selectedCategory != null &&
                                    selectedLesson != null) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(selectedLesson!,
                                          style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold)),
                                      StreamBuilder<List<Lesson>>(
                                          stream: readLessonsByCategoryTitle(
                                              selectedCategory!,
                                              selectedLesson!),
                                          builder: ((context, snapshot) {
                                            if (snapshot.hasError) {
                                              return const Text(
                                                  "Something went wrong!");
                                            } else if (snapshot.hasData) {
                                              if (snapshot.data!.length >= 1) {
                                                final lessons = snapshot.data!;
                                                return GridView.builder(
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  gridDelegate:
                                                      const SliverGridDelegateWithMaxCrossAxisExtent(
                                                    maxCrossAxisExtent: 400,
                                                    childAspectRatio: 35 / 9,
                                                    mainAxisSpacing: 10.0,
                                                    crossAxisSpacing: 10.0,
                                                  ),
                                                  itemCount: lessons.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return LessonCard(
                                                      lesson: lessons[index],
                                                    );
                                                  },
                                                );
                                              } else {
                                                return Column(
                                                  children: [
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    Center(
                                                      child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .noLessons),
                                                    ),
                                                  ],
                                                );
                                              }
                                            } else {
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            }
                                          })),
                                    ],
                                  );
                                }
                                return Container();
                              }()),
                              SizedBox(height: 10),
                              (bookView.length != 0)
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Divider(
                                          color: Colors.grey,
                                        ),
                                        const Text("Available books",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 10),
                                        GridView.builder(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          gridDelegate:
                                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                            maxCrossAxisExtent: 400,
                                            childAspectRatio: 35 / 9,
                                            mainAxisSpacing: 10.0,
                                            crossAxisSpacing: 10.0,
                                          ),
                                          itemCount: bookView.length,
                                          itemBuilder: (context, index) {
                                            return bookCard(bookView[index]);
                                          },
                                        ),
                                      ],
                                    )
                                  : const SizedBox()
                            ],
                          ),
                        ),
                  //Categories
                ],
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}

Route _createRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
