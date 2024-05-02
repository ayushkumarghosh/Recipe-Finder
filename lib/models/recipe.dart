class Recipe {
  final int id;
  final String title;
  final String image;
  final int usedIngredientCount;
  final int missedIngredientCount;
  final List<RecipeIngredient> usedIngredients;
  final List<RecipeIngredient> missedIngredients;
  final int likes;

  Recipe({
    required this.id,
    required this.title,
    required this.image,
    required this.usedIngredientCount,
    required this.missedIngredientCount,
    required this.usedIngredients,
    required this.missedIngredients,
    required this.likes,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    List<RecipeIngredient> parseIngredients(List<dynamic> ingredientList) {
      return ingredientList
          .map((item) => RecipeIngredient.fromJson(item))
          .toList();
    }

    return Recipe(
      id: json['id'],
      title: json['title'],
      image: json['image'],
      usedIngredientCount: json['usedIngredientCount'],
      missedIngredientCount: json['missedIngredientCount'],
      usedIngredients: parseIngredients(json['usedIngredients'] ?? []),
      missedIngredients: parseIngredients(json['missedIngredients'] ?? []),
      likes: json['likes'] ?? 0,
    );
  }
}

class RecipeIngredient {
  final int id;
  final String name;
  final String image;
  final double amount;
  final String unit;

  RecipeIngredient({
    required this.id,
    required this.name,
    required this.image,
    required this.amount,
    required this.unit,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      id: json['id'],
      name: json['name'],
      image: json['image'] ?? '',
      amount: json['amount']?.toDouble() ?? 0.0,
      unit: json['unit'] ?? '',
    );
  }
} 