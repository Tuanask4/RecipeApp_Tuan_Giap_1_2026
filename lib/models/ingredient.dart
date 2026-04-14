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

  // Hàm tính toán khẩu phần (Dynamic Portion)
  Ingredient copyWithMultiplier(double multiplier) {
    return Ingredient(
      id: id,
      name: name,
      amount: amount * multiplier,
      unit: unit,
    );
  }

  // =================================================================
  // BỘ PHIÊN DỊCH 1: TỪ DART SANG FIREBASE (Ép nguyên liệu thành Map)
  // =================================================================
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'unit': unit,
    };
  }

  // =================================================================
  // BỘ PHIÊN DỊCH 2: TỪ FIREBASE SANG DART (Giải nén từ Map ra Object)
  // =================================================================
  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      unit: map['unit'] ?? '',
    );
  }
}