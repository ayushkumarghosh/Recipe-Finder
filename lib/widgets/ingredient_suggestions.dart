import 'package:flutter/material.dart';
import '../models/ingredient.dart';
import '../constants/app_theme.dart';

class IngredientSuggestions extends StatelessWidget {
  final List<Ingredient> suggestions;
  final Function(Ingredient) onSuggestionSelected;
  final double maxHeight;

  const IngredientSuggestions({
    super.key,
    required this.suggestions,
    required this.onSuggestionSelected,
    this.maxHeight = 200,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final ingredient = suggestions[index];
            final isRecent = !ingredient.isCommon;
            
            return InkWell(
              onTap: () => onSuggestionSelected(ingredient),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(
                      isRecent 
                          ? Icons.history 
                          : Icons.restaurant,
                      size: 18,
                      color: isRecent
                          ? Colors.grey.shade600
                          : AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        ingredient.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isRecent ? FontWeight.normal : FontWeight.w500,
                          color: isRecent ? Colors.grey.shade800 : Colors.black,
                        ),
                      ),
                    ),
                    if (ingredient.category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          ingredient.category!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryColor.withOpacity(0.8),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
} 