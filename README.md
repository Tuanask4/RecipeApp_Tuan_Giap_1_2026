# 🍳 Recipe App - Ứng Dụng Nấu Ăn Thông Minh

Một ứng dụng di động đa nền tảng được xây dựng bằng **Flutter**, giúp người dùng dễ dàng tìm kiếm công thức nấu ăn, quản lý tủ lạnh thông minh (Smart Pantry) và chia sẻ công thức của riêng mình với cộng đồng.

Dự án áp dụng kiến trúc **MVVM** chuẩn mực, kết hợp với **Provider** để quản lý trạng thái (State Management) và **Firebase** làm backend.

---

## ✨ Tính Năng Nổi Bật (Core Features)

*   🔐 **Xác thực người dùng (Authentication):** Đăng nhập/Đăng ký an toàn bảo mật.
*   🏠 **Trang chủ trực quan:** Hiển thị nổi bật các công thức mới nhất, thanh tìm kiếm tiện lợi và phân mục rõ ràng.
*   🧊 **Tủ Lạnh Thông Minh (Smart Pantry):** Gợi ý món ăn dựa trên những nguyên liệu người dùng đang có sẵn (tập trung vào nguyên liệu chính).
*   📖 **Chi tiết công thức:** Giao diện trực quan, chia rõ nguyên liệu cần chuẩn bị và các bước thực hiện.
*   📝 **Tạo công thức mới:** Form nhập liệu thân thiện, hỗ trợ tải ảnh món ăn lên hệ thống.
*   🌐 **Cộng đồng (Community Feed):** Nơi người dùng lướt xem, tương tác và khám phá các công thức được chia sẻ từ những người dùng khác.

---

## 🛠 Tech Stack & Kiến trúc

*   **Framework:** [Flutter](https://flutter.dev/) (Dart)
*   **Architecture:** MVVM (Model - View - ViewModel)
*   **State Management:** Provider
*   **Backend & Database:** Firebase (Authentication, Cloud Firestore, Cloud Storage)
*   **Tối ưu UI/UX:** Caching hình ảnh (`app_cached_image`), hiệu ứng mượt mà (`animated_scale_card`).

---

## 📂 Cấu Trúc Thư Mục Dự Án (Project Structure)

Dự án được quy hoạch khoa học trong thư mục `lib/` để dễ dàng bảo trì và mở rộng:
```text
lib/
│
├── core/               # Chứa các cấu hình cốt lõi (VD: app_theme.dart)
├── models/             # Định nghĩa cấu trúc dữ liệu (recipe, ingredient)
├── services/           # Giao tiếp với API/Firebase (auth_service, image_upload_service)
├── viewmodels/         # Logic nghiệp vụ & State Management (auth_provider, pantry_provider...)
├── views/              # Giao diện ứng dụng (UI/Screens)
│   ├── auth_page.dart
│   ├── home_page.dart
│   ├── main_layout.dart
│   ├── recipe_detail_page.dart
│   ├── recipe_form_page.dart
│   ├── smart_pantry_page.dart
│   └── community_feed_page.dart
│
├── widgets/            # Các UI Components dùng chung, tái sử dụng (Cards, SearchBar, Headers...)
├── firebase_options.dart # Cấu hình môi trường Firebase
└── main.dart           # Entry point của ứng dụng