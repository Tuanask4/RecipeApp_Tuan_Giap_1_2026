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

  // =================================================================
  // BỘ PHIÊN DỊCH 1: TỪ DART SANG FIREBASE (Đẩy dữ liệu lên mây)
  // =================================================================
  Map<String, dynamic> toMap() {
    return {
      // Không cần đẩy 'id' lên vì Firebase sẽ dùng nó làm tên File (Document ID)
      'title': title,
      'imageUrl': imageUrl,
      'durationMinutes': durationMinutes,
      'difficulty': difficulty.name, // Chuyển Enum thành chữ ('easy', 'medium', 'hard')
      'defaultServings': defaultServings,
      'ingredients': ingredients.map((x) => x.toMap()).toList(), // Ép từng nguyên liệu thành Map
      'steps': steps,
    };
  }

  // =================================================================
  // BỘ PHIÊN DỊCH 2: TỪ FIREBASE SANG DART (Tải dữ liệu về app)
  // =================================================================
  factory Recipe.fromMap(Map<String, dynamic> map, String documentId) {
    return Recipe(
      id: documentId, // Lấy ID thẳng từ tên File của Firebase
      title: map['title'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      durationMinutes: map['durationMinutes']?.toInt() ?? 0,
      
      // Tìm Enum tương ứng với chữ tải về (Nếu lỗi thì mặc định là medium)
      difficulty: Difficulty.values.firstWhere(
        (e) => e.name == map['difficulty'],
        orElse: () => Difficulty.medium,
      ),
      
      defaultServings: map['defaultServings']?.toInt() ?? 1,
      
      // Quét qua danh sách nguyên liệu và dùng hàm fromMap của Ingredient để dịch ngược lại
      ingredients: map['ingredients'] != null
          ? List<Ingredient>.from(map['ingredients'].map((x) => Ingredient.fromMap(x)))
          : [],
          
      // Ép kiểu an toàn cho danh sách các bước
      steps: List<String>.from(map['steps'] ?? []),
    );
  }
}