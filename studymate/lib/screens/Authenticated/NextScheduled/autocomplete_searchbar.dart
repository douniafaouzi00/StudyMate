import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AutocompleteSearchbar extends StatefulWidget {
  final Function(String) onSelected;
  final bool isTutoring;
  const AutocompleteSearchbar(
      {super.key, required this.onSelected, required this.isTutoring});
  @override
  _AutocompleteSearchbarState createState() => _AutocompleteSearchbarState();
}

class _AutocompleteSearchbarState extends State<AutocompleteSearchbar> {
  bool isLoading = false;
  final user = FirebaseAuth.instance.currentUser!;

  List<String> autoCompleteData = [];
  late TextEditingController controller;
  final CollectionReference _scheduleRef =
      FirebaseFirestore.instance.collection('scheduled');

  @override
  void initState() {
    super.initState();

    widget.isTutoring ? getDataTutor() : getDataLesson();
  }

  Future<void> getDataTutor() async {
    autoCompleteData = [];
    QuerySnapshot querySnapshot = await _scheduleRef
        .where("tutorId", isEqualTo: user.uid)
        .where('accepted', isEqualTo: true)
        .where('date',
            isGreaterThan: Timestamp.fromDate(DateTime.utc(DateTime.now().year,
                    DateTime.now().month, DateTime.now().day)
                .subtract(const Duration(days: 1))))
        .orderBy('date', descending: true)
        .get();
    //var allData =
    querySnapshot.docs.map((doc) {
      autoCompleteData.add(doc.get("title"));
    }).toList();
    print(autoCompleteData);
  }

  Future<void> getDataLesson() async {
    autoCompleteData = [];
    QuerySnapshot querySnapshot = await _scheduleRef
        .where("studentId", isEqualTo: user.uid)
        .where('accepted', isEqualTo: true)
        .where('date',
            isGreaterThan: Timestamp.fromDate(DateTime.utc(DateTime.now().year,
                    DateTime.now().month, DateTime.now().day)
                .subtract(const Duration(days: 1))))
        .orderBy('date', descending: true)
        .get();
    //var allData =
    querySnapshot.docs.map((doc) {
      autoCompleteData.add(doc.get("title"));
    }).toList();
    print(autoCompleteData);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Autocomplete(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            } else {
              return autoCompleteData.where((word) => word
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase()));
            }
          },
          optionsViewBuilder: (context, Function(String) onSelected, options) {
            return Material(
              elevation: 4,
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    // title: Text(option.toString()),
                    title: SubstringHighlight(
                      text: option.toString(),
                      term: controller.text,
                      textStyleHighlight:
                          TextStyle(fontWeight: FontWeight.w700),
                    ),
                    //subtitle: Text("This is subtitle"),
                    onTap: () {
                      onSelected(option.toString());
                    },
                  );
                },
                separatorBuilder: (context, index) => Divider(),
                itemCount: options.length,
              ),
            );
          },
          onSelected: (selectedString) {
            setState(() => widget.onSelected(selectedString));
          },
          fieldViewBuilder:
              (context, controller, focusNode, onEditingComplete) {
            this.controller = controller;
            return TextField(
              controller: controller,
              focusNode: focusNode,
              onEditingComplete: onEditingComplete,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                hintText: AppLocalizations.of(context)!.search,
                suffixIcon: IconButton(
                    onPressed: () {
                      controller.clear();
                      widget.onSelected("");
                    },
                    icon: const Icon(
                      Icons.delete,
                      size: 15,
                    )),
              ),
            );
          },
        )
      ],
    );
  }
}
