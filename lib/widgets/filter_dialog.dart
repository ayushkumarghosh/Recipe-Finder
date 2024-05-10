import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../models/filter_options.dart';

class FilterDialog extends StatefulWidget {
  final FilterOptions initialFilters;
  final Function(FilterOptions) onApplyFilters;

  const FilterDialog({
    super.key,
    required this.initialFilters,
    required this.onApplyFilters,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late FilterOptions _filterOptions;
  late TextEditingController _excludeIngredientsController;
  final List<String> _excludeIngredientsList = [];
  final List<String> _selectedCuisines = [];
  final List<String> _selectedDiets = [];
  final List<String> _selectedIntolerances = [];
  String? _selectedMealType;
  int _maxReadyTime = 0;
  String _selectedSortOption = 'popularity';
  String _sortDirection = 'desc';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _filterOptions = widget.initialFilters;
    
    // Initialize values from initial filters
    _selectedCuisines.addAll(_filterOptions.cuisine ?? []);
    _selectedDiets.addAll(_filterOptions.diet ?? []);
    _selectedIntolerances.addAll(_filterOptions.intolerances ?? []);
    _selectedMealType = _filterOptions.type;
    _maxReadyTime = _filterOptions.maxReadyTime;
    _selectedSortOption = _filterOptions.sortOption;
    _sortDirection = _filterOptions.sortDirection;
    _excludeIngredientsList.addAll(_filterOptions.excludeIngredients ?? []);
    
    _excludeIngredientsController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _excludeIngredientsController.dispose();
    super.dispose();
  }

  void _addExcludeIngredient(String ingredient) {
    if (ingredient.trim().isEmpty) return;
    
    setState(() {
      if (!_excludeIngredientsList.contains(ingredient)) {
        _excludeIngredientsList.add(ingredient);
      }
      _excludeIngredientsController.clear();
    });
  }

  void _removeExcludeIngredient(String ingredient) {
    setState(() {
      _excludeIngredientsList.remove(ingredient);
    });
  }

  void _applyFilters() {
    final updatedFilters = FilterOptions(
      cuisine: _selectedCuisines.isNotEmpty ? _selectedCuisines : null,
      diet: _selectedDiets.isNotEmpty ? _selectedDiets : null,
      intolerances: _selectedIntolerances.isNotEmpty ? _selectedIntolerances : null,
      excludeIngredients: _excludeIngredientsList.isNotEmpty ? _excludeIngredientsList : null,
      type: _selectedMealType,
      maxReadyTime: _maxReadyTime,
      sortOption: _selectedSortOption,
      sortDirection: _sortDirection,
    );
    
    widget.onApplyFilters(updatedFilters);
    Navigator.of(context).pop();
  }

  void _resetFilters() {
    setState(() {
      _selectedCuisines.clear();
      _selectedDiets.clear();
      _selectedIntolerances.clear();
      _excludeIngredientsList.clear();
      _selectedMealType = null;
      _maxReadyTime = 0;
      _selectedSortOption = 'popularity';
      _sortDirection = 'desc';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.maxFinite,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: 600,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter & Sort Recipes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppTheme.primaryColor,
              tabs: const [
                Tab(text: 'Filters'),
                Tab(text: 'Diet & Health'),
                Tab(text: 'Sort'),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFiltersTab(),
                  _buildDietHealthTab(),
                  _buildSortTab(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text('Reset'),
                ),
                ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Cuisine',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: cuisineOptions.map((cuisine) {
              final isSelected = _selectedCuisines.contains(cuisine);
              return FilterChip(
                label: Text(cuisine),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedCuisines.add(cuisine);
                    } else {
                      _selectedCuisines.remove(cuisine);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'Meal Type',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: mealTypeOptions.map((type) {
              final isSelected = _selectedMealType == type;
              return FilterChip(
                label: Text(type),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedMealType = selected ? type : null;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'Maximum Ready Time (minutes)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Slider(
            value: _maxReadyTime.toDouble(),
            min: 0,
            max: 120,
            divisions: 12,
            label: _maxReadyTime == 0 ? 'Any' : '${_maxReadyTime} mins',
            onChanged: (value) {
              setState(() {
                _maxReadyTime = value.round();
              });
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Exclude Ingredients',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _excludeIngredientsController,
                  decoration: const InputDecoration(
                    hintText: 'Enter ingredient to exclude',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  ),
                  onSubmitted: _addExcludeIngredient,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _addExcludeIngredient(_excludeIngredientsController.text),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _excludeIngredientsList.map((ingredient) {
              return Chip(
                label: Text(ingredient),
                onDeleted: () => _removeExcludeIngredient(ingredient),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDietHealthTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Diet',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: dietOptions.map((diet) {
              final isSelected = _selectedDiets.contains(diet);
              return FilterChip(
                label: Text(diet),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedDiets.add(diet);
                    } else {
                      _selectedDiets.remove(diet);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'Intolerances',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: intoleranceOptions.map((intolerance) {
              final isSelected = _selectedIntolerances.contains(intolerance);
              return FilterChip(
                label: Text(intolerance),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedIntolerances.add(intolerance);
                    } else {
                      _selectedIntolerances.remove(intolerance);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSortTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Sort By',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortOptions.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final option = sortOptions[index];
            return RadioListTile<String>(
              title: Text(option.label),
              value: option.value,
              groupValue: _selectedSortOption,
              onChanged: (value) {
                setState(() {
                  _selectedSortOption = value!;
                });
              },
            );
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Sort Direction',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        RadioListTile<String>(
          title: const Text('Descending (high to low)'),
          value: 'desc',
          groupValue: _sortDirection,
          onChanged: (value) {
            setState(() {
              _sortDirection = value!;
            });
          },
        ),
        RadioListTile<String>(
          title: const Text('Ascending (low to high)'),
          value: 'asc',
          groupValue: _sortDirection,
          onChanged: (value) {
            setState(() {
              _sortDirection = value!;
            });
          },
        ),
      ],
    );
  }
} 