import 'ingredient.dart';

// Enum phân loại độ khó
enum Difficulty { easy, medium, hard }

// Định nghĩa một Công thức nấu ăn
class Recipe {
  final String id;
  final String title;
  final String imageUrl;
  final int durationMinutes; // Thời gian nấu
  final Difficulty difficulty;
  final int defaultServings; // Khẩu phần mặc định (VD: 2 người)
  final List<Ingredient> ingredients; // Danh sách nguyên liệu
  final List<String> steps; // Các bước thực hiện

  Recipe({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.durationMinutes,
    required this.difficulty,
    required this.defaultServings,
    required this.ingredients,
    required this.steps,
  });
}