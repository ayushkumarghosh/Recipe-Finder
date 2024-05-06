import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class EmptyRecipeResults extends StatelessWidget {
  final VoidCallback onGoBack;

  const EmptyRecipeResults({
    super.key,
    required this.onGoBack,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.no_food,
                color: AppTheme.textColorSecondary,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No recipes found',
              style: AppTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Try using fewer ingredients or check your spelling',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onGoBack,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 