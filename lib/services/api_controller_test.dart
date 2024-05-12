import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'api_controller.dart';
import '../models/recipe.dart';
import '../models/recipe_detail.dart';

// Create a simple mock class manually
class MockApiService implements ApiService {
  bool testConnectionResult = true;
  Exception? testConnectionException;
  
  List<Recipe> searchRecipesResult = [];
  Exception? searchRecipesException;
  
  RecipeDetail? recipeDetailResult;
  Exception? recipeDetailException;
  
  @override
  String get apiKey => 'mock-api-key';
  
  @override
  set apiKey(String value) {}
  
  @override
  String get baseUrl => 'https://mock.api.com';
  
  @override
  Future<bool> testConnection() async {
    if (testConnectionException != null) {
      throw testConnectionException!;
    }
    return testConnectionResult;
  }
  
  @override
  void clearCache() {
    // No-op for mock
  }
  
  @override
  Future<List<Recipe>> searchRecipesByIngredients(
    List<String> ingredients, {
    int number = 10,
    bool limitLicense = true,
    int ranking = 1,
    bool ignorePantry = false,
  }) async {
    if (searchRecipesException != null) {
      throw searchRecipesException!;
    }
    return searchRecipesResult;
  }
  
  @override
  Future<RecipeDetail> getRecipeDetails(
    int recipeId, {
    bool includeNutrition = false,
  }) async {
    if (recipeDetailException != null) {
      throw recipeDetailException!;
    }
    if (recipeDetailResult == null) {
      throw ApiException('No recipe detail result configured');
    }
    return recipeDetailResult!;
  }
  
  @override
  Future<List<Recipe>> searchRecipes({
    String? query,
    List<String>? cuisine,
    List<String>? diet,
    List<String>? intolerances,
    List<String>? includeIngredients,
    List<String>? excludeIngredients,
    String? type,
    int maxReadyTime = 0,
    bool includeInstructions = false,
    int number = 10,
    int offset = 0,
    String sort = 'popularity',
    String sortDirection = 'desc',
  }) async {
    if (searchRecipesException != null) {
      throw searchRecipesException!;
    }
    return searchRecipesResult;
  }
  
  // Not needed for these tests
  @override
  Uri _buildUrl(String endpoint, Map<String, dynamic> queryParams) {
    return Uri.parse('$baseUrl$endpoint');
  }
  
  @override
  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    return {'success': true, 'data': {}};
  }
}

void main() {
  group('ApiController Tests', () {
    late MockApiService mockApiService;
    late ApiController apiController;

    setUp(() {
      mockApiService = MockApiService();
      apiController = ApiController(apiService: mockApiService);
    });

    test('initial state is correct', () {
      expect(apiController.state, RequestState.initial);
      expect(apiController.errorMessage, '');
      expect(apiController.recipes, isEmpty);
      expect(apiController.recipeDetail, isNull);
      expect(apiController.isConnectionAvailable, false);
    });

    test('checkConnection updates state correctly on success', () async {
      // Arrange
      mockApiService.testConnectionResult = true;

      // Act
      await apiController.checkConnection();

      // Assert
      expect(apiController.state, RequestState.success);
      expect(apiController.isConnectionAvailable, true);
    });

    test('checkConnection updates state correctly on failure', () async {
      // Arrange
      mockApiService.testConnectionException = Exception('Connection failed');

      // Act
      await apiController.checkConnection();

      // Assert
      expect(apiController.state, RequestState.error);
      expect(apiController.isConnectionAvailable, false);
      expect(apiController.errorMessage, contains('Connection failed'));
    });

    test('searchRecipesByIngredients updates state correctly on success', () async {
      // Arrange
      mockApiService.searchRecipesResult = [
        Recipe(
          id: 1,
          title: 'Test Recipe',
          image: 'test.jpg',
          usedIngredientCount: 1,
          missedIngredientCount: 0,
          usedIngredients: [],
          missedIngredients: [],
          likes: 10,
        )
      ];

      // Act
      await apiController.searchRecipesByIngredients(['chicken']);

      // Assert
      expect(apiController.state, RequestState.success);
      expect(apiController.recipes, equals(mockApiService.searchRecipesResult));
      expect(apiController.recipes.length, 1);
      expect(apiController.recipes.first.title, 'Test Recipe');
    });

    test('searchRecipesByIngredients updates state correctly on failure', () async {
      // Arrange
      mockApiService.searchRecipesException = ApiException('Search failed');

      // Act
      await apiController.searchRecipesByIngredients(['chicken']);

      // Assert
      expect(apiController.state, RequestState.error);
      expect(apiController.recipes, isEmpty);
      expect(apiController.errorMessage, contains('Search failed'));
    });

    test('getRecipeDetails updates state correctly on success', () async {
      // Arrange
      mockApiService.recipeDetailResult = RecipeDetail(
        id: 1,
        title: 'Test Recipe Detail',
        image: 'test.jpg',
        readyInMinutes: 30,
        servings: 4,
        healthScore: 80,
        summary: 'A test recipe',
        ingredients: [],
        steps: [],
        vegetarian: true,
        vegan: false,
        glutenFree: true,
        dairyFree: true,
        sustainable: true,
        aggregateLikes: 10,
      );

      // Act
      await apiController.getRecipeDetails(1);

      // Assert
      expect(apiController.state, RequestState.success);
      expect(apiController.recipeDetail, equals(mockApiService.recipeDetailResult));
      expect(apiController.recipeDetail?.title, 'Test Recipe Detail');
    });

    test('getRecipeDetails updates state correctly on failure', () async {
      // Arrange
      mockApiService.recipeDetailException = ApiException('Failed to get recipe details');

      // Act
      await apiController.getRecipeDetails(1);

      // Assert
      expect(apiController.state, RequestState.error);
      expect(apiController.recipeDetail, isNull);
      expect(apiController.errorMessage, contains('Failed to get recipe details'));
    });

    test('reset clears all state', () async {
      // Arrange - Set some initial state
      mockApiService.searchRecipesResult = [
        Recipe(
          id: 1,
          title: 'Test Recipe',
          image: 'test.jpg',
          usedIngredientCount: 1,
          missedIngredientCount: 0,
          usedIngredients: [],
          missedIngredients: [],
          likes: 10,
        )
      ];
      
      await apiController.searchRecipesByIngredients(['chicken']);
      expect(apiController.state, RequestState.success);
      expect(apiController.recipes.isNotEmpty, true);

      // Act
      apiController.reset();

      // Assert
      expect(apiController.state, RequestState.initial);
      expect(apiController.errorMessage, '');
      expect(apiController.recipes, isEmpty);
      expect(apiController.recipeDetail, isNull);
    });
  });
} 