import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_finder/models/recipe.dart';
import 'package:recipe_finder/widgets/recipe_card.dart';

void main() {
  group('RecipeCard Widget Tests', () {
    testWidgets('RecipeCard displays recipe title and ingredients count correctly', 
        (WidgetTester tester) async {
      // Create a test recipe
      final recipe = Recipe(
        id: 1,
        title: 'Test Recipe',
        image: 'https://example.com/image.jpg',
        usedIngredientCount: 3,
        missedIngredientCount: 2,
        usedIngredients: [],
        missedIngredients: [],
        likes: 10,
      );
      
      bool onTapCalled = false;
      
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeCard(
              recipe: recipe,
              onTap: () {
                onTapCalled = true;
              },
            ),
          ),
        ),
      );
      
      // Allow cached image widget to load
      await tester.pump(const Duration(milliseconds: 300));
      
      // Verify the title is displayed
      expect(find.text('Test Recipe'), findsOneWidget);
      
      // Verify ingredient counts are displayed
      expect(find.text('3 used'), findsOneWidget);
      expect(find.text('2 missing'), findsOneWidget);
      
      // Verify likes count is displayed
      expect(find.text('10 likes • 5 ingredients'), findsOneWidget);
      
      // Test tap functionality
      await tester.tap(find.byType(InkWell));
      expect(onTapCalled, isTrue);
    });
    
    testWidgets('RecipeCard handles recipes with no likes correctly', 
        (WidgetTester tester) async {
      // Create a test recipe with no likes
      final recipe = Recipe(
        id: 2,
        title: 'No Likes Recipe',
        image: 'https://example.com/image.jpg',
        usedIngredientCount: 2,
        missedIngredientCount: 1,
        usedIngredients: [],
        missedIngredients: [],
        likes: 0,
      );
      
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeCard(
              recipe: recipe,
              onTap: () {},
            ),
          ),
        ),
      );
      
      // Allow cached image widget to load
      await tester.pump(const Duration(milliseconds: 300));
      
      // Verify the title is displayed
      expect(find.text('No Likes Recipe'), findsOneWidget);
      
      // Verify only ingredients count is displayed (not likes)
      expect(find.text('3 ingredients'), findsOneWidget);
    });
  });
} 