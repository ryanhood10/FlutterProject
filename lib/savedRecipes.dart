import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SavedRecipe {
  final String title;
  final String responseText;

  SavedRecipe({required this.title, required this.responseText});
}

class SavedRecipesPageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final box = Hive.box('recipes'); // Access the Hive box

    return WatchBoxBuilder(
      box: box,
      builder: (context, box) {
        return ListView.builder(
          itemCount: box.length,
          itemBuilder: (context, index) {
            final recipe = box.getAt(index) as SavedRecipe;
            return ListTile(
              title: Text(recipe.title),
              subtitle: Text(recipe.responseText),
            );
          },
        );
      },
    );
  }
}
