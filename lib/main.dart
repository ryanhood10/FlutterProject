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
  bool isPaleoSelected = false;
  bool isKetoSelected = false;
  bool isGlutenFreeSelected = false;
  bool isHealthySelected = false;
  String cookTime = '';

  void addIngredient(String ingredient) {
    setState(() {
      ingredientsList.add(ingredient);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe App'),
      ),
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            // Ingredients Section
            Text('Ingredients'), // End of Text('Ingredients')
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
            SizedBox(height: 16.0),
            Text('Ingredients List:'), // End of Text('Ingredients List:')
            ListView.builder(
              shrinkWrap: true,
              itemCount: ingredientsList.length,
              itemBuilder: (context, index) {
                return Text(ingredientsList[index]);
              },
            ), // End of ListView.builder
            SizedBox(height: 16.0),

            // Diets Section
            Text('Diets'), // End of Text('Diets')
            CheckboxListTile(
              title: Text('Paleo'),
              value: isPaleoSelected,
              onChanged: (value) {
                setState(() {
                  isPaleoSelected = value!;
                });
              },
            ), // End of CheckboxListTile (Paleo)
            CheckboxListTile(
              title: Text('Keto'),
              value: isKetoSelected,
              onChanged: (value) {
                setState(() {
                  isKetoSelected = value!;
                });
              },
            ), // End of CheckboxListTile (Keto)
            CheckboxListTile(
              title: Text('Gluten-Free'),
              value: isGlutenFreeSelected,
              onChanged: (value) {
                setState(() {
                  isGlutenFreeSelected = value!;
                });
              },
            ), // End of CheckboxListTile (Gluten-Free)
            CheckboxListTile(
              title: Text('Healthy'),
              value: isHealthySelected,
              onChanged: (value) {
                setState(() {
                  isHealthySelected = value!;
                });
              },
            ), // End of CheckboxListTile (Healthy)
            SizedBox(height: 16.0),

            // Cook Time Section
            Text('Cook Time'), // End of Text('Cook Time')
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
          ],
        ),
      ),
    );
  }
}
