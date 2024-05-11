import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../models/recipe_detail.dart';
import '../services/api_controller.dart';
import '../services/storage_service.dart';
import '../widgets/optimized_image.dart';

class RecipeDetailScreen extends StatefulWidget {
  final int recipeId;
  final String? recipeTitle;

  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
    this.recipeTitle,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late final Future<RecipeDetail> _recipeFuture;
  bool _isFavorite = false;
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _recipeFuture = Provider.of<ApiController>(context, listen: false)
        .getRecipeDetails(widget.recipeId);
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final isFavorite = await _storageService.isFavorite(widget.recipeId);
    if (mounted) {
      setState(() {
        _isFavorite = isFavorite;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipeTitle ?? 'Recipe Details'),
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
            color: _isFavorite ? Colors.red : null,
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
              _recipeFuture.then((recipe) {
                if (_isFavorite) {
                  _storageService.addFavorite(recipe.toRecipe());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to favorites')),
                  );
                } else {
                  _storageService.removeFavorite(recipe.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Removed from favorites')),
                  );
                }
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<RecipeDetail>(
        future: _recipeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Loading recipe details...',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppTheme.errorColor,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: AppTheme.errorColor),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.no_food,
                    color: AppTheme.textColorSecondary,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Recipe not found',
                    style: AppTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          } else {
            final recipe = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipe image
                  if (recipe.image.isNotEmpty)
                    OptimizedImage(
                      imageUrl: recipe.image,
                      height: 250,
                      width: double.infinity,
                      // Memory optimization for large images
                      memCacheHeight: 800,
                      memCacheWidth: 1200,
                      // Hero animation for smooth transition from recipe card
                      heroTag: 'recipe_image_${recipe.id}',
                    ),
                    
                  // Recipe title and info
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.title,
                          style: AppTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 16,
                          children: [
                            _buildInfoItem(
                              Icons.timer,
                              '${recipe.readyInMinutes} mins',
                            ),
                            _buildInfoItem(
                              Icons.people,
                              '${recipe.servings} servings',
                            ),
                            if (recipe.healthScore > 0)
                              _buildInfoItem(
                                Icons.favorite,
                                'Health: ${recipe.healthScore}',
                              ),
                          ],
                        ),
                        
                        // Divider
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(),
                        ),
                        
                        // Ingredients
                        const Text(
                          'Ingredients',
                          style: AppTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        ...recipe.ingredients.map((ingredient) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.fiber_manual_record,
                                  size: 12,
                                  color: AppTheme.primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${ingredient.amount} ${ingredient.unit} ${ingredient.name}',
                                    style: AppTheme.bodyLarge,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        
                        // Divider
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(),
                        ),
                        
                        // Instructions
                        const Text(
                          'Instructions',
                          style: AppTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        recipe.steps.isNotEmpty
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: recipe.steps
                                    .map((step) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: const BoxDecoration(
                                            color: AppTheme.primaryColor,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              step.number.toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            step.step,
                                            style: AppTheme.bodyLarge,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              )
                            : Text(
                                recipe.summary.isNotEmpty
                                    ? recipe.summary
                                    : 'No instructions available.',
                                style: AppTheme.bodyLarge,
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 18,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: AppTheme.textColorSecondary),
        ),
      ],
    );
  }
} 