import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  await dotenv.load();
  print('Environment variables loaded: ${dotenv.env['token']}');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe App',
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
              {"role": "user", "content": "hello! how are you?"}
            ],
            "max_tokens": 400,
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData); // Add this line to check the parsed response
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe App'),
      ),
      body: SingleChildScrollView(
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
              child: Text(
                responseText,
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
