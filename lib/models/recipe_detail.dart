import 'recipe.dart';

class RecipeIngredient {
  final int id;
  final String name;
  final double amount;
  final String unit;
  final String original;

  RecipeIngredient({
    required this.id,
    required this.name,
    required this.amount,
    required this.unit,
    required this.original,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      id: json['id'] as int,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      unit: json['unit'] as String,
      original: json['original'] as String,
    );
  }
}

class RecipeStep {
  final int number;
  final String step;

  RecipeStep({
    required this.number,
    required this.step,
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      number: json['number'] as int,
      step: json['step'] as String,
    );
  }
}

class RecipeDetail {
  final int id;
  final String title;
  final String image;
  final int readyInMinutes;
  final int servings;
  final double healthScore;
  final String summary;
  final List<RecipeIngredient> ingredients;
  final List<RecipeStep> steps;
  final bool vegetarian;
  final bool vegan;
  final bool glutenFree;
  final bool dairyFree;
  final bool sustainable;

  RecipeDetail({
    required this.id,
    required this.title,
    required this.image,
    required this.readyInMinutes,
    required this.servings,
    required this.healthScore,
    required this.summary,
    required this.ingredients,
    required this.steps,
    required this.vegetarian,
    required this.vegan,
    required this.glutenFree,
    required this.dairyFree,
    required this.sustainable,
  });

  factory RecipeDetail.fromJson(Map<String, dynamic> json) {
    // Handle ingredients
    List<RecipeIngredient> ingredients = [];
    if (json['extendedIngredients'] != null) {
      ingredients = (json['extendedIngredients'] as List)
          .map((i) => RecipeIngredient.fromJson(i))
          .toList();
    }

    // Handle steps
    List<RecipeStep> steps = [];
    if (json['analyzedInstructions'] != null && (json['analyzedInstructions'] as List).isNotEmpty) {
      final instructions = json['analyzedInstructions'][0];
      if (instructions['steps'] != null) {
        steps = (instructions['steps'] as List)
            .map((s) => RecipeStep.fromJson(s))
            .toList();
      }
    }

    return RecipeDetail(
      id: json['id'] as int,
      title: json['title'] as String,
      image: json['image'] ?? '',
      readyInMinutes: json['readyInMinutes'] as int? ?? 0,
      servings: json['servings'] as int? ?? 1,
      healthScore: (json['healthScore'] as num?)?.toDouble() ?? 0,
      summary: json['summary'] as String? ?? '',
      ingredients: ingredients,
      steps: steps,
      vegetarian: json['vegetarian'] as bool? ?? false,
      vegan: json['vegan'] as bool? ?? false,
      glutenFree: json['glutenFree'] as bool? ?? false,
      dairyFree: json['dairyFree'] as bool? ?? false,
      sustainable: json['sustainable'] as bool? ?? false,
    );
  }
  
  // Convert RecipeDetail to Recipe for storage
  Recipe toRecipe() {
    return Recipe(
      id: id,
      title: title,
      image: image,
      likes: 0, // Not included in detail
      missedIngredientCount: 0, // Not relevant for favorites
      usedIngredientCount: ingredients.length,
      missedIngredients: [], // Not needed for favorites
      usedIngredients: [], // Not needed for favorites
    );
  }
} 