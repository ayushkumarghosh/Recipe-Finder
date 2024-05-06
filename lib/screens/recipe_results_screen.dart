import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_theme.dart';
import '../models/recipe.dart';
import '../services/api_controller.dart';
import '../widgets/recipe_card.dart';
import '../widgets/loading_recipe_card.dart';
import '../widgets/empty_recipe_results.dart';
import '../widgets/error_recipe_results.dart';
import 'recipe_detail_screen.dart';

class RecipeResultsScreen extends StatefulWidget {
  final List<String> ingredients;

  const RecipeResultsScreen({
    super.key,
    required this.ingredients,
  });

  @override
  State<RecipeResultsScreen> createState() => _RecipeResultsScreenState();
}

class _RecipeResultsScreenState extends State<RecipeResultsScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  bool _isSearching = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    // Start the API search when the screen loads
    _searchRecipes();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _searchRecipes() {
    setState(() => _isSearching = true);
    
    // Use the ApiController to search for recipes
    final apiController = Provider.of<ApiController>(context, listen: false);
    apiController.searchRecipesByIngredients(widget.ingredients).then((_) {
      setState(() => _isSearching = false);
    }).catchError((error) {
      setState(() => _isSearching = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Filter functionality will be implemented in a later day
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filtering coming soon!')),
              );
            },
          ),
        ],
      ),
      body: Consumer<ApiController>(
        builder: (context, apiController, child) {
          final state = apiController.state;
          
          // Show loading state
          if (_isSearching || state == RequestState.loading) {
            return _buildLoadingView();
          }
          
          // Show error state
          if (state == RequestState.error) {
            return ErrorRecipeResults(
              errorMessage: apiController.errorMessage,
              onRetry: _searchRecipes,
              onGoBack: () => Navigator.of(context).pop(),
            );
          }
          
          // Show empty state
          final recipes = apiController.recipes;
          if (recipes.isEmpty) {
            return EmptyRecipeResults(
              onGoBack: () => Navigator.of(context).pop(),
            );
          }
          
          // Show results
          return _buildRecipeList(recipes);
        },
      ),
    );
  }
  
  Widget _buildLoadingView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5, // Show 5 shimmer loading cards
      itemBuilder: (context, index) => const LoadingRecipeCard(),
    );
  }
  
  Widget _buildRecipeList(List<Recipe> recipes) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        // Start the animation when we have results
        if (!_animationController.isAnimating && 
            !_animationController.isCompleted) {
          _animationController.forward();
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            
            // Staggered animation for each card
            final Animation<double> animation = CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                index * 0.05, // Stagger the start time
                1.0,
                curve: Curves.easeOut,
              ),
            );
            
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(animation),
                child: RecipeCard(
                  recipe: recipe,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipeDetailScreen(
                        recipeId: recipe.id,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
} 