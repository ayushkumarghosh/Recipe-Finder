import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:recipe_finder/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end test', () {
    testWidgets('Verify Add Ingredients and Navigation Flow',
        (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Verify app starts with Recipe Finder title
      expect(find.text('Recipe Finder'), findsOneWidget);
      
      // Verify ingredient input field is present
      expect(find.byType(TextField), findsOneWidget);
      
      // Add an ingredient
      await tester.enterText(find.byType(TextField), 'chicken');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      
      // Verify the ingredient chip appears
      expect(find.text('chicken'), findsOneWidget);
      
      // Verify the Find Recipes button is enabled
      final buttonFinder = find.text('Find Recipes');
      expect(buttonFinder, findsOneWidget);
      
      final button = tester.widget<ElevatedButton>(
        find.ancestor(
          of: buttonFinder,
          matching: find.byType(ElevatedButton),
        ),
      );
      
      // Button should be enabled now that we have an ingredient
      expect(button.enabled, isTrue);
      
      // Test navigation to favorites screen
      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pumpAndSettle();
      
      // Should be on favorites screen
      expect(find.text('Favorites'), findsOneWidget);
      
      // Navigate back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      
      // Test navigation to history screen
      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();
      
      // Should be on history screen
      expect(find.text('Search History'), findsOneWidget);
      
      // Navigate back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      
      // Test removing the ingredient by tapping the chip's close icon
      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pumpAndSettle();
      
      // Ingredient should be removed
      expect(find.text('chicken'), findsNothing);
    });
  });
} 