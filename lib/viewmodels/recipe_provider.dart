import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe.dart';

// =======================================================================
// 1. STREAM PROVIDER: LẮNG NGHE FIREBASE THỜI GIAN THỰC (REAL-TIME)
// =======================================================================
final recipeListProvider = StreamProvider<List<Recipe>>((ref) {
  return FirebaseFirestore.instance
      .collection('recipes')
      .limit(20)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) => Recipe.fromMap(doc.data(), doc.id))
            .toList();
      });
});

// =======================================================================
// 2. LOGIC TỦ LẠNH THÔNG MINH (SMART PANTRY)
// =======================================================================

// Provider lưu trữ danh sách các nguyên liệu người dùng ĐANG CÓ (trong tủ lạnh)
final selectedIngredientsProvider = StateProvider<Set<String>>((ref) => {});

// Class phụ trợ để lưu trữ "Điểm số" của từng món ăn
class RecipeMatch {
  final Recipe recipe;
  final int matchedCount; // Số nguyên liệu trùng khớp
  final int totalCount; // Tổng số nguyên liệu của món

  // Tỷ lệ trùng khớp (0.0 đến 1.0)
  double get matchPercentage => matchedCount / totalCount;

  RecipeMatch(this.recipe, this.matchedCount, this.totalCount);
}

// Thuật toán lọc và sắp xếp (Sử dụng logic tối ưu Greedy)
final smartPantryProvider = Provider<List<RecipeMatch>>((ref) {
  // Lấy dữ liệu từ StreamProvider (dùng .value để lấy giá trị hiện tại, nếu null thì gán mảng rỗng)
  final recipes = ref.watch(recipeListProvider).value ?? [];
  final selectedIngredients = ref.watch(selectedIngredientsProvider);

  // Nếu tủ lạnh trống, không gợi ý gì cả
  if (selectedIngredients.isEmpty) return [];

  List<RecipeMatch> matches = [];

  // Duyệt qua từng công thức
  for (var recipe in recipes) {
    int matchCount = 0;
    // Kiểm tra xem nguyên liệu của món này có trong tủ lạnh không
    for (var ingredient in recipe.ingredients) {
      if (selectedIngredients.contains(ingredient.name)) {
        matchCount++;
      }
    }

    // Nếu có ít nhất 1 nguyên liệu trùng khớp, đưa vào danh sách xem xét
    if (matchCount > 0) {
      matches.add(RecipeMatch(recipe, matchCount, recipe.ingredients.length));
    }
  }

  // Sắp xếp danh sách ưu tiên món có tỷ lệ trùng khớp cao nhất (Tham lam)
  matches.sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));

  return matches;
});

// Provider tự động trích xuất TẤT CẢ nguyên liệu độc nhất từ kho dữ liệu để hiển thị
final allIngredientsProvider = Provider<List<String>>((ref) {
  final recipes = ref.watch(recipeListProvider).value ?? [];
  final Set<String> uniqueIngredients = {};

  for (var recipe in recipes) {
    for (var ingredient in recipe.ingredients) {
      uniqueIngredients.add(ingredient.name);
    }
  }
  return uniqueIngredients.toList();
});
