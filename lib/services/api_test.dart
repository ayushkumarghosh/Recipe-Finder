import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'api_service.dart';

/// Utility class to test the API service
/// Not meant for production use
class ApiTest {
  static Future<void> testApiConnectivity() async {
    try {
      final apiService = ApiService();
      
      // Test basic connection
      final isConnected = await apiService.testConnection();
      debugPrint('API Connection Test: ${isConnected ? 'SUCCESS' : 'FAILED'}');
      
      if (isConnected) {
        // Test recipe search
        final searchResult = await apiService.searchRecipesByIngredients(
          ['chicken', 'pasta', 'tomato'],
          number: 3,
        );
        
        if (searchResult['success']) {
          final recipes = searchResult['data'];
          debugPrint('Found ${recipes.length} recipes');
          
          if (recipes.isNotEmpty) {
            final firstRecipe = recipes.first;
            debugPrint('First recipe: ${firstRecipe.title}');
            
            // Test recipe details
            final recipeId = firstRecipe.id;
            final detailsResult = await apiService.getRecipeDetails(recipeId);
            
            if (detailsResult['success']) {
              final recipeDetails = detailsResult['data'];
              debugPrint('Recipe details loaded: ${recipeDetails.title}');
              debugPrint('Cooking time: ${recipeDetails.readyInMinutes} minutes');
              debugPrint('Servings: ${recipeDetails.servings}');
              debugPrint('Instructions: ${recipeDetails.steps.length} steps');
            } else {
              debugPrint('Failed to load recipe details: ${detailsResult['message']}');
            }
          }
        } else {
          debugPrint('Search failed: ${searchResult['message']}');
        }
      }
    } catch (e) {
      debugPrint('API Test Error: ${e.toString()}');
    }
  }
} 