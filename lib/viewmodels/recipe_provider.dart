import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recipe.dart';
import '../models/ingredient.dart';

// Tạo một Provider cung cấp danh sách List<Recipe>
// Sau này khi nối với Firebase, chúng ta chỉ cần sửa code ở TRONG khối này,
// giao diện (View) bên ngoài sẽ không cần phải sửa đổi một dòng nào cả.
final recipeListProvider = Provider<List<Recipe>>((ref) {
  return [
    Recipe(
      id: 'r1',
      title: 'Ức gà áp chảo siêu tốc',
      imageUrl: 'https://images.unsplash.com/photo-1532550907401-a500c9a57435?q=80&w=800&auto=format&fit=crop',
      durationMinutes: 15,
      difficulty: Difficulty.easy,
      defaultServings: 1,
      ingredients: [
        Ingredient(id: 'i1', name: 'Ức gà', amount: 200, unit: 'gram'),
        Ingredient(id: 'i2', name: 'Dầu oliu', amount: 1, unit: 'thìa'),
      ],
      steps: ['Làm nóng chảo', 'Áp chảo mỗi mặt 4 phút', 'Thái nhỏ và thưởng thức'],
    ),
    Recipe(
      id: 'r2',
      title: 'Salad bơ cá hồi',
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=800&auto=format&fit=crop',
      durationMinutes: 10,
      difficulty: Difficulty.easy,
      defaultServings: 2,
      ingredients: [
        Ingredient(id: 'i3', name: 'Cá hồi hun khói', amount: 100, unit: 'gram'),
        Ingredient(id: 'i4', name: 'Bơ', amount: 1, unit: 'quả'),
      ],
      steps: ['Cắt bơ thành hạt lựu', 'Trộn cá hồi và bơ', 'Rưới nước sốt'],
    ),
    Recipe(
      id: 'r3',
      title: 'Mì Ý Sốt Bò Băm',
      imageUrl: 'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?q=80&w=800&auto=format&fit=crop',
      durationMinutes: 30,
      difficulty: Difficulty.medium,
      defaultServings: 3,
      ingredients: [
        Ingredient(id: 'i5', name: 'Mì Ý', amount: 250, unit: 'gram'),
        Ingredient(id: 'i6', name: 'Thịt bò băm', amount: 300, unit: 'gram'),
      ],
      steps: ['Luộc mì 8 phút', 'Xào thịt bò với sốt cà chua', 'Trộn mì và sốt'],
    ),
  ];
});

// --- THÊM VÀO CUỐI FILE recipe_provider.dart ---

// 1. Provider lưu trữ danh sách các nguyên liệu người dùng ĐANG CÓ (trong tủ lạnh)
final selectedIngredientsProvider = StateProvider<Set<String>>((ref) => {});

// 2. Class phụ trợ để lưu trữ "Điểm số" của từng món ăn
class RecipeMatch {
  final Recipe recipe;
  final int matchedCount; // Số nguyên liệu trùng khớp
  final int totalCount;   // Tổng số nguyên liệu của món
  
  // Tỷ lệ trùng khớp (0.0 đến 1.0)
  double get matchPercentage => matchedCount / totalCount;

  RecipeMatch(this.recipe, this.matchedCount, this.totalCount);
}

// 3. Thuật toán lọc và sắp xếp (Sử dụng logic tối ưu Greedy)
final smartPantryProvider = Provider<List<RecipeMatch>>((ref) {
  final recipes = ref.watch(recipeListProvider);
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

// 4. Provider tự động trích xuất TẤT CẢ nguyên liệu độc nhất từ kho dữ liệu để hiển thị lên màn hình
final allIngredientsProvider = Provider<List<String>>((ref) {
  final recipes = ref.watch(recipeListProvider);
  final Set<String> uniqueIngredients = {};
  
  for (var recipe in recipes) {
    for (var ingredient in recipe.ingredients) {
      uniqueIngredients.add(ingredient.name);
    }
  }
  return uniqueIngredients.toList();
});