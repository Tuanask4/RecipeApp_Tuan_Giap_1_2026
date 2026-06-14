import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recipe.dart';
import 'recipe_provider.dart';

// =======================================================================
// LOGIC TỦ LẠNH THÔNG MINH (SMART PANTRY)
// =======================================================================

// ===========================================================================
// FIX: PantryNotifier thay cho StateProvider<Set<String>> thuần
// Lý do: encapsulate logic toggle, dễ mở rộng sau (max items, persist cloud...)
// ===========================================================================
class PantryNotifier extends StateNotifier<Set<String>> {
  PantryNotifier() : super({});

  // Toggle: có thì bỏ, chưa có thì thêm — 1 hàm duy nhất, gọi ở bất kỳ đâu
  void toggle(String ingredientName) {
    if (state.contains(ingredientName)) {
      state = {...state}..remove(ingredientName);
    } else {
      state = {...state, ingredientName};
    }
  }

  // Xóa toàn bộ tủ lạnh — dùng cho nút "Đặt lại"
  void clear() => state = {};

  // Kiểm tra nhanh không cần watch toàn bộ set
  bool contains(String ingredientName) => state.contains(ingredientName);
}

final selectedIngredientsProvider =
    StateNotifierProvider<PantryNotifier, Set<String>>(
      (ref) => PantryNotifier(),
    );

// ===========================================================================
// RecipeMatch: kết quả gợi ý kèm điểm số
// ===========================================================================
class RecipeMatch {
  final Recipe recipe;
  final int matchedCount;
  final int totalCount;

  double get matchPercentage => matchedCount / totalCount;

  const RecipeMatch(this.recipe, this.matchedCount, this.totalCount);
}

// ===========================================================================
// smartPantryProvider: thuật toán Greedy — sort theo % trùng khớp giảm dần
// ===========================================================================
final smartPantryProvider = Provider<List<RecipeMatch>>((ref) {
  final recipes = ref.watch(recipeListProvider).value ?? [];
  final selected = ref.watch(selectedIngredientsProvider);

  if (selected.isEmpty) return [];

  // Lowercase toàn bộ để so sánh không phân biệt hoa thường
  final selectedLower = selected.map((s) => s.toLowerCase()).toSet();

  // Trong smartPantryProvider
  final matches = <RecipeMatch>[];

  for (final recipe in recipes) {
    int matchCount = 0;
    for (final ingredient in recipe.ingredients) {
      if (selectedLower.any((s) => ingredient.name.toLowerCase().contains(s))) {
        matchCount++;
      }
    }

    if (matchCount >= 1) {
      matches.add(RecipeMatch(recipe, matchCount, recipe.ingredients.length));
    }
  }

  matches.sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));
  return matches;
});

// ===========================================================================
// allIngredientsProvider: danh sách nguyên liệu unique, sort A-Z
// ===========================================================================
final allIngredientsProvider = Provider<List<String>>((ref) {
  final recipes = ref.watch(recipeListProvider).value ?? [];
  final unique = <String>{};

  for (final recipe in recipes) {
    for (final ingredient in recipe.ingredients) {
      if (ingredient.name.trim().isNotEmpty) {
        unique.add(ingredient.name.trim());
      }
    }
  }

  // Sort A-Z để dễ tìm kiếm hơn
  final sorted = unique.toList()..sort();
  return sorted;
});
