import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/recipe.dart';
import '../models/recipe_detail.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message${statusCode != null ? ' (Status code: $statusCode)' : ''}';
}

class ApiService {
  final String baseUrl = 'https://api.spoonacular.com';
  late final String apiKey;
  
  // Caching layer for API responses
  final Map<String, dynamic> _cache = {};
  // Cache TTL in seconds
  final int _cacheTtl = 300; // 5 minutes
  // Cache timestamps for expiration
  final Map<String, DateTime> _cacheTimestamps = {};

  ApiService() {
    apiKey = dotenv.env['SPOONACULAR_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw ApiException('API key not found. Please check your .env file.');
    }
  }

  // Helper method to build URL with API key
  Uri _buildUrl(String endpoint, Map<String, dynamic> queryParams) {
    final params = {...queryParams, 'apiKey': apiKey};
    return Uri.parse('$baseUrl$endpoint').replace(queryParameters: params);
  }

  // Helper method to handle HTTP responses and standardize error handling
  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (response.statusCode == 200) {
      try {
        final dynamic data = json.decode(response.body);
        return {'success': true, 'data': data};
      } catch (e) {
        throw ApiException('Failed to parse response: ${e.toString()}');
      }
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw ApiException('Authentication error. Please check your API key.', statusCode: response.statusCode);
    } else if (response.statusCode == 429) {
      throw ApiException('Rate limit exceeded. Please try again later.', statusCode: response.statusCode);
    } else {
      String errorMessage = 'API request failed';
      try {
        final errorData = json.decode(response.body);
        errorMessage = errorData['message'] ?? 'Unknown error';
      } catch (e) {
        // If we can't parse the error, use the status code
        errorMessage = 'Error: HTTP ${response.statusCode}';
      }
      throw ApiException(errorMessage, statusCode: response.statusCode);
    }
  }
  
  // Cache management methods
  String _generateCacheKey(String endpoint, Map<String, dynamic> params) {
    final sortedParams = Map.fromEntries(params.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
    return '$endpoint:${json.encode(sortedParams)}';
  }
  
  dynamic _getCachedData(String cacheKey) {
    if (!_cache.containsKey(cacheKey)) return null;
    
    // Check if cache is expired
    final timestamp = _cacheTimestamps[cacheKey];
    if (timestamp == null) return null;
    
    final now = DateTime.now();
    final expiration = timestamp.add(Duration(seconds: _cacheTtl));
    
    if (now.isAfter(expiration)) {
      // Cache expired, remove it
      _cache.remove(cacheKey);
      _cacheTimestamps.remove(cacheKey);
      return null;
    }
    
    return _cache[cacheKey];
  }
  
  void _cacheData(String cacheKey, dynamic data) {
    _cache[cacheKey] = data;
    _cacheTimestamps[cacheKey] = DateTime.now();
  }
  
  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  // Basic test connection to check if API is working
  Future<bool> testConnection() async {
    try {
      final response = await http.get(
        _buildUrl('/recipes/complexSearch', {'number': '1'}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Method to search recipes by ingredients with caching
  Future<List<Recipe>> searchRecipesByIngredients(
      List<String> ingredients, {
      int number = 10,
      bool limitLicense = true,
      int ranking = 1,
      bool ignorePantry = false,
    }) async {
    try {
      final String ingredientsStr = ingredients.join(',');
      
      // Build cache key and check cache
      final params = {
        'ingredients': ingredientsStr,
        'number': number.toString(),
        'ranking': ranking.toString(),
        'ignorePantry': ignorePantry.toString(),
        'limitLicense': limitLicense.toString(),
      };
      
      final cacheKey = _generateCacheKey('/recipes/findByIngredients', params);
      final cachedData = _getCachedData(cacheKey);
      
      if (cachedData != null) {
        return (cachedData as List).map((json) => Recipe.fromJson(json)).toList();
      }
      
      final response = await http.get(_buildUrl('/recipes/findByIngredients', params));
      
      final result = await _handleResponse(response);
      final List<dynamic> data = result['data'];
      
      // Cache the result
      _cacheData(cacheKey, data);
      
      return data.map((json) => Recipe.fromJson(json)).toList();
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to search recipes: ${e.toString()}');
    }
  }
  
  // Get detailed information about a specific recipe with caching
  Future<RecipeDetail> getRecipeDetails(
    int recipeId, {
    bool includeNutrition = false,
  }) async {
    try {
      // Build cache key and check cache
      final params = {
        'includeNutrition': includeNutrition.toString(),
      };
      
      final cacheKey = _generateCacheKey('/recipes/$recipeId/information', params);
      final cachedData = _getCachedData(cacheKey);
      
      if (cachedData != null) {
        return RecipeDetail.fromJson(cachedData);
      }
      
      final response = await http.get(_buildUrl('/recipes/$recipeId/information', params));

      final result = await _handleResponse(response);
      final data = result['data'];
      
      // Cache the result
      _cacheData(cacheKey, data);
      
      return RecipeDetail.fromJson(data);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to get recipe details: ${e.toString()}');
    }
  }
  
  // Complex search for recipes with multiple filters and caching
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
    try {
      Map<String, dynamic> queryParams = {
        'number': number.toString(),
        'offset': offset.toString(),
        'sort': sort,
        'sortDirection': sortDirection,
        'addRecipeInformation': includeInstructions.toString(),
      };
      
      if (query != null && query.isNotEmpty) {
        queryParams['query'] = query;
      }
      
      if (cuisine != null && cuisine.isNotEmpty) {
        queryParams['cuisine'] = cuisine.join(',');
      }
      
      if (diet != null && diet.isNotEmpty) {
        queryParams['diet'] = diet.join(',');
      }
      
      if (intolerances != null && intolerances.isNotEmpty) {
        queryParams['intolerances'] = intolerances.join(',');
      }
      
      if (includeIngredients != null && includeIngredients.isNotEmpty) {
        queryParams['includeIngredients'] = includeIngredients.join(',');
      }
      
      if (excludeIngredients != null && excludeIngredients.isNotEmpty) {
        queryParams['excludeIngredients'] = excludeIngredients.join(',');
      }
      
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }
      
      if (maxReadyTime > 0) {
        queryParams['maxReadyTime'] = maxReadyTime.toString();
      }
      
      // Build cache key and check cache
      final cacheKey = _generateCacheKey('/recipes/complexSearch', queryParams);
      final cachedData = _getCachedData(cacheKey);
      
      if (cachedData != null) {
        return (cachedData as List).map((json) => Recipe.fromJson(json)).toList();
      }
      
      final response = await http.get(_buildUrl('/recipes/complexSearch', queryParams));
      final result = await _handleResponse(response);
      
      // Complex search returns results inside a 'results' array
      final List<dynamic> data = result['data']['results'];
      
      // Cache the result
      _cacheData(cacheKey, data);
      
      return data.map((json) => Recipe.fromJson(json)).toList();
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to search recipes: ${e.toString()}');
    }
  }
} 