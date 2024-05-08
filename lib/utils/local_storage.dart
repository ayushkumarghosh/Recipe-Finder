import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// A utility class for handling local storage operations.
class LocalStorage {
  static const String _ingredientsKey = 'saved_ingredients';
  static const String _historyKey = 'search_history';

  /// Save a list of ingredients to persistent storage.
  static Future<bool> saveIngredients(List<String> ingredients) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setStringList(_ingredientsKey, ingredients);
  }

  /// Retrieve saved ingredients from persistent storage.
  static Future<List<String>> getIngredients() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_ingredientsKey) ?? [];
  }

  /// Add a search query to search history.
  static Future<bool> addToSearchHistory(List<String> ingredients) async {
    if (ingredients.isEmpty) return false;

    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_historyKey) ?? [];
    
    // Encode ingredients list to JSON string
    final searchEntry = jsonEncode({
      'ingredients': ingredients,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    
    // Add to beginning of list (most recent first)
    history.insert(0, searchEntry);
    
    // Limit history to 10 entries
    if (history.length > 10) {
      history = history.sublist(0, 10);
    }
    
    return prefs.setStringList(_historyKey, history);
  }
  
  /// Get search history entries.
  static Future<List<Map<String, dynamic>>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];
    
    return history.map((entry) {
      final Map<String, dynamic> decoded = jsonDecode(entry);
      return {
        'ingredients': List<String>.from(decoded['ingredients']),
        'timestamp': decoded['timestamp'],
      };
    }).toList();
  }
  
  /// Clear search history.
  static Future<bool> clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(_historyKey);
  }
} 