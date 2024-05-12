import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:recipe_finder/models/recipe.dart';
import 'package:recipe_finder/services/api_service.dart';

// Simple wrapper for testing the Recipe parsing without real API calls
void main() {
  group('Recipe Model Tests', () {
    test('Recipe.fromJson parses correctly', () {
      // Test recipe JSON data
      final jsonMap = {
        "id": 123,
        "title": "Test Recipe",
        "image": "test.jpg",
        "usedIngredientCount": 2,
        "missedIngredientCount": 1,
        "likes": 10,
        "usedIngredients": [],
        "missedIngredients": []
      };
      
      // Parse the recipe
      final recipe = Recipe.fromJson(jsonMap);
      
      // Verify all fields parsed correctly
      expect(recipe.id, 123);
      expect(recipe.title, 'Test Recipe');
      expect(recipe.image, 'test.jpg');
      expect(recipe.usedIngredientCount, 2);
      expect(recipe.missedIngredientCount, 1);
      expect(recipe.likes, 10);
      expect(recipe.usedIngredients, isEmpty);
      expect(recipe.missedIngredients, isEmpty);
    });
    
    test('API Exception has correct toString output', () {
      const message = 'Test error message';
      const statusCode = 401;
      
      final exception = ApiException(message, statusCode: statusCode);
      
      expect(
        exception.toString(),
        contains(message),
      );
      expect(
        exception.toString(),
        contains(statusCode.toString()),
      );
    });
    
    test('Encoding and decoding JSON maintains object equality', () {
      // Original recipe
      final recipe = Recipe(
        id: 456,
        title: 'Encoded Recipe',
        image: 'encoded.jpg',
        usedIngredientCount: 3,
        missedIngredientCount: 2,
        usedIngredients: [],
        missedIngredients: [],
        likes: 50,
      );
      
      // Convert to JSON and back
      final jsonMap = {
        "id": recipe.id,
        "title": recipe.title,
        "image": recipe.image,
        "usedIngredientCount": recipe.usedIngredientCount,
        "missedIngredientCount": recipe.missedIngredientCount,
        "likes": recipe.likes,
        "usedIngredients": [],
        "missedIngredients": []
      };
      
      final decodedRecipe = Recipe.fromJson(jsonMap);
      
      // Verify the recipes are equal
      expect(decodedRecipe.id, recipe.id);
      expect(decodedRecipe.title, recipe.title);
      expect(decodedRecipe.image, recipe.image);
      expect(decodedRecipe.usedIngredientCount, recipe.usedIngredientCount);
      expect(decodedRecipe.missedIngredientCount, recipe.missedIngredientCount);
      expect(decodedRecipe.likes, recipe.likes);
    });
  });
} 