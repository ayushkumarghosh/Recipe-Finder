import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
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
  final int _cacheTtl = 3600; // Increased to 1 hour
  // Cache timestamps for expiration
  final Map<String, DateTime> _cacheTimestamps = {};
  // Track ongoing requests to prevent duplicate API calls
  final Map<String, Completer<dynamic>> _ongoingRequests = {};
  
  // Key for persistent cache in SharedPreferences
  static const String _persistentCacheKey = 'api_response_cache';
  static const String _persistentCacheTimestampKey = 'api_cache_timestamps';

  ApiService() {
    apiKey = dotenv.env['SPOONACULAR_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw ApiException('API key not found. Please check your .env file.');
    }
    // Load cache from persistent storage
    _loadCacheFromStorage();
  }
  
  // Load cache from persistent storage
  Future<void> _loadCacheFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final persistentCache = prefs.getString(_persistentCacheKey);
      final persistentTimestamps = prefs.getString(_persistentCacheTimestampKey);
      
      if (persistentCache != null && persistentTimestamps != null) {
        final decodedCache = json.decode(persistentCache) as Map<String, dynamic>;
        final decodedTimestamps = json.decode(persistentTimestamps) as Map<String, dynamic>;
        
        // Convert timestamps back to DateTime
        final timestamps = <String, DateTime>{};
        decodedTimestamps.forEach((key, value) {
          timestamps[key] = DateTime.fromMillisecondsSinceEpoch(value as int);
        });
        
        // Only load entries that haven't expired
        final now = DateTime.now();
        decodedCache.forEach((key, value) {
          final timestamp = timestamps[key];
          if (timestamp != null) {
            final expiration = timestamp.add(Duration(seconds: _cacheTtl));
            if (now.isBefore(expiration)) {
              _cache[key] = value;
              _cacheTimestamps[key] = timestamp;
            }
          }
        });
      }
    } catch (e) {
      // If loading fails, simply start with an empty cache
      // No need to throw an exception here
    }
  }
  
  // Save cache to persistent storage
  Future<void> _saveCacheToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Convert timestamps to milliseconds for JSON serialization
      final timestamps = <String, int>{};
      _cacheTimestamps.forEach((key, value) {
        timestamps[key] = value.millisecondsSinceEpoch;
      });
      
      // Only save if there's data to save
      if (_cache.isNotEmpty) {
        await prefs.setString(_persistentCacheKey, json.encode(_cache));
        await prefs.setString(_persistentCacheTimestampKey, json.encode(timestamps));
      }
    } catch (e) {
      // If saving fails, just continue
      // The in-memory cache will still work
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
    
    // Save to persistent storage asynchronously
    unawaited(_saveCacheToStorage());
  }
  
  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
    // Clear from persistent storage as well
    _saveCacheToStorage();
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
  
  // Generic method to make API requests with caching and concurrent request handling
  Future<T> _makeApiRequest<T>(String endpoint, Map<String, dynamic> params, 
      Future<http.Response> Function() apiCall, T Function(dynamic) transform) async {
    final cacheKey = _generateCacheKey(endpoint, params);
    
    // Check cache first
    final cachedData = _getCachedData(cacheKey);
    if (cachedData != null) {
      return transform(cachedData);
    }
    
    // Check if there's an ongoing request for this exact endpoint and params
    if (_ongoingRequests.containsKey(cacheKey)) {
      // Wait for the existing request to complete instead of making a duplicate
      return _ongoingRequests[cacheKey]!.future.then((data) => transform(data)) as Future<T>;
    }
    
    // Create a completer to track this request
    final completer = Completer<dynamic>();
    _ongoingRequests[cacheKey] = completer;
    
    try {
      final response = await apiCall();
      final result = await _handleResponse(response);
      final data = endpoint.contains('complexSearch') ? result['data']['results'] : result['data'];
      
      // Cache the result
      _cacheData(cacheKey, data);
      
      // Complete the request
      completer.complete(data);
      _ongoingRequests.remove(cacheKey);
      
      return transform(data);
    } catch (e) {
      // Complete with error
      completer.completeError(e);
      _ongoingRequests.remove(cacheKey);
      
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('API request failed: ${e.toString()}');
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
    final String ingredientsStr = ingredients.join(',');
    
    final params = {
      'ingredients': ingredientsStr,
      'number': number.toString(),
      'ranking': ranking.toString(),
      'ignorePantry': ignorePantry.toString(),
      'limitLicense': limitLicense.toString(),
    };
    
    return _makeApiRequest<List<Recipe>>(
      '/recipes/findByIngredients',
      params,
      () => http.get(_buildUrl('/recipes/findByIngredients', params)),
      (data) => (data as List).map((json) => Recipe.fromJson(json)).toList()
    );
  }
  
  // Get detailed information about a specific recipe with caching
  Future<RecipeDetail> getRecipeDetails(
    int recipeId, {
    bool includeNutrition = false,
  }) async {
    final params = {
      'includeNutrition': includeNutrition.toString(),
    };
    
    return _makeApiRequest<RecipeDetail>(
      '/recipes/$recipeId/information',
      params,
      () => http.get(_buildUrl('/recipes/$recipeId/information', params)),
      (data) => RecipeDetail.fromJson(data)
    );
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
    
    return _makeApiRequest<List<Recipe>>(
      '/recipes/complexSearch',
      queryParams,
      () => http.get(_buildUrl('/recipes/complexSearch', queryParams)),
      (data) => (data as List).map((json) => Recipe.fromJson(json)).toList()
    );
  }
}

/// Make unawaited calls easier to identify
void unawaited(Future<void> future) {} 