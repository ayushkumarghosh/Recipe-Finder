import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class IngredientChips extends StatelessWidget {
  final List<String> ingredients;
  final Function(String) onRemove;

  const IngredientChips({
    super.key,
    required this.ingredients,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (ingredients.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your ingredients:',
          style: AppTheme.labelLarge,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ingredients.map((ingredient) {
              return _buildIngredientChip(ingredient);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientChip(String ingredient) {
    return AnimatedScale(
      scale: 1.0,
      duration: const Duration(milliseconds: 200),
      child: Chip(
        label: Text(
          ingredient,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: () => onRemove(ingredient),
        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
        side: const BorderSide(color: AppTheme.primaryColor, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
} 