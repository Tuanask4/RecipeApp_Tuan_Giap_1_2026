// lib/models/recipe_model.dart

// Nguyên liệu
class Ingredient {
  final String name;
  final double quantity;
  final String unit; // vd: gam, ml, muỗng

  Ingredient({
    required this.name,
    required this.quantity,
    required this.unit,
  });
}

// Công thức nấu ăn
class Recipe {
  final String id;
  final String title;
  final String imageUrl;
  final int prepTime; // Thời gian chuẩn bị (phút)
  final String difficulty; // Dễ, Trung bình, Khó
  final List<Ingredient> ingredients;
  final List<String> steps; // Các bước thực hiện

  Recipe({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.prepTime,
    required this.difficulty,
    required this.ingredients,
    required this.steps,
  });
}