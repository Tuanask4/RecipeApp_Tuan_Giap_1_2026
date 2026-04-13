// Định nghĩa một Nguyên liệu
class Ingredient {
  final String id;
  final String name; // Tên: Cà chua, Thịt bò...
  final double amount; // Số lượng: 2, 500...
  final String unit; // Đơn vị: quả, gram, kg...

  Ingredient({
    required this.id,
    required this.name,
    required this.amount,
    required this.unit,
  });

  // Hàm này rất quan trọng để tính toán khẩu phần (Dynamic Portion)
  // Nếu công thức gốc là 2 người, muốn nấu 4 người thì nhân đôi 'amount'
  Ingredient copyWithMultiplier(double multiplier) {
    return Ingredient(
      id: id,
      name: name,
      amount: amount * multiplier,
      unit: unit,
    );
  }
}