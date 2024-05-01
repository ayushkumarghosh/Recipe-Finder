class Recipe {
  final int id;
  final String title;
  final String image;
  final List<String> usedIngredients;
  final List<String> missedIngredients;
  final int readyInMinutes;
  final int servings;
  final String sourceUrl;

  Recipe({
    required this.id,
    required this.title,
    required this.image,
    required this.usedIngredients,
    required this.missedIngredients,
    this.readyInMinutes = 0,
    this.servings = 0,
    this.sourceUrl = '',
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    // Parse used ingredients
    List<String> used = [];
    if (json['usedIngredients'] != null) {
      for (var ingredient in json['usedIngredients']) {
        used.add(ingredient['original'] ?? ingredient['name'] ?? '');
      }
    }

    // Parse missed ingredients
    List<String> missed = [];
    if (json['missedIngredients'] != null) {
      for (var ingredient in json['missedIngredients']) {
        missed.add(ingredient['original'] ?? ingredient['name'] ?? '');
      }
    }

    return Recipe(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      usedIngredients: used,
      missedIngredients: missed,
      readyInMinutes: json['readyInMinutes'] ?? 0,
      servings: json['servings'] ?? 0,
      sourceUrl: json['sourceUrl'] ?? '',
    );
  }
} 