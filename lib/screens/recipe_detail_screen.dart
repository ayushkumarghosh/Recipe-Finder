import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../models/recipe_detail.dart';
import '../services/api_controller.dart';

class RecipeDetailScreen extends StatelessWidget {
  final int recipeId;

  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // TODO: Implement favorite functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to favorites')),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<RecipeDetail>(
        future: Provider.of<ApiController>(context, listen: false)
            .getRecipeDetails(recipeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
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
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
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
                    Image.network(
                      recipe.image,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 250,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.broken_image, size: 60),
                      ),
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
          color: AppTheme.textColorSecondary,
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