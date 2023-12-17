import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';




class AutocompleteSearchbar extends StatefulWidget {
  final Function(String) onSelected;
  const AutocompleteSearchbar({super.key, required this.onSelected});
  @override
  _AutocompleteSearchbarState createState() => _AutocompleteSearchbarState();
}

class _AutocompleteSearchbarState extends State<AutocompleteSearchbar> {
  bool isLoading = false;
  final user = FirebaseAuth.instance.currentUser!;

  List<String> autoCompleteData = [];
  late TextEditingController controller;

  CollectionReference _chatRef = FirebaseFirestore.instance.collection('chat');
  CollectionReference _userRef = FirebaseFirestore.instance.collection('users');

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    QuerySnapshot querySnapshot =
        await _chatRef.where('member', arrayContains: user.uid).get();

    final allData = querySnapshot.docs.map((doc) {
      if (doc.get("last_msg") != "") {
        return doc.get("member");
      }
    }).toList();
    List<String> members = [];
    allData.forEach((element) async {
      var m = element
          .toString()
          .substring(1, element.toString().length - 1)
          .split(',');

      if (m[0] == user.uid) {
        members.add(m[1].substring(1));
      } else {
        members.add(m[0]);
      }
    });
    members.forEach((element) async {
      querySnapshot = await _userRef.where('id', isEqualTo: element).get();
      if (querySnapshot.size > 0) {
        final allData1 = querySnapshot.docs
            .map((doc) => "${doc.get('firstname')} ${doc.get('lastname')}");
        autoCompleteData.add(allData1.first);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
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
            optionsViewBuilder:
                (context, Function(String) onSelected, options) {
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
                        size: 20,
                      )),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
