import 'package:flutter/material.dart';
import '../models/filter_options.dart';

class FilterBadges extends StatelessWidget {
  final FilterOptions filters;
  final VoidCallback onFilterClear;

  const FilterBadges({
    super.key,
    required this.filters,
    required this.onFilterClear,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> badges = [];
    
    // Add cuisine badges
    if (filters.cuisine != null && filters.cuisine!.isNotEmpty) {
      badges.add(_buildBadge('Cuisine', filters.cuisine!.join(', ')));
    }
    
    // Add diet badges
    if (filters.diet != null && filters.diet!.isNotEmpty) {
      badges.add(_buildBadge('Diet', filters.diet!.join(', ')));
    }
    
    // Add intolerances badges
    if (filters.intolerances != null && filters.intolerances!.isNotEmpty) {
      badges.add(_buildBadge('Intolerances', filters.intolerances!.join(', ')));
    }
    
    // Add excluded ingredients badge
    if (filters.excludeIngredients != null && filters.excludeIngredients!.isNotEmpty) {
      badges.add(_buildBadge('Excluding', filters.excludeIngredients!.join(', ')));
    }
    
    // Add meal type badge
    if (filters.type != null && filters.type!.isNotEmpty) {
      badges.add(_buildBadge('Type', filters.type!));
    }
    
    // Add cooking time badge
    if (filters.maxReadyTime > 0) {
      badges.add(_buildBadge('Max Time', '${filters.maxReadyTime} mins'));
    }
    
    // If there are no filter badges, return an empty container
    if (badges.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.filter_list,
                size: 16,
              ),
              const SizedBox(width: 4),
              const Text(
                'Active Filters:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onFilterClear,
                child: const Text(
                  'Clear All',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: badges,
          ),
        ],
      ),
    );
  }
  
  Widget _buildBadge(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 12,
          color: Colors.blue.shade800,
        ),
      ),
    );
  }
} 