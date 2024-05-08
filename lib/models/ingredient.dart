class Ingredient {
  final String name;
  final String? category;
  final bool isCommon;

  const Ingredient({
    required this.name,
    this.category,
    this.isCommon = false,
  });

  // Convert to and from JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'isCommon': isCommon,
    };
  }

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'],
      category: json['category'],
      isCommon: json['isCommon'] ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Ingredient && other.name.toLowerCase() == name.toLowerCase();
  }

  @override
  int get hashCode => name.toLowerCase().hashCode;
} 