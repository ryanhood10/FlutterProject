import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  await dotenv.load();
  await Hive.initFlutter(); // Initialize Hive
  Hive.registerAdapter(
      SavedRecipeAdapter()); // Register the adapter for SavedRecipe model
  await Hive.openBox('recipes'); // Open the Hive box
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DishMate',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    MainPageContent(), // Main Page Content
    SearchPageContent(), // Search Page Content
    SavedRecipesPageContent(), // Saved Recipes Page Content
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    Hive.close(); // Close the Hive box when the app is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe App'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Main Page',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search Page',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Saved Recipes',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class MainPageContent extends StatefulWidget {
  @override
  _MainPageContentState createState() => _MainPageContentState();
}

class _MainPageContentState extends State<MainPageContent> {
  List<String> ingredientsList = [];
  List<String> dietsList = [];
  String cookTime = '';
  String ingredients = '';
  String diet = '';
  String responseText = '';

  void addIngredient(String ingredient) {
    setState(() {
      ingredientsList.add(ingredient);
      ingredients = ingredientsList.join(", ");
    });
  }

  void deleteIngredient(String ingredient) {
    setState(() {
      ingredientsList.remove(ingredient);
      ingredients = ingredientsList.join(", ");
    });
  }

  void toggleDiet(String diet) {
    setState(() {
      if (dietsList.contains(diet)) {
        dietsList.remove(diet);
      } else {
        dietsList.add(diet);
      }
      this.diet = dietsList.join(", ");
    });
  }

  generateRecipes() async {
    setState(() => responseText = 'Loading...');
    try {
      final apiKey = dotenv.env['token'];
      if (apiKey == null) {
        setState(() {
          responseText = 'API key not found.';
        });
        return;
      }

      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(
          {
            "model": 'gpt-3.5-turbo',
            "messages": [
              {
                "role": "user",
                "content":
                    "You are a personal chef's assistant. Create me a recipe that includes 1 or more of the following ingredients (you don't have to include every ingredient, but don't add any extra ones not listed): $ingredientsList. Make sure the recipe follows one or more of these diets (if no diet is listed after this, then don't worry about it): $dietsList . The dish must take $cookTime minutes or less to prepare and cook. Respond with 1. Title of Recipe 2. Cook Time 3. Ingredients 4. Instructions 5. Diets that it could be included in"
              }
            ],
            "max_tokens": 400,
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // print(responseData); // Add this line to check the parsed response
        final recipe = responseData['choices'][0]['message']['content'];
        setState(() {
          responseText = recipe;
        });
      } else {
        setState(() {
          responseText = 'Error occurred while generating recipe.';
        });
      }
    } catch (error) {
      print('Error in generateRecipes: $error');
      setState(() {
        responseText = 'Error occurred while generating recipe.';
      });
    }
  }

  void saveRecipe() async {
    final box = Hive.box('recipes'); // Access the Hive box

    final savedRecipe = SavedRecipe(
      title: 'Recipe Title',
      recipeText: responseText,
    );

    await box.add(savedRecipe); // Add the saved recipe to the box

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Recipe saved.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ingredients Section
          Text(
            'Ingredients',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          SizedBox(height: 8.0),
          TextField(
            onChanged: (value) => cookTime = value,
            decoration: InputDecoration(
              labelText: 'Add Ingredient',
            ),
            onSubmitted: addIngredient,
          ),
          ElevatedButton(
            onPressed: () => addIngredient(cookTime),
            child: Text('Add'),
          ),
          SizedBox(height: 16.0),
          Text(
            'Ingredients List:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: ingredientsList.length,
            itemBuilder: (context, index) {
              final ingredient = ingredientsList[index];
              return Row(
                children: [
                  Expanded(child: Text(ingredient)),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => deleteIngredient(ingredient),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 32.0),

          // Diets Section
          Text(
            'Diets',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          SizedBox(height: 8.0),
          CheckboxListTile(
            title: Text('Paleo'),
            value: dietsList.contains('Paleo'),
            onChanged: (value) => toggleDiet('Paleo'),
          ),
          CheckboxListTile(
            title: Text('Keto'),
            value: dietsList.contains('Keto'),
            onChanged: (value) => toggleDiet('Keto'),
          ),
          CheckboxListTile(
            title: Text('Gluten-Free'),
            value: dietsList.contains('Gluten-Free'),
            onChanged: (value) => toggleDiet('Gluten-Free'),
          ),
          CheckboxListTile(
            title: Text('Healthy'),
            value: dietsList.contains('Healthy'),
            onChanged: (value) => toggleDiet('Healthy'),
          ),
          SizedBox(height: 32.0),

          // Cook Time Section
          Text(
            'Cook Time',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          SizedBox(height: 8.0),
          TextField(
            onChanged: (value) {
              setState(() {
                cookTime = value;
              });
            },
            decoration: InputDecoration(
              labelText: 'Cook Time (minutes)',
            ),
          ),
          SizedBox(height: 32.0),

          // Generate Recipe Button
          ElevatedButton(
            onPressed: generateRecipes,
            child: Text('Generate Recipe'),
          ),
          SizedBox(height: 32.0),

          // Generated Recipe Text
          Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.grey[200],
            child: Column(
              children: [
                Text(
                  responseText,
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                ElevatedButton(
                  onPressed: saveRecipe,
                  child: Text('Save Recipe'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SearchPageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Search Page',
        style: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class SavedRecipesPageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final box = Hive.box('recipes'); // Access the Hive box

    return ListView.builder(
      itemCount: box.length,
      itemBuilder: (context, index) {
        final savedRecipe = box.getAt(index) as SavedRecipe;
        return ListTile(
          title: Text(savedRecipe.title),
          subtitle: Text(savedRecipe.recipeText),
        );
      },
    );
  }
}

class SavedRecipe {
  String title;
  String recipeText;

  SavedRecipe({
    required this.title,
    required this.recipeText,
  });
}

class SavedRecipeAdapter extends TypeAdapter<SavedRecipe> {
  @override
  int get typeId => 0;

  @override
  SavedRecipe read(BinaryReader reader) {
    return SavedRecipe(
      title: reader.read(),
      recipeText: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, SavedRecipe obj) {
    writer.write(obj.title);
    writer.write(obj.recipeText);
  }
}
