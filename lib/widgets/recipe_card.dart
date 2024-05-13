import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../models/recipe.dart';
import '../widgets/optimized_image.dart';
import 'animated_feedback.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final bool isFavorite;
  final Function(Recipe) onFavoriteToggle;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedFeedback(
      type: FeedbackType.scale,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipe Image
              Stack(
                children: [
                  Hero(
                    tag: 'recipe_image_${recipe.id}',
                    child: OptimizedImage(
                      imageUrl: recipe.image,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      highQuality: true,
                    ),
                  ),
                  // Used ingredients count badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _buildUsedIngredientsBadge(),
                  ),
                  // Favorite button
                  Positioned(
                    top: 4,
                    right: 4,
                    child: _buildFavoriteButton(context),
                  ),
                ],
              ),
              // Recipe Info
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recipe title
                    Text(
                      recipe.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Recipe details
                    _buildRecipeDetails(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsedIngredientsBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '${recipe.usedIngredientCount}/${recipe.usedIngredientCount + recipe.missedIngredientCount}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    return AnimatedFeedback(
      type: FeedbackType.pulse,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.grey,
          ),
          onPressed: () {
            onFavoriteToggle(recipe);
          },
          tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
          iconSize: 24,
          constraints: const BoxConstraints(
            minHeight: 40,
            minWidth: 40,
          ),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildRecipeDetails(BuildContext context) {
    return Row(
      children: [
        // Likes
        _buildInfoItem(
          context,
          Icons.thumb_up,
          '${recipe.likes}',
        ),
        const SizedBox(width: 16),
        // Ingredient count
        _buildInfoItem(
          context,
          Icons.list_alt,
          '${recipe.usedIngredientCount + recipe.missedIngredientCount} ingredients',
        ),
      ],
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
} 