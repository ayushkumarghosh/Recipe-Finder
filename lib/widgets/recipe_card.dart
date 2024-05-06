import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../models/recipe.dart';

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
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe image
            _buildRecipeImage(),
            
            // Recipe info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: AppTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.favorite,
                        size: 16,
                        color: AppTheme.secondaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        recipe.likes.toString(),
                        style: const TextStyle(
                          color: AppTheme.textColorSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildIngredientInfo(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeImage() {
    return recipe.image.isNotEmpty
        ? Image.network(
            recipe.image,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
          )
        : _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 200,
      color: Colors.grey.shade300,
      child: const Icon(Icons.image, size: 50),
    );
  }

  Widget _buildIngredientInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Used ingredients: ${recipe.usedIngredientCount}',
          style: const TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          'Missing ingredients: ${recipe.missedIngredientCount}',
          style: TextStyle(
            color: recipe.missedIngredientCount > 0
                ? Colors.orange
                : Colors.green,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
} 