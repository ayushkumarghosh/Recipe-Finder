import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/recipe.dart';
import '../models/recipe_detail.dart';

class ApiService {
  final String baseUrl = 'https://api.spoonacular.com';
  late final String apiKey;

  ApiService() {
    apiKey = dotenv.env['SPOONACULAR_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('API key not found. Please check your .env file.');
    }
  }

  // Helper method to build URL with API key
  Uri _buildUrl(String endpoint, Map<String, dynamic> queryParams) {
    final params = {...queryParams, 'apiKey': apiKey};
    return Uri.parse('$baseUrl$endpoint').replace(queryParameters: params);
  }

  // Basic test connection to check if API is working
  Future<bool> testConnection() async {
    try {
      final response = await http.get(
        _buildUrl('/recipes/complexSearch', {'number': '1'}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Method to search recipes by ingredients
  Future<Map<String, dynamic>> searchRecipesByIngredients(
      List<String> ingredients, {int number = 10}) async {
    try {
      final String ingredientsStr = ingredients.join(',');
      final response = await http.get(
        _buildUrl('/recipes/findByIngredients', {
          'ingredients': ingredientsStr,
          'number': number.toString(),
          'ranking': '1', // 1 = maximize used ingredients, 2 = minimize missing ingredients
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<Recipe> recipes = data.map((json) => Recipe.fromJson(json)).toList();
        
        return {
          'success': true,
          'data': recipes,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load recipes: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error occurred: ${e.toString()}',
      };
    }
  }
  
  // Get detailed information about a specific recipe
  Future<Map<String, dynamic>> getRecipeDetails(int recipeId) async {
    try {
      final response = await http.get(
        _buildUrl('/recipes/$recipeId/information', {
          'includeNutrition': 'false',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final RecipeDetail recipeDetail = RecipeDetail.fromJson(data);
        
        return {
          'success': true,
          'data': recipeDetail,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load recipe details: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error occurred: ${e.toString()}',
      };
    }
  }
} 