class RecipeDetail {
  final int id;
  final String title;
  final String image;
  final int readyInMinutes;
  final int servings;
  final String summary;
  final List<String> dishTypes;
  final List<String> diets;
  final int aggregateLikes;
  final double healthScore;
  final double spoonacularScore;
  final bool cheap;
  final bool veryPopular;
  final bool sustainable;
  final bool veryHealthy;
  final bool dairyFree;
  final bool glutenFree;
  final bool vegan;
  final bool vegetarian;
  final List<RecipeDetailIngredient> ingredients;
  final List<RecipeStep> steps;

  RecipeDetail({
    required this.id,
    required this.title,
    required this.image,
    required this.readyInMinutes,
    required this.servings,
    required this.summary,
    required this.dishTypes,
    required this.diets,
    required this.aggregateLikes,
    required this.healthScore,
    required this.spoonacularScore,
    required this.cheap,
    required this.veryPopular,
    required this.sustainable,
    required this.veryHealthy,
    required this.dairyFree,
    required this.glutenFree,
    required this.vegan,
    required this.vegetarian,
    required this.ingredients,
    required this.steps,
  });

  factory RecipeDetail.fromJson(Map<String, dynamic> json) {
    // Parse ingredients
    List<RecipeDetailIngredient> ingredients = [];
    if (json['extendedIngredients'] != null) {
      ingredients = (json['extendedIngredients'] as List)
          .map((item) => RecipeDetailIngredient.fromJson(item))
          .toList();
    }

    // Parse steps
    List<RecipeStep> steps = [];
    if (json['analyzedInstructions'] != null && 
        json['analyzedInstructions'].isNotEmpty &&
        json['analyzedInstructions'][0]['steps'] != null) {
      steps = (json['analyzedInstructions'][0]['steps'] as List)
          .map((item) => RecipeStep.fromJson(item))
          .toList();
    }

    return RecipeDetail(
      id: json['id'],
      title: json['title'],
      image: json['image'],
      readyInMinutes: json['readyInMinutes'] ?? 0,
      servings: json['servings'] ?? 0,
      summary: json['summary'] ?? '',
      dishTypes: json['dishTypes'] != null 
          ? List<String>.from(json['dishTypes']) 
          : [],
      diets: json['diets'] != null 
          ? List<String>.from(json['diets']) 
          : [],
      aggregateLikes: json['aggregateLikes'] ?? 0,
      healthScore: json['healthScore']?.toDouble() ?? 0.0,
      spoonacularScore: json['spoonacularScore']?.toDouble() ?? 0.0,
      cheap: json['cheap'] ?? false,
      veryPopular: json['veryPopular'] ?? false,
      sustainable: json['sustainable'] ?? false,
      veryHealthy: json['veryHealthy'] ?? false,
      dairyFree: json['dairyFree'] ?? false,
      glutenFree: json['glutenFree'] ?? false,
      vegan: json['vegan'] ?? false,
      vegetarian: json['vegetarian'] ?? false,
      ingredients: ingredients,
      steps: steps,
    );
  }
}

class RecipeDetailIngredient {
  final int id;
  final String name;
  final String original;
  final double amount;
  final String unit;
  final String image;

  RecipeDetailIngredient({
    required this.id,
    required this.name,
    required this.original,
    required this.amount,
    required this.unit,
    required this.image,
  });

  factory RecipeDetailIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeDetailIngredient(
      id: json['id'],
      name: json['name'] ?? '',
      original: json['original'] ?? '',
      amount: json['amount']?.toDouble() ?? 0.0,
      unit: json['unit'] ?? '',
      image: json['image'] ?? '',
    );
  }
}

class RecipeStep {
  final int number;
  final String step;
  final List<String> ingredients;
  final List<String> equipment;

  RecipeStep({
    required this.number,
    required this.step,
    required this.ingredients,
    required this.equipment,
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    // Parse ingredients
    final ingredientsList = json['ingredients'] as List? ?? [];
    final ingredients = ingredientsList
        .map((item) => item['name'] as String? ?? '')
        .where((name) => name.isNotEmpty)
        .toList();

    // Parse equipment
    final equipmentList = json['equipment'] as List? ?? [];
    final equipment = equipmentList
        .map((item) => item['name'] as String? ?? '')
        .where((name) => name.isNotEmpty)
        .toList();

    return RecipeStep(
      number: json['number'] ?? 0,
      step: json['step'] ?? '',
      ingredients: ingredients,
      equipment: equipment,
    );
  }
} 