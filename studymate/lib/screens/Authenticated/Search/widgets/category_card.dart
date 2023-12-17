import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../service/storage_service.dart';

class CategoryCard extends StatelessWidget {
  final String name;
  final String url;
  final bool selected;
  const CategoryCard(
      {super.key,
      required this.name,
      required this.url,
      required this.selected});

  @override
  Widget build(BuildContext context) {
    final Storage storage = Storage();

    return Center(
      child: Column(
        children: [
          Card(
            elevation: selected ? 10 : 0,
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: SizedBox(
              height: 150,
              width: 100,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: FutureBuilder(
                    future: storage.downloadURL(url),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text("Something went wrong!");
                      } else if (snapshot.hasData) {
                        return Image(
                          fit: BoxFit.cover,
                          image: NetworkImage(snapshot.data!),
                        );
                      } else {
                        return Container();
                      }
                    }),
              ),
            ),
          ),
          Text(name,
              style: TextStyle(
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal))
        ],
      ),
    );
  }
}
