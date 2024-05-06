import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class ErrorRecipeResults extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onGoBack;

  const ErrorRecipeResults({
    super.key,
    required this.errorMessage,
    required this.onRetry,
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
                color: AppTheme.errorColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: AppTheme.errorColor,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Something went wrong',
              style: AppTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: onGoBack,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Go Back'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textColorPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 