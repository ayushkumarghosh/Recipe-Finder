import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import 'recipe_results_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _ingredients = [];
  final TextEditingController _ingredientController = TextEditingController();

  @override
  void dispose() {
    _ingredientController.dispose();
    super.dispose();
  }

  void _addIngredient() {
    final ingredient = _ingredientController.text.trim();
    if (ingredient.isNotEmpty && !_ingredients.contains(ingredient)) {
      setState(() {
        _ingredients.add(ingredient);
        _ingredientController.clear();
      });
    }
  }

  void _removeIngredient(String ingredient) {
    setState(() {
      _ingredients.remove(ingredient);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Finder'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            const Text(
              'Find recipes with your ingredients',
              style: AppTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Add ingredients you have and discover delicious recipes',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Ingredient input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ingredientController,
                    decoration: const InputDecoration(
                      labelText: 'Add an ingredient',
                      hintText: 'e.g., tomato, chicken, pasta',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addIngredient(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.add),
                  onPressed: _addIngredient,
                  tooltip: 'Add ingredient',
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Ingredients list
            if (_ingredients.isNotEmpty) ...[
              const Text(
                'Added ingredients:',
                style: AppTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _ingredients.map((ingredient) {
                  return Chip(
                    label: Text(ingredient),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => _removeIngredient(ingredient),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
            
            // Search button
            ElevatedButton.icon(
              onPressed: _ingredients.isEmpty ? null : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeResultsScreen(
                      ingredients: _ingredients,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.search),
              label: const Text('Find Recipes'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.food_bank,
                      size: 80,
                      color: AppTheme.primaryColor,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Add ingredients to get started',
                      style: TextStyle(fontSize: 16, color: AppTheme.textColorSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 