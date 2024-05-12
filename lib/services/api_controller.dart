import 'package:flutter/material.dart';
import 'api_service.dart';
import '../models/recipe.dart';
import '../models/recipe_detail.dart';

enum RequestState { initial, loading, success, error }

class ApiController with ChangeNotifier {
  final ApiService _apiService;
  RequestState _state = RequestState.initial;
  String _errorMessage = '';
  List<Recipe> _recipes = [];
  RecipeDetail? _recipeDetail;
  bool _isConnectionAvailable = false;
  List<String> _currentIngredients = [];
  
  // Current filter and sort state
  String _sortOption = 'popularity';
  String _sortDirection = 'desc';
  List<String>? _cuisine;
  List<String>? _diet;
  List<String>? _intolerances;
  List<String>? _excludeIngredients;
  String? _mealType;
  int _maxReadyTime = 0;

  ApiController({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService();

  // Getters
  RequestState get state => _state;
  String get errorMessage => _errorMessage;
  List<Recipe> get recipes => _recipes;
  RecipeDetail? get recipeDetail => _recipeDetail;
  bool get isConnectionAvailable => _isConnectionAvailable;
  String get sortOption => _sortOption;
  String get sortDirection => _sortDirection;
  List<String>? get cuisine => _cuisine;
  List<String>? get diet => _diet;
  List<String>? get intolerances => _intolerances;
  List<String>? get excludeIngredients => _excludeIngredients;
  String? get mealType => _mealType;
  int get maxReadyTime => _maxReadyTime;

  // Check API connection
  Future<void> checkConnection() async {
    _state = RequestState.loading;
    notifyListeners();

    try {
      _isConnectionAvailable = await _apiService.testConnection();
      _state = RequestState.success;
    } catch (e) {
      _state = RequestState.error;
      _errorMessage = 'Failed to connect to API: ${e.toString()}';
      _isConnectionAvailable = false;
    }
    
    notifyListeners();
  }

  // Improved ranking algorithm for recipe search
  int _calculateImprovedRanking(String sortOption) {
    // 1 = maximize used ingredients, 2 = minimize missing ingredients
    switch (sortOption) {
      case 'max-used-ingredients':
        return 1;
      case 'min-missing-ingredients':
        return 2;
      default:
        return 1; // Default to maximize used ingredients
    }
  }

  // Search recipes by ingredients
  Future<void> searchRecipesByIngredients(List<String> ingredients, {
    int number = 10,
    bool limitLicense = true,
    bool ignorePantry = false,
  }) async {
    if (ingredients.isEmpty) {
      _state = RequestState.error;
      _errorMessage = 'Please provide at least one ingredient';
      notifyListeners();
      return;
    }

    _currentIngredients = List.from(ingredients);
    _state = RequestState.loading;
    notifyListeners();

    try {
      // Use the improved ranking algorithm
      final ranking = _calculateImprovedRanking(_sortOption);
      
      _recipes = await _apiService.searchRecipesByIngredients(
        ingredients,
        number: number,
        limitLicense: limitLicense,
        ranking: ranking,
        ignorePantry: ignorePantry,
      );
      
      // Apply additional sorting if needed (for cases the API doesn't handle)
      if (_sortOption == 'popularity' && _recipes.isNotEmpty) {
        _sortRecipesByPopularity();
      }
      
      _state = RequestState.success;
    } catch (e) {
      _state = RequestState.error;
      _errorMessage = e is ApiException 
          ? e.toString() 
          : 'An error occurred while searching for recipes';
      _recipes = [];
    }
    
    notifyListeners();
  }

  // Custom sorting method for recipes
  void _sortRecipesByPopularity() {
    _recipes.sort((a, b) {
      int result = 0;
      
      // First sort by likes
      result = b.likes.compareTo(a.likes);
      
      // If likes are the same, sort by used ingredient count
      if (result == 0) {
        result = b.usedIngredientCount.compareTo(a.usedIngredientCount);
      }
      
      // If used ingredient count is the same, sort by missed ingredient count
      if (result == 0) {
        result = a.missedIngredientCount.compareTo(b.missedIngredientCount);
      }
      
      // Apply sort direction
      return _sortDirection == 'desc' ? result : -result;
    });
  }

  // Get recipe by ID (for favorites functionality)
  Future<Recipe?> getRecipeById(int recipeId) async {
    try {
      for (final recipe in _recipes) {
        if (recipe.id == recipeId) {
          return recipe;
        }
      }
      
      // If not in current recipes list, fetch from API
      final recipeDetail = await _apiService.getRecipeDetails(recipeId);
      
      // Create a basic Recipe object from the recipe detail
      return Recipe(
        id: recipeDetail.id,
        title: recipeDetail.title,
        image: recipeDetail.image,
        usedIngredientCount: 0, // Not available from detail
        missedIngredientCount: 0, // Not available from detail
        usedIngredients: [], // Not available from detail
        missedIngredients: [], // Not available from detail
        likes: recipeDetail.aggregateLikes,
      );
    } catch (e) {
      return null;
    }
  }

  // Get recipe details
  Future<RecipeDetail> getRecipeDetails(int recipeId, {
    bool includeNutrition = false,
  }) async {
    _state = RequestState.loading;
    notifyListeners();

    try {
      _recipeDetail = await _apiService.getRecipeDetails(
        recipeId,
        includeNutrition: includeNutrition,
      );
      
      _state = RequestState.success;
      notifyListeners();
      return _recipeDetail!;
    } catch (e) {
      _state = RequestState.error;
      _errorMessage = e is ApiException 
          ? e.toString() 
          : 'Failed to load recipe details';
      _recipeDetail = null;
      notifyListeners();
      rethrow;
    }
  }

  // Search recipes with complex filtering
  Future<void> searchRecipes({
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
    _state = RequestState.loading;
    notifyListeners();

    try {
      _recipes = await _apiService.searchRecipes(
        query: query,
        cuisine: cuisine,
        diet: diet,
        intolerances: intolerances,
        includeIngredients: includeIngredients,
        excludeIngredients: excludeIngredients,
        type: type,
        maxReadyTime: maxReadyTime,
        includeInstructions: includeInstructions,
        number: number,
        offset: offset,
        sort: sort,
        sortDirection: sortDirection,
      );
      
      // Apply additional sorting if needed
      if (sort == 'popularity' && _recipes.isNotEmpty) {
        _sortRecipesByPopularity();
      }
      
      _state = RequestState.success;
    } catch (e) {
      _state = RequestState.error;
      _errorMessage = e is ApiException 
          ? e.toString() 
          : 'Failed to search recipes';
      _recipes = [];
    }
    
    notifyListeners();
  }
  
  // Apply filters and sorting
  Future<void> applyFiltersAndSort({
    List<String>? cuisine,
    List<String>? diet,
    List<String>? intolerances,
    List<String>? excludeIngredients,
    String? type,
    int maxReadyTime = 0,
    String sortOption = 'popularity',
    String sortDirection = 'desc',
  }) async {
    // Update the filter state
    _cuisine = cuisine;
    _diet = diet;
    _intolerances = intolerances;
    _excludeIngredients = excludeIngredients;
    _mealType = type;
    _maxReadyTime = maxReadyTime;
    _sortOption = sortOption;
    _sortDirection = sortDirection;
    
    // If we have ingredients, use the complex search API
    if (_currentIngredients.isNotEmpty) {
      return searchRecipes(
        includeIngredients: _currentIngredients,
        cuisine: _cuisine,
        diet: _diet,
        intolerances: _intolerances,
        excludeIngredients: _excludeIngredients,
        type: _mealType,
        maxReadyTime: _maxReadyTime,
        sort: _sortOption,
        sortDirection: _sortDirection,
      );
    }
    
    notifyListeners();
  }
  
  // Reset filters to default values
  void resetFilters() {
    _cuisine = null;
    _diet = null;
    _intolerances = null;
    _excludeIngredients = null;
    _mealType = null;
    _maxReadyTime = 0;
    _sortOption = 'popularity';
    _sortDirection = 'desc';
    
    notifyListeners();
  }

  // Reset the controller state
  void reset() {
    _state = RequestState.initial;
    _errorMessage = '';
    _recipes = [];
    _recipeDetail = null;
    _currentIngredients = [];
    resetFilters();
    notifyListeners();
  }
} 