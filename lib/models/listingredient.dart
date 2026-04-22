import 'Ingredient.dart';

class ListIngredient {
  // ========================
  // Danh sách Ingredient
  // ========================
  List<Ingredient> ingredients = [];

  // ========================
  // CREATE - Thêm mới
  // ========================
  void create(Ingredient ingredient) {
    ingredients.add(ingredient);
  }

  // ========================
  // READ - Đọc tất cả
  // ========================
  void readAll() {
    for (var i in ingredients) {
      print("${i.name} - ${i.quantity} ${i.unit}");
    }
  }

  // ========================
  // UPDATE - Sửa theo name (coi như id)
  // ========================
  void update(String name, double newQuantity, String newUnit) {
    for (var i in ingredients) {
      if (i.name == name) {
        i.quantity = newQuantity;
        i.unit = newUnit;
      }
    }
  }

  // ========================
  // DELETE - Xóa (nếu cần thêm)
  // ========================
  void delete(String name) {
    ingredients.removeWhere((i) => i.name == name);
  }
}