class Ingredient {
  final int id;
  final String name;
  final double calories;
  final bool state;

  Ingredient({
    required this.id,
    required this.name,
    required this.calories,
    required this.state,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['ing_id'] is int ? json['ing_id'] : int.parse(json['ing_id'].toString()),
      name: json['ing_name'],
      calories: json['ing_calories'] is double ? json['ing_calories'] : double.parse(json['ing_calories'].toString()),
      state: json['ing_state'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ing_name': name,
      'ing_calories': calories,
      'ing_state': state,
    };
  }
}