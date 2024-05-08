import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ingredient.dart';

class IngredientService {
  static const String _recentIngredientsKey = 'recent_ingredients';
  static const String _commonIngredientsKey = 'common_ingredients';

  // Common ingredients for suggestions
  static final List<Ingredient> defaultCommonIngredients = [
    Ingredient(name: 'Chicken', category: 'Protein', isCommon: true),
    Ingredient(name: 'Beef', category: 'Protein', isCommon: true),
    Ingredient(name: 'Pork', category: 'Protein', isCommon: true),
    Ingredient(name: 'Salmon', category: 'Protein', isCommon: true),
    Ingredient(name: 'Tuna', category: 'Protein', isCommon: true),
    Ingredient(name: 'Eggs', category: 'Protein', isCommon: true),
    Ingredient(name: 'Rice', category: 'Grain', isCommon: true),
    Ingredient(name: 'Pasta', category: 'Grain', isCommon: true),
    Ingredient(name: 'Bread', category: 'Grain', isCommon: true),
    Ingredient(name: 'Tomato', category: 'Vegetable', isCommon: true),
    Ingredient(name: 'Onion', category: 'Vegetable', isCommon: true),
    Ingredient(name: 'Potato', category: 'Vegetable', isCommon: true),
    Ingredient(name: 'Carrot', category: 'Vegetable', isCommon: true),
    Ingredient(name: 'Broccoli', category: 'Vegetable', isCommon: true),
    Ingredient(name: 'Spinach', category: 'Vegetable', isCommon: true),
    Ingredient(name: 'Apple', category: 'Fruit', isCommon: true),
    Ingredient(name: 'Banana', category: 'Fruit', isCommon: true),
    Ingredient(name: 'Orange', category: 'Fruit', isCommon: true),
    Ingredient(name: 'Lemon', category: 'Fruit', isCommon: true),
    Ingredient(name: 'Milk', category: 'Dairy', isCommon: true),
    Ingredient(name: 'Cheese', category: 'Dairy', isCommon: true),
    Ingredient(name: 'Butter', category: 'Dairy', isCommon: true),
    Ingredient(name: 'Yogurt', category: 'Dairy', isCommon: true),
    Ingredient(name: 'Salt', category: 'Spice', isCommon: true),
    Ingredient(name: 'Pepper', category: 'Spice', isCommon: true),
    Ingredient(name: 'Garlic', category: 'Spice', isCommon: true),
    Ingredient(name: 'Olive Oil', category: 'Oil', isCommon: true),
  ];

  // Get recent ingredients from SharedPreferences
  Future<List<Ingredient>> getRecentIngredients() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_recentIngredientsKey) ?? [];
    
    return jsonList
        .map((jsonString) => Ingredient.fromJson(jsonDecode(jsonString)))
        .toList();
  }

  // Save an ingredient to recent list
  Future<void> saveRecentIngredient(Ingredient ingredient) async {
    final prefs = await SharedPreferences.getInstance();
    List<Ingredient> recentIngredients = await getRecentIngredients();
    
    // Remove if already exists to avoid duplicates
    recentIngredients.removeWhere((item) => item.name.toLowerCase() == ingredient.name.toLowerCase());
    
    // Add to beginning of list
    recentIngredients.insert(0, ingredient);
    
    // Limit to 20 recent ingredients
    if (recentIngredients.length > 20) {
      recentIngredients = recentIngredients.sublist(0, 20);
    }
    
    await prefs.setStringList(
      _recentIngredientsKey,
      recentIngredients.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }

  // Initialize common ingredients list if it doesn't exist
  Future<void> initializeCommonIngredients() async {
    final prefs = await SharedPreferences.getInstance();
    final exists = prefs.containsKey(_commonIngredientsKey);
    
    if (!exists) {
      await prefs.setStringList(
        _commonIngredientsKey,
        defaultCommonIngredients.map((item) => jsonEncode(item.toJson())).toList(),
      );
    }
  }

  // Get common ingredients from SharedPreferences
  Future<List<Ingredient>> getCommonIngredients() async {
    final prefs = await SharedPreferences.getInstance();
    await initializeCommonIngredients();
    
    final jsonList = prefs.getStringList(_commonIngredientsKey) ?? [];
    
    return jsonList
        .map((jsonString) => Ingredient.fromJson(jsonDecode(jsonString)))
        .toList();
  }

  // Get ingredient suggestions based on query
  Future<List<Ingredient>> getSuggestions(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }
    
    final commonIngredients = await getCommonIngredients();
    final recentIngredients = await getRecentIngredients();
    
    // Combine both lists, with recent taking priority
    final allIngredients = [...recentIngredients, ...commonIngredients];
    
    // Remove duplicates based on name
    final uniqueIngredients = <Ingredient>[];
    final uniqueNames = <String>{};
    
    for (final ingredient in allIngredients) {
      if (!uniqueNames.contains(ingredient.name.toLowerCase())) {
        uniqueNames.add(ingredient.name.toLowerCase());
        uniqueIngredients.add(ingredient);
      }
    }
    
    // Filter based on query
    final lowercaseQuery = query.toLowerCase();
    return uniqueIngredients
        .where((ingredient) => ingredient.name.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  // Clear all recent ingredients
  Future<void> clearRecentIngredients() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentIngredientsKey);
  }
} 