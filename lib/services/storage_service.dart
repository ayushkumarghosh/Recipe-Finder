import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';

class StorageService {
  static const String _favoritesKey = 'favorites';
  static const String _searchHistoryKey = 'search_history';
  
  // Favorites methods
  Future<List<Recipe>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesJson = prefs.getString(_favoritesKey);
    
    if (favoritesJson == null) {
      return [];
    }
    
    final List<dynamic> decoded = jsonDecode(favoritesJson);
    return decoded.map((item) => Recipe.fromJson(item)).toList();
  }
  
  Future<bool> addFavorite(Recipe recipe) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    
    // Check if recipe already exists in favorites
    if (favorites.any((fav) => fav.id == recipe.id)) {
      return false;
    }
    
    favorites.add(recipe);
    final encoded = jsonEncode(favorites.map((r) => _recipeToJson(r)).toList());
    return await prefs.setString(_favoritesKey, encoded);
  }
  
  Future<bool> removeFavorite(int recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    
    final newFavorites = favorites.where((recipe) => recipe.id != recipeId).toList();
    final encoded = jsonEncode(newFavorites.map((r) => _recipeToJson(r)).toList());
    return await prefs.setString(_favoritesKey, encoded);
  }
  
  Future<bool> isFavorite(int recipeId) async {
    final favorites = await getFavorites();
    return favorites.any((recipe) => recipe.id == recipeId);
  }
  
  // Search history methods
  Future<List<String>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_searchHistoryKey) ?? [];
  }
  
  Future<bool> addSearchQuery(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getSearchHistory();
    
    // Remove the query if it already exists (to move it to the top)
    history.removeWhere((item) => item == query);
    
    // Add the new query at the beginning
    history.insert(0, query);
    
    // Keep only the 10 most recent searches
    final limitedHistory = history.take(10).toList();
    
    return await prefs.setStringList(_searchHistoryKey, limitedHistory);
  }
  
  Future<bool> clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_searchHistoryKey);
  }
  
  // Helper method to convert Recipe to a JSON-compatible format
  Map<String, dynamic> _recipeToJson(Recipe recipe) {
    return {
      'id': recipe.id,
      'title': recipe.title,
      'image': recipe.image,
      'usedIngredientCount': recipe.usedIngredientCount,
      'missedIngredientCount': recipe.missedIngredientCount,
      'usedIngredients': recipe.usedIngredients.map((i) => {
        'id': i.id,
        'name': i.name,
        'image': i.image,
        'amount': i.amount,
        'unit': i.unit,
      }).toList(),
      'missedIngredients': recipe.missedIngredients.map((i) => {
        'id': i.id,
        'name': i.name,
        'image': i.image,
        'amount': i.amount,
        'unit': i.unit,
      }).toList(),
      'likes': recipe.likes,
    };
  }
} 