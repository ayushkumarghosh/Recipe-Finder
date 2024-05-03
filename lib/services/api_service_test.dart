import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../models/recipe.dart';
import '../models/recipe_detail.dart';

// Custom API service for testing that doesn't require .env file
class TestApiService extends ApiService {
  @override
  String get apiKey => 'test-api-key';
}

// Mock HTTP client for testing
class MockHttpClient extends http.BaseClient {
  final Map<String, Function(http.BaseRequest)> _responses = {};

  void mockResponse(String url, Function(http.BaseRequest) responseBuilder) {
    _responses[url] = responseBuilder;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final uri = request.url.toString();
    
    for (final pattern in _responses.keys) {
      if (uri.contains(pattern)) {
        final response = _responses[pattern]!(request);
        if (response is http.Response) {
          return http.StreamedResponse(
            Stream.value(response.bodyBytes),
            response.statusCode,
            headers: response.headers,
          );
        }
      }
    }
    
    // Default response for unmocked requests
    return http.StreamedResponse(
      Stream.value(utf8.encode('{"message": "Unmocked request"}')),
      404,
    );
  }
}

void main() {
  group('ApiService Tests', () {
    late TestApiService apiService;
    late MockHttpClient mockHttpClient;
    late http.Client originalClient;
    
    setUp(() async {
      // Create API service and mock HTTP client
      apiService = TestApiService();
      mockHttpClient = MockHttpClient();
      
      // Store original client and replace with mock
      originalClient = http.Client();
      // Override the default client with our mock
      http.Client.new = () => mockHttpClient;
    });
    
    tearDown(() {
      // Restore original client creation
      http.Client.new = () => http.Client();
    });
    
    test('testConnection returns true on successful response', () async {
      // Arrange
      mockHttpClient.mockResponse('/recipes/complexSearch', (request) {
        return http.Response('{"results": []}', 200);
      });
      
      // Act
      final result = await apiService.testConnection();
      
      // Assert
      expect(result, true);
    });
    
    test('searchRecipesByIngredients returns recipes when successful', () async {
      // Arrange
      mockHttpClient.mockResponse('/recipes/findByIngredients', (request) {
        final uri = request.url;
        expect(uri.path, contains('/recipes/findByIngredients'));
        expect(uri.queryParameters['ingredients'], 'chicken,pasta');
        expect(uri.queryParameters['number'], '2');
        
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
      
      // Act
      final recipes = await apiService.searchRecipesByIngredients(
        ['chicken', 'pasta'], 
        number: 2
      );
      
      // Assert
      expect(recipes.length, 1);
      expect(recipes[0].title, 'Chicken Pasta');
      expect(recipes[0].id, 123);
    });
    
    test('getRecipeDetails returns recipe details when successful', () async {
      // Arrange
      mockHttpClient.mockResponse('/recipes/123/information', (request) {
        final uri = request.url;
        expect(uri.path, contains('/recipes/123/information'));
        
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
      
      // Act
      final recipeDetail = await apiService.getRecipeDetails(123);
      
      // Assert
      expect(recipeDetail.id, 123);
      expect(recipeDetail.title, 'Chicken Pasta');
      expect(recipeDetail.readyInMinutes, 30);
      expect(recipeDetail.steps.length, 1);
      expect(recipeDetail.ingredients.length, 1);
    });
    
    test('searchRecipes returns recipes with complex filtering', () async {
      // Arrange
      mockHttpClient.mockResponse('/recipes/complexSearch', (request) {
        final uri = request.url;
        expect(uri.path, contains('/recipes/complexSearch'));
        expect(uri.queryParameters['query'], 'pasta');
        expect(uri.queryParameters['cuisine'], 'italian');
        expect(uri.queryParameters['diet'], 'vegetarian');
        
        return http.Response(
          jsonEncode({
            'results': [
              {
                'id': 456,
                'title': 'Vegetarian Pasta',
                'image': 'veg-pasta.jpg',
                'usedIngredientCount': 3,
                'missedIngredientCount': 2,
                'likes': 50
              }
            ],
            'totalResults': 1
          }),
          200,
        );
      });
      
      // Act
      final recipes = await apiService.searchRecipes(
        query: 'pasta',
        cuisine: ['italian'],
        diet: ['vegetarian'],
        maxReadyTime: 30
      );
      
      // Assert
      expect(recipes.length, 1);
      expect(recipes[0].title, 'Vegetarian Pasta');
      expect(recipes[0].id, 456);
    });
    
    test('API throws ApiException on 401 unauthorized response', () async {
      // Arrange
      mockHttpClient.mockResponse('/recipes/findByIngredients', (request) {
        return http.Response(
          jsonEncode({
            'code': 401,
            'message': 'Invalid API key'
          }),
          401,
        );
      });
      
      // Act & Assert
      expect(
        () => apiService.searchRecipesByIngredients(['chicken']),
        throwsA(isA<ApiException>()
          .having((e) => e.statusCode, 'statusCode', 401)
          .having((e) => e.message, 'message contains authentication', contains('Authentication')))
      );
    });
    
    test('API throws ApiException on rate limit exceeded', () async {
      // Arrange
      mockHttpClient.mockResponse('/recipes/complexSearch', (request) {
        return http.Response(
          jsonEncode({
            'code': 429,
            'message': 'You have exceeded your rate limit'
          }),
          429,
        );
      });
      
      // Act & Assert
      expect(
        () => apiService.searchRecipes(query: 'pasta'),
        throwsA(isA<ApiException>()
          .having((e) => e.statusCode, 'statusCode', 429)
          .having((e) => e.message, 'message contains rate limit', contains('rate limit')))
      );
    });
    
    test('API throws ApiException on malformed JSON response', () async {
      // Arrange
      mockHttpClient.mockResponse('/recipes/123/information', (request) {
        return http.Response(
          '{invalid json',
          200,
        );
      });
      
      // Act & Assert
      expect(
        () => apiService.getRecipeDetails(123),
        throwsA(isA<ApiException>()
          .having((e) => e.message, 'message contains parse', contains('parse')))
      );
    });
  });
} 