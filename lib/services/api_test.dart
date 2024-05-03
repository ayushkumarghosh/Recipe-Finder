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
        // Test recipe search by ingredients
        try {
          final recipes = await apiService.searchRecipesByIngredients(
            ['chicken', 'pasta', 'tomato'],
            number: 3,
          );
          
          debugPrint('Found ${recipes.length} recipes');
          
          if (recipes.isNotEmpty) {
            final firstRecipe = recipes.first;
            debugPrint('First recipe: ${firstRecipe.title}');
            
            // Test recipe details
            try {
              final recipeId = firstRecipe.id;
              final recipeDetails = await apiService.getRecipeDetails(recipeId);
              
              debugPrint('Recipe details loaded: ${recipeDetails.title}');
              debugPrint('Cooking time: ${recipeDetails.readyInMinutes} minutes');
              debugPrint('Servings: ${recipeDetails.servings}');
              debugPrint('Instructions: ${recipeDetails.steps.length} steps');
            } catch (e) {
              debugPrint('Recipe details error: $e');
            }
          }
        } catch (e) {
          debugPrint('Recipe search error: $e');
        }
        
        // Test complex search
        try {
          final complexResults = await apiService.searchRecipes(
            query: 'pasta',
            cuisine: ['italian'],
            diet: ['vegetarian'],
            number: 3,
            maxReadyTime: 30,
          );
          
          debugPrint('Complex search found ${complexResults.length} recipes');
          if (complexResults.isNotEmpty) {
            final firstResult = complexResults.first;
            debugPrint('First result: ${firstResult.title}');
          }
        } catch (e) {
          debugPrint('Complex search error: $e');
        }
      }
    } catch (e) {
      debugPrint('API Test Error: ${e.toString()}');
    }
  }
  
  static Future<void> testErrorHandling() async {
    debugPrint('Testing API error handling...');
    final apiService = ApiService();
    
    // Test invalid recipe ID
    try {
      await apiService.getRecipeDetails(999999999);
      debugPrint('Should have thrown an exception');
    } catch (e) {
      debugPrint('Expected error: $e');
    }
    
    // Test empty ingredients list
    try {
      await apiService.searchRecipesByIngredients([]);
      debugPrint('Should have thrown an exception');
    } catch (e) {
      debugPrint('Expected error: $e');
    }
  }
} 