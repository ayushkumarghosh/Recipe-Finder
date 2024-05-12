import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recipe_finder/models/ingredient.dart';
import 'package:recipe_finder/services/ingredient_service.dart';

@GenerateMocks([SharedPreferences])
void main() {
  late IngredientService ingredientService;
  
  setUp(() {
    // Set up mock SharedPreferences without unused variable
    SharedPreferences.setMockInitialValues({});
    ingredientService = IngredientService();
  });
  
  group('IngredientService', () {
    test('getSuggestions should return matching ingredients', () async {
      // Arrange
      final query = 'tom';
      
      // Act
      final suggestions = await ingredientService.getSuggestions(query);
      
      // Assert
      expect(
        suggestions.any((ingredient) => 
          ingredient.name.toLowerCase().contains(query.toLowerCase())),
        true,
      );
    });
    
    test('getSuggestions should return empty list for empty query', () async {
      // Arrange
      final query = '';
      
      // Act
      final suggestions = await ingredientService.getSuggestions(query);
      
      // Assert
      expect(suggestions, isEmpty);
    });
    
    test('saveRecentIngredient should add ingredient to recent list', () async {
      // Arrange
      final ingredient = Ingredient(name: 'Test Ingredient');
      
      // Act
      await ingredientService.saveRecentIngredient(ingredient);
      final recentIngredients = await ingredientService.getRecentIngredients();
      
      // Assert
      expect(recentIngredients.isNotEmpty, true);
      expect(
        recentIngredients.any((item) => 
          item.name == ingredient.name),
        true,
      );
    });
    
    test('initializeCommonIngredients should populate default ingredients', () async {
      // Act
      await ingredientService.initializeCommonIngredients();
      final commonIngredients = await ingredientService.getCommonIngredients();
      
      // Assert
      expect(commonIngredients.length, greaterThan(0));
    });
  });
} 