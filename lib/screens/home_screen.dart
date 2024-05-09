import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../models/ingredient.dart';
import '../services/ingredient_service.dart';
import '../services/storage_service.dart';
import '../utils/local_storage.dart';
import '../widgets/ingredient_input.dart';
import '../widgets/ingredient_chips.dart';
import 'recipe_results_screen.dart';
import 'favorites_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _ingredients = [];
  final TextEditingController _ingredientController = TextEditingController();
  final FocusNode _ingredientFocusNode = FocusNode();
  late IngredientService _ingredientService;
  bool _isSubmitting = false;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _ingredientService = IngredientService();
    _loadSavedIngredients();
  }
  
  Future<void> _loadSavedIngredients() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Initialize common ingredients list if it's the first launch
      await _ingredientService.initializeCommonIngredients();
      
      // Load saved ingredients from local storage
      final savedIngredients = await LocalStorage.getIngredients();
      
      if (savedIngredients.isNotEmpty) {
        setState(() {
          _ingredients.addAll(savedIngredients);
        });
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _ingredientController.dispose();
    _ingredientFocusNode.dispose();
    super.dispose();
  }

  Future<void> _addIngredient(String ingredient) async {
    if (!_ingredients.contains(ingredient)) {
      // Save to recent ingredients
      await _ingredientService.saveRecentIngredient(
        Ingredient(name: ingredient),
      );
      
      setState(() {
        _ingredients.add(ingredient);
      });
      
      // Save updated ingredients list to local storage
      await LocalStorage.saveIngredients(_ingredients);
    } else {
      // Show snackbar if ingredient already exists
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$ingredient is already in your list'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _removeIngredient(String ingredient) async {
    setState(() {
      _ingredients.remove(ingredient);
    });
    
    // Save updated ingredients list to local storage
    await LocalStorage.saveIngredients(_ingredients);
  }

  void _findRecipes() {
    if (_ingredients.isEmpty) return;
    
    setState(() {
      _isSubmitting = true;
    });
    
    // Add to search history
    LocalStorage.addToSearchHistory(_ingredients);
    
    // Save to search history using StorageService
    final storageService = Provider.of<StorageService>(context, listen: false);
    storageService.addSearchQuery(_ingredients.join(', '));
    
    // Simulate a small delay to show loading state
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeResultsScreen(
              ingredients: _ingredients,
            ),
          ),
        );
      }
    });
  }

  void _setIngredientsList(List<String> ingredients) {
    setState(() {
      _ingredients.clear();
      _ingredients.addAll(ingredients);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 180.0,
            pinned: true,
            actions: [
              // Favorites button
              IconButton(
                icon: const Icon(Icons.favorite),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FavoritesScreen(),
                    ),
                  );
                },
                tooltip: 'Favorites',
              ),
              // History button
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HistoryScreen(
                        onSelectIngredients: _setIngredientsList,
                      ),
                    ),
                  );
                },
                tooltip: 'Search History',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Recipe Finder'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Food pattern background
                    Opacity(
                      opacity: 0.1,
                      child: Image.network(
                        'https://images.unsplash.com/photo-1606787366850-de6330128bfc?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Icon overlay
                    const Center(
                      child: Icon(
                        Icons.restaurant_menu,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Main Content
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Header text
                const Text(
                  'Find recipes with your ingredients',
                  style: AppTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add ingredients you have and discover delicious recipes',
                  style: AppTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // Ingredient input using our reusable widget
                IngredientInput(
                  controller: _ingredientController,
                  focusNode: _ingredientFocusNode,
                  onIngredientAdded: _addIngredient,
                ),
                
                const SizedBox(height: 16),
                
                // Ingredient chips using our reusable widget
                if (_ingredients.isNotEmpty)
                  IngredientChips(
                    ingredients: _ingredients,
                    onRemove: _removeIngredient,
                  ),
                
                const SizedBox(height: 24),
                
                // Search button with loading state
                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _ingredients.isEmpty || _isSubmitting ? null : _findRecipes,
                    icon: _isSubmitting
                        ? Container(
                            width: 24,
                            height: 24,
                            padding: const EdgeInsets.all(2.0),
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Icon(Icons.search),
                    label: Text(
                      _isSubmitting ? 'Finding Recipes...' : 'Find Recipes',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Empty state or quick recipes section
                if (_ingredients.isEmpty)
                  Column(
                    children: [
                      Container(
                        width: screenSize.width * 0.5,
                        height: screenSize.width * 0.5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.restaurant,
                            size: screenSize.width * 0.25,
                            color: AppTheme.primaryColor.withOpacity(0.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Add ingredients to find delicious recipes!',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textColorSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Try adding ingredients you have in your kitchen',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textColorSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
              ]),
            ),
          ),
        ],
      ),
      // Floating action button to clear all ingredients
      floatingActionButton: _ingredients.isNotEmpty
          ? FloatingActionButton(
              mini: true,
              onPressed: () async {
                setState(() {
                  _ingredients.clear();
                });
                
                // Clear from local storage
                await LocalStorage.saveIngredients([]);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All ingredients cleared'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              tooltip: 'Clear all ingredients',
              child: const Icon(Icons.delete_sweep),
            )
          : null,
    );
  }
} 