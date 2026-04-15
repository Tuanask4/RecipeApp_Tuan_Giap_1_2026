import 'package:flutter/material.dart';

class AppTheme {
  // ===========================================================================
  // 1. BẢNG MÀU CHỦ ĐẠO (Color Palette)
  // ===========================================================================
  static const Color primary = Colors.orange;           // Màu cam thương hiệu
  static const Color secondary = Color(0xFFFFA726);     // Cam nhạt (dùng cho hover/nhấn)
  static const Color background = Color(0xFFFAFAFA);    // Trắng ngà (tương đương grey[50])
  static const Color surface = Colors.white;            // Nền của các Thẻ (Card)
  static const Color textDark = Color(0xFF2D3142);      // Đen ánh xanh (Sang trọng hơn đen thui)
  static const Color textLight = Color(0xFF9E9E9E);     // Xám (dùng cho mô tả, thời gian)
  static const Color success = Color(0xFF4CAF50);       // Xanh lá (Thông báo thành công)
  static const Color error = Color(0xFFF44336);         // Đỏ (Báo lỗi)

  // ===========================================================================
  // 2. KÍCH THƯỚC CHUẨN
  // ===========================================================================
  static const double spacingS = 8.0;   // Khoảng cách nhỏ (giữa icon và chữ)
  static const double spacingM = 16.0;  // Padding tiêu chuẩn cho màn hình
  static const double spacingL = 24.0;  // Khoảng cách giữa các khối lớn
  static const double spacingXL = 32.0; // Khoảng cách section

  // ===========================================================================
  // 3. BO GÓC CHUẨN (Border Radius)
  // ===========================================================================
  static final BorderRadius radiusS = BorderRadius.circular(8);
  static final BorderRadius radiusM = BorderRadius.circular(16); // Bo góc thẻ nhỏ
  static final BorderRadius radiusL = BorderRadius.circular(24); // Bo góc thẻ lớn/Thanh tìm kiếm

  // ===========================================================================
  // 4. HIỆU ỨNG ĐỔ BÓNG (Shadows)
  // ===========================================================================
  // Bóng mềm mại cho các Thẻ món ăn
  static final List<BoxShadow> softShadow = [
    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
  ];
  // Bóng màu cam phát sáng cho nút bấm nổi bật (Smart Pantry)
  static final List<BoxShadow> primaryShadow = [
    BoxShadow(color: primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
  ];

  // ===========================================================================
  // 5. KIỂU CHỮ CHUẨN
  // ===========================================================================
  static const TextStyle heading1 = TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textDark);
  static const TextStyle heading2 = TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark);
  static const TextStyle bodyText = TextStyle(fontSize: 14, color: textLight);
  
  static const TextStyle heroTitleStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 22,
    shadows: [Shadow(color: Colors.black87, blurRadius: 8)],
  );

  // ===========================================================================
  // 6. GÓI THEME CHO MAIN.DART (Đồng bộ hóa toàn bộ Widget mặc định của Flutter)
  // ===========================================================================
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: error,
      ),
      // Tự động áp dụng màu chuẩn cho mọi thanh AppBar được tạo sau này
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: heading2,
      ),
    );
  }

  static final BoxDecoration searchBarDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ],
  );
}
