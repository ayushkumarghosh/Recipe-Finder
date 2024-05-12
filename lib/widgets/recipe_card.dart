import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../models/recipe.dart';
import '../widgets/optimized_image.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe image with used/missed ingredients indicator
            Stack(
              children: [
                // Recipe image using optimized component
                OptimizedImage(
                  imageUrl: recipe.image,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12.0),
                    topRight: Radius.circular(12.0),
                  ),
                  // Memory optimization
                  memCacheWidth: 600,
                  memCacheHeight: 400,
                  // Hero animation for transition to detail screen
                  heroTag: 'recipe_image_${recipe.id}',
                ),
                // Ingredients used counter
                Positioned(
                  top: 10,
                  right: 10,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withAlpha(230),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 16.0,
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              '${recipe.usedIngredientCount} used',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withAlpha(230),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.remove_circle,
                              color: Colors.white,
                              size: 16.0,
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              '${recipe.missedIngredientCount} missing',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Recipe title and info
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    recipe.likes > 0 
                        ? '${recipe.likes} likes • ${recipe.missedIngredientCount + recipe.usedIngredientCount} ingredients'
                        : '${recipe.missedIngredientCount + recipe.usedIngredientCount} ingredients',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey.shade700,
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