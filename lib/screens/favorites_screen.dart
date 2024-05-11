import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../models/recipe.dart';
import '../services/storage_service.dart';
import '../widgets/optimized_image.dart';
import 'recipe_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final StorageService _storageService = StorageService();
  late Future<List<Recipe>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    setState(() {
      _favoritesFuture = _storageService.getFavorites();
    });
  }

  Future<void> _removeFavorite(Recipe recipe) async {
    final result = await _storageService.removeFavorite(recipe.id);
    if (result) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${recipe.title} removed from favorites'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              await _storageService.addFavorite(recipe);
              _loadFavorites();
            },
          ),
        ),
      );
      _loadFavorites();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
      ),
      body: FutureBuilder<List<Recipe>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.favorite_border,
                    color: Colors.grey,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No favorite recipes yet',
                    style: AppTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Find recipes and mark them as favorites',
                    style: TextStyle(
                      color: AppTheme.textColorSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else {
            final recipes = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: recipes.length,
              // Add cacheExtent to improve scrolling performance
              cacheExtent: 500,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return FavoriteRecipeCard(
                  recipe: recipe,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailScreen(
                          recipeId: recipe.id,
                          recipeTitle: recipe.title,
                        ),
                      ),
                    ).then((_) => _loadFavorites());
                  },
                  onRemove: () => _removeFavorite(recipe),
                );
              },
            );
          }
        },
      ),
    );
  }
}

/// A separate widget for favorite recipe card for better performance
class FavoriteRecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const FavoriteRecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe image
            if (recipe.image.isNotEmpty)
              OptimizedImage(
                imageUrl: recipe.image,
                height: 180,
                width: double.infinity,
                // Hero animation for transition to detail screen
                heroTag: 'recipe_image_${recipe.id}',
                // Memory optimization
                memCacheWidth: 600,
                memCacheHeight: 400,
              ),
            
            // Recipe title and info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          recipe.title,
                          style: AppTheme.titleLarge,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                        ),
                        onPressed: onRemove,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Used ingredients: ${recipe.usedIngredientCount}',
                    style: const TextStyle(
                      color: AppTheme.textColorSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Missing ingredients: ${recipe.missedIngredientCount}',
                    style: const TextStyle(
                      color: AppTheme.textColorSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 