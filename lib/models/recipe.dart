import 'package:cloud_firestore/cloud_firestore.dart';
import 'ingredient.dart';

enum Difficulty { easy, medium, hard }

class Recipe {
  final String id;
  final String title;
  final String imageUrl;
  final int durationMinutes;
  final Difficulty difficulty;
  final int defaultServings;
  final List<Ingredient> ingredients;
  final List<String> steps;

  // ===========================================================================
  // THÊM MỚI: Thông tin tác giả & metadata
  // authorId    — uid của người tạo, dùng để kiểm tra quyền sửa/xóa
  // authorName  — tên hiển thị, tránh query thêm vào collection users
  // createdAt   — dùng để orderBy mới nhất lên đầu
  // isPublic    — true = hiện trên community feed, false = chỉ mình thấy
  // ===========================================================================
  final String authorId;
  final String authorName;
  final DateTime? createdAt;
  final bool isPublic;

  Recipe({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.durationMinutes,
    required this.difficulty,
    required this.defaultServings,
    required this.ingredients,
    required this.steps,
    required this.authorId,
    required this.authorName,
    this.createdAt,
    this.isPublic = true,
  });

  // =================================================================
  // BỘ PHIÊN DỊCH 1: TỪ DART SANG FIREBASE
  // =================================================================
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'durationMinutes': durationMinutes,
      'difficulty': difficulty.name,
      'defaultServings': defaultServings,
      'ingredients': ingredients.map((x) => x.toMap()).toList(),
      'steps': steps,
      // Thông tin tác giả — ghi cùng lúc với dữ liệu công thức
      'authorId': authorId,
      'authorName': authorName,
      'isPublic': isPublic,
      // Dùng FieldValue.serverTimestamp() khi tạo mới (xem RecipeFormPage)
      // Ở đây chỉ giữ nguyên giá trị cũ khi update
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  // =================================================================
  // BỘ PHIÊN DỊCH 2: TỪ FIREBASE SANG DART
  // =================================================================
  factory Recipe.fromMap(Map<String, dynamic> map, String documentId) {
    return Recipe(
      id: documentId,
      title: map['title'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      durationMinutes: map['durationMinutes']?.toInt() ?? 0,
      difficulty: Difficulty.values.firstWhere(
        (e) => e.name == map['difficulty'],
        orElse: () => Difficulty.medium,
      ),
      defaultServings: map['defaultServings']?.toInt() ?? 1,
      ingredients: map['ingredients'] != null
          ? List<Ingredient>.from(
              map['ingredients'].map((x) => Ingredient.fromMap(x)))
          : [],
      steps: List<String>.from(map['steps'] ?? []),
      // Đọc authorId — fallback '' để tương thích với data cũ chưa có field này
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? 'Ẩn danh',
      isPublic: map['isPublic'] ?? true,
      // Firestore trả về Timestamp, cần convert sang DateTime
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // =================================================================
  // HELPER: copyWith — dùng khi update một phần mà giữ nguyên phần còn lại
  // =================================================================
  Recipe copyWith({
    String? title,
    String? imageUrl,
    int? durationMinutes,
    Difficulty? difficulty,
    int? defaultServings,
    List<Ingredient>? ingredients,
    List<String>? steps,
    bool? isPublic,
  }) {
    return Recipe(
      id: id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      difficulty: difficulty ?? this.difficulty,
      defaultServings: defaultServings ?? this.defaultServings,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      authorId: authorId,        // không cho đổi authorId
      authorName: authorName,    // không cho đổi authorName
      createdAt: createdAt,      // không cho đổi createdAt
      isPublic: isPublic ?? this.isPublic,
    );
  }
}
