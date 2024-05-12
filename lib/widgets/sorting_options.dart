import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../models/filter_options.dart';

class SortingOptions extends StatelessWidget {
  final String currentSort;
  final String currentDirection;
  final Function(String, String) onSortChanged;

  const SortingOptions({
    super.key,
    required this.currentSort,
    required this.currentDirection,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(51),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.sort,
                size: 18,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              const Text(
                'Sort by:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<String>(
                  value: currentSort,
                  isExpanded: true,
                  underline: Container(
                    height: 1,
                    color: Colors.grey.shade300,
                  ),
                  onChanged: (value) {
                    if (value != null) {
                      onSortChanged(value, currentDirection);
                    }
                  },
                  items: sortOptions.map((option) {
                    return DropdownMenuItem<String>(
                      value: option.value,
                      child: Text(option.label),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(width: 26),
              const Text(
                'Order:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: Icon(
                  Icons.arrow_upward,
                  color: currentDirection == 'asc'
                      ? AppTheme.primaryColor
                      : Colors.grey,
                  size: 20,
                ),
                onPressed: () => onSortChanged(currentSort, 'asc'),
              ),
              IconButton(
                icon: Icon(
                  Icons.arrow_downward,
                  color: currentDirection == 'desc'
                      ? AppTheme.primaryColor
                      : Colors.grey,
                  size: 20,
                ),
                onPressed: () => onSortChanged(currentSort, 'desc'),
              ),
              const Spacer(),
              Text(
                currentDirection == 'desc'
                    ? 'High to Low'
                    : 'Low to High',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 