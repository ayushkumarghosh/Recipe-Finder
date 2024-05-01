import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static const String baseUrl = 'https://api.spoonacular.com';
  
  // Get API key from environment variables
  static String get apiKey => dotenv.env['SPOONACULAR_API_KEY'] ?? '';
  
  // Method to search recipes by ingredients
  Future<Map<String, dynamic>> searchRecipesByIngredients(List<String> ingredients) async {
    try {
      final ingredientsString = ingredients.join(',');
      final response = await http.get(
        Uri.parse('$baseUrl/recipes/findByIngredients?ingredients=$ingredientsString&number=10&apiKey=$apiKey'),
      );
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {
          'success': false, 
          'error': 'Failed to load recipes. Status code: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Method to get recipe details by ID
  Future<Map<String, dynamic>> getRecipeDetails(int recipeId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/recipes/$recipeId/information?apiKey=$apiKey'),
      );
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {
          'success': false, 
          'error': 'Failed to load recipe details. Status code: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
} 