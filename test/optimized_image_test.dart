import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:recipe_finder/widgets/optimized_image.dart';

void main() {
  group('OptimizedImage Widget Tests', () {
    testWidgets('OptimizedImage renders correctly with valid URL', 
        (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OptimizedImage(
              imageUrl: 'https://example.com/image.jpg',
              height: 200,
              width: 300,
            ),
          ),
        ),
      );
      
      // Verify CachedNetworkImage is used
      expect(find.byType(CachedNetworkImage), findsOneWidget);
      
      // Shimmer effect should be visible during loading
      expect(find.byType(Container), findsOneWidget);
    });
    
    testWidgets('OptimizedImage applies hero animation when tag is provided', 
        (WidgetTester tester) async {
      // Build the widget with a hero tag
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OptimizedImage(
              imageUrl: 'https://example.com/image.jpg',
              heroTag: 'test_hero_tag',
            ),
          ),
        ),
      );
      
      // Verify Hero widget is used
      expect(find.byType(Hero), findsOneWidget);
      
      // Verify the Hero tag is applied correctly
      final heroWidget = tester.widget<Hero>(find.byType(Hero));
      expect(heroWidget.tag, equals('test_hero_tag'));
    });
    
    testWidgets('OptimizedImage applies border radius when provided', 
        (WidgetTester tester) async {
      // Build the widget with a border radius
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedImage(
              imageUrl: 'https://example.com/image.jpg',
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
      );
      
      // Verify ClipRRect is used for border radius
      expect(find.byType(ClipRRect), findsOneWidget);
      
      // Verify the border radius is applied correctly
      final clipRRect = tester.widget<ClipRRect>(find.byType(ClipRRect));
      expect(clipRRect.borderRadius, equals(BorderRadius.circular(12.0)));
    });
    
    testWidgets('OptimizedImage uses provided custom loading widget', 
        (WidgetTester tester) async {
      // Custom loading widget
      const customLoadingWidget = CircularProgressIndicator();
      
      // Build the widget with custom loading widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OptimizedImage(
              imageUrl: 'https://example.com/image.jpg',
              loadingWidget: customLoadingWidget,
            ),
          ),
        ),
      );
      
      // Verify CachedNetworkImage is used
      expect(find.byType(CachedNetworkImage), findsOneWidget);
      
      // The custom loading widget should be in the widget tree
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
} 