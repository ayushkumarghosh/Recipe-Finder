class FilterOptions {
  final List<String>? cuisine;
  final List<String>? diet;
  final List<String>? intolerances;
  final List<String>? excludeIngredients;
  final String? type;
  final int maxReadyTime;
  final String sortOption;
  final String sortDirection;

  FilterOptions({
    this.cuisine,
    this.diet,
    this.intolerances,
    this.excludeIngredients,
    this.type,
    this.maxReadyTime = 0,
    this.sortOption = 'popularity',
    this.sortDirection = 'desc',
  });

  FilterOptions copyWith({
    List<String>? cuisine,
    List<String>? diet,
    List<String>? intolerances,
    List<String>? excludeIngredients,
    String? type,
    int? maxReadyTime,
    String? sortOption,
    String? sortDirection,
  }) {
    return FilterOptions(
      cuisine: cuisine ?? this.cuisine,
      diet: diet ?? this.diet,
      intolerances: intolerances ?? this.intolerances,
      excludeIngredients: excludeIngredients ?? this.excludeIngredients,
      type: type ?? this.type,
      maxReadyTime: maxReadyTime ?? this.maxReadyTime,
      sortOption: sortOption ?? this.sortOption,
      sortDirection: sortDirection ?? this.sortDirection,
    );
  }
}

class SortOption {
  final String value;
  final String label;

  const SortOption(this.value, this.label);
}

// Available sort options for recipes
final List<SortOption> sortOptions = [
  const SortOption('popularity', 'Popularity'),
  const SortOption('healthiness', 'Healthiness'),
  const SortOption('time', 'Preparation Time'),
  const SortOption('random', 'Random'),
  const SortOption('max-used-ingredients', 'Maximum Used Ingredients'),
  const SortOption('min-missing-ingredients', 'Minimum Missing Ingredients'),
  const SortOption('calories', 'Calories'),
  const SortOption('protein', 'Protein'),
  const SortOption('fat', 'Fat'),
  const SortOption('carbs', 'Carbs'),
];

// Available cuisine options
final List<String> cuisineOptions = [
  'African', 'American', 'British', 'Cajun', 'Caribbean', 'Chinese', 'Eastern European',
  'European', 'French', 'German', 'Greek', 'Indian', 'Irish', 'Italian', 'Japanese',
  'Jewish', 'Korean', 'Latin American', 'Mediterranean', 'Mexican', 'Middle Eastern',
  'Nordic', 'Southern', 'Spanish', 'Thai', 'Vietnamese'
];

// Available diet options
final List<String> dietOptions = [
  'Gluten Free', 'Ketogenic', 'Vegetarian', 'Lacto-Vegetarian',
  'Ovo-Vegetarian', 'Vegan', 'Pescetarian', 'Paleo', 'Primal', 'Whole30'
];

// Available intolerances options
final List<String> intoleranceOptions = [
  'Dairy', 'Egg', 'Gluten', 'Grain', 'Peanut', 'Seafood',
  'Sesame', 'Shellfish', 'Soy', 'Sulfite', 'Tree Nut', 'Wheat'
];

// Available meal type options
final List<String> mealTypeOptions = [
  'Main Course', 'Side Dish', 'Dessert', 'Appetizer', 'Salad',
  'Bread', 'Breakfast', 'Soup', 'Beverage', 'Sauce', 'Drink'
]; 