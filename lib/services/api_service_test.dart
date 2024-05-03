import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'api_service.dart';
import '../models/recipe.dart';
import '../models/recipe_detail.dart';

void main() {
  group('ApiService Tests', () {
    late ApiService apiService;
    
    setUp(() async {
      // Mock environment loading
      await dotenv.load(fileName: '.env');
      apiService = ApiService();
    });
    
    test('searchRecipesByIngredients returns recipes when successful', () async {
      // Arrange - Setup a mock client
      final mockClient = MockClient((request) async {
        // Verify the request URL contains the expected parameters
        final uri = request.url;
        expect(uri.path, '/recipes/findByIngredients');
        expect(uri.queryParameters['ingredients'], 'chicken,pasta');
        expect(uri.queryParameters['number'], '2');
        
        // Return a successful response with mock data
        return http.Response(
          jsonEncode([
            {
              'id': 123,
              'title': 'Chicken Pasta',
              'image': 'chicken-pasta.jpg',
              'usedIngredientCount': 2,
              'missedIngredientCount': 0,
              'usedIngredients': [],
              'missedIngredients': [],
              'likes': 100
            }
          ]),
          200,
        );
      });
      
      // Replace http client with mock
      http.Client originalClient = http.Client();
      http.Client = () => mockClient;
      
      // Act
      final recipes = await apiService.searchRecipesByIngredients(
        ['chicken', 'pasta'], 
        number: 2
      );
      
      // Assert
      expect(recipes.length, 1);
      expect(recipes[0].title, 'Chicken Pasta');
      expect(recipes[0].id, 123);
      
      // Restore original client
      http.Client = () => originalClient;
    });
    
    test('getRecipeDetails returns recipe details when successful', () async {
      // Arrange - Setup a mock client
      final mockClient = MockClient((request) async {
        // Verify the request URL contains the expected parameters
        final uri = request.url;
        expect(uri.path, '/recipes/123/information');
        
        // Return a successful response with mock data
        return http.Response(
          jsonEncode({
            'id': 123,
            'title': 'Chicken Pasta',
            'image': 'chicken-pasta.jpg',
            'readyInMinutes': 30,
            'servings': 4,
            'summary': 'A delicious chicken pasta recipe',
            'dishTypes': ['lunch', 'dinner'],
            'diets': ['gluten-free'],
            'analyzedInstructions': [
              {
                'steps': [
                  {
                    'number': 1,
                    'step': 'Cook pasta according to package instructions',
                    'ingredients': [],
                    'equipment': []
                  }
                ]
              }
            ],
            'extendedIngredients': [
              {
                'id': 1,
                'name': 'pasta',
                'original': '200g pasta',
                'amount': 200,
                'unit': 'g',
                'image': 'pasta.jpg'
              }
            ]
          }),
          200,
        );
      });
      
      // Replace http client with mock
      http.Client originalClient = http.Client();
      http.Client = () => mockClient;
      
      // Act
      final recipeDetail = await apiService.getRecipeDetails(123);
      
      // Assert
      expect(recipeDetail.id, 123);
      expect(recipeDetail.title, 'Chicken Pasta');
      expect(recipeDetail.readyInMinutes, 30);
      expect(recipeDetail.steps.length, 1);
      expect(recipeDetail.ingredients.length, 1);
      
      // Restore original client
      http.Client = () => originalClient;
    });
    
    test('API throws ApiException on error response', () async {
      // Arrange - Setup a mock client
      final mockClient = MockClient((request) async {
        // Return an error response
        return http.Response(
          jsonEncode({
            'message': 'API rate limit exceeded'
          }),
          429,
        );
      });
      
      // Replace http client with mock
      http.Client originalClient = http.Client();
      http.Client = () => mockClient;
      
      // Act & Assert
      expect(
        () => apiService.searchRecipesByIngredients(['chicken']),
        throwsA(isA<ApiException>()
          .having((e) => e.statusCode, 'statusCode', 429)
          .having((e) => e.message, 'message contains rate limit', contains('rate limit')))
      );
      
      // Restore original client
      http.Client = () => originalClient;
    });
  });
} 