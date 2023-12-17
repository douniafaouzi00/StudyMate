import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../models/category.dart';

class DropdownCategory extends StatefulWidget {
  final Function callback;
  final List<Category> categories;
  final String initCategory;
  const DropdownCategory({
    super.key,
    required this.callback,
    required this.categories,
    required this.initCategory,
  });

  @override
  State<DropdownCategory> createState() => _DropdownCategoryState();
}

class _DropdownCategoryState extends State<DropdownCategory> {
  String? dropdownValue;

  @override
  void initState() {
    super.initState();
    if (widget.initCategory != "") {
      setState(() {
        dropdownValue = widget.initCategory;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: DropdownButtonFormField<String>(
        key: Key('dropdownCategory'),
        value: dropdownValue,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return AppLocalizations.of(context)!.pleaseCategoryText;
          }
          return null;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.category,
          hintText: AppLocalizations.of(context)!.categoryFieldHint,
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
        ),
        onChanged: (String? value) {
          // This is called when the user selects an item.
          setState(() {
            dropdownValue = value!;
          });
          widget.callback(value);
        },
        items: widget.categories
            .map<DropdownMenuItem<String>>((Category category) {
          return DropdownMenuItem<String>(
            value: category.name,
            child: Text(category.name),
          );
        }).toList(),
      ),
    );
  }
}
