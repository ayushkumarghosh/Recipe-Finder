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

  ApiController({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService();

  // Getters
  RequestState get state => _state;
  String get errorMessage => _errorMessage;
  List<Recipe> get recipes => _recipes;
  RecipeDetail? get recipeDetail => _recipeDetail;
  bool get isConnectionAvailable => _isConnectionAvailable;

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

  // Search recipes by ingredients
  Future<void> searchRecipesByIngredients(List<String> ingredients, {
    int number = 10,
    bool limitLicense = true,
    int ranking = 1,
    bool ignorePantry = false,
  }) async {
    if (ingredients.isEmpty) {
      _state = RequestState.error;
      _errorMessage = 'Please provide at least one ingredient';
      notifyListeners();
      return;
    }

    _state = RequestState.loading;
    notifyListeners();

    try {
      _recipes = await _apiService.searchRecipesByIngredients(
        ingredients,
        number: number,
        limitLicense: limitLicense,
        ranking: ranking,
        ignorePantry: ignorePantry,
      );
      
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
      throw e;
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

  // Reset the controller state
  void reset() {
    _state = RequestState.initial;
    _errorMessage = '';
    _recipes = [];
    _recipeDetail = null;
    notifyListeners();
  }
} 