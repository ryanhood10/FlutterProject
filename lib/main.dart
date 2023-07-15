import 'package:flutter/material.dart';

void main() {
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
  String recipeText = '';

  void addIngredient(String ingredient) {
    setState(() {
      ingredientsList.add(ingredient);
    });
  }

  void deleteIngredient(String ingredient) {
    setState(() {
      ingredientsList.remove(ingredient);
    });
  }

  void toggleDiet(String diet) {
    setState(() {
      if (dietsList.contains(diet)) {
        dietsList.remove(diet);
      } else {
        dietsList.add(diet);
      }
    });
  }

  void generateRecipes() {
    // TODO: Implement API call to generate recipes
    // Simulating API call delay with a Future.delayed
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        // Replace this with the actual API response
        recipeText = 'This is the generated recipe.';
      });
    });
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
              'Ingredients', // End of Text('Ingredients')
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ), // End of Text
            SizedBox(height: 8.0), // End of SizedBox
            TextField(
              onChanged: (value) => cookTime = value,
              decoration: InputDecoration(
                labelText: 'Add Ingredient',
              ),
              onSubmitted: addIngredient,
            ), // End of TextField
            ElevatedButton(
              onPressed: () => addIngredient(cookTime),
              child: Text('Add'),
            ), // End of ElevatedButton
            SizedBox(height: 16.0), // End of SizedBox
            Text(
              'Ingredients List:', // End of Text('Ingredients List:')
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ), // End of Text
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
            ), // End of ListView.builder
            SizedBox(height: 32.0), // End of SizedBox

            // Diets Section
            Text(
              'Diets', // End of Text('Diets')
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ), // End of Text
            SizedBox(height: 8.0), // End of SizedBox
            CheckboxListTile(
              title: Text('Paleo'),
              value: dietsList.contains('Paleo'),
              onChanged: (value) => toggleDiet('Paleo'),
            ), // End of CheckboxListTile (Paleo)
            CheckboxListTile(
              title: Text('Keto'),
              value: dietsList.contains('Keto'),
              onChanged: (value) => toggleDiet('Keto'),
            ), // End of CheckboxListTile (Keto)
            CheckboxListTile(
              title: Text('Gluten-Free'),
              value: dietsList.contains('Gluten-Free'),
              onChanged: (value) => toggleDiet('Gluten-Free'),
            ), // End of CheckboxListTile (Gluten-Free)
            CheckboxListTile(
              title: Text('Healthy'),
              value: dietsList.contains('Healthy'),
              onChanged: (value) => toggleDiet('Healthy'),
            ), // End of CheckboxListTile (Healthy)
            SizedBox(height: 32.0), // End of SizedBox

            // Cook Time Section
            Text(
              'Cook Time', // End of Text('Cook Time')
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ), // End of Text
            SizedBox(height: 8.0), // End of SizedBox
            TextField(
              onChanged: (value) {
                setState(() {
                  cookTime = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Cook Time (minutes)',
              ),
            ), // End of TextField
            SizedBox(height: 32.0), // End of SizedBox

            // Generate Recipe Button
            ElevatedButton(
              onPressed: generateRecipes,
              child: Text('Generate Recipe'),
            ), // End of ElevatedButton
            SizedBox(height: 32.0), // End of SizedBox

            // Generated Recipe Text
            Container(
              padding: EdgeInsets.all(16.0),
              color: Colors.grey[200],
              child: Text(
                recipeText, // End of Text(recipeText)
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ), // End of Container
          ],
        ),
      ),
    );
  }
}
