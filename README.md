RECIPE APP - Ứng Dụng Quản Lý Công Thức Nấu Ăn Tự Động
Recipe App là một ứng dụng di động đa nền tảng được phát triển nhằm mục đích số hóa trải nghiệm nấu nướng. Ứng dụng không chỉ hỗ trợ lưu trữ công thức cá nhân mà còn tích hợp thuật toán "Tủ lạnh thông minh" giúp giải quyết bài toán cốt lõi: "Hôm nay ăn gì với những nguyên liệu đang có?".

TÍNH NĂNG NỔI BẬT
Quản Lý Dữ Liệu Chuyên Sâu (Full CRUD): Hỗ trợ thêm mới, đọc, cập nhật và xóa (CRUD) các công thức nấu ăn. Giao diện biểu mẫu (form) cho phép mở rộng linh hoạt không giới hạn số lượng nguyên liệu và các bước thực hiện.

Tủ Lạnh Thông Minh (Smart Pantry): Tích hợp thuật toán Tham lam (Greedy Algorithm) để phân tích tập hợp nguyên liệu người dùng đang có, đối chiếu với cơ sở dữ liệu và tự động đề xuất các món ăn có tỷ lệ đáp ứng (Match Percentage) cao nhất.

Tối Ưu Hóa Truy Vấn (Debounced Search): Áp dụng kỹ thuật Debounce (độ trễ 0.5s) trong thanh tìm kiếm nhằm ngăn chặn tình trạng gửi request ồ ạt lên máy chủ, tối ưu hóa chi phí vận hành và tăng cường hiệu năng ứng dụng.

Đồng Bộ Hóa Thời Gian Thực (Real-time Sync): Sử dụng StreamProvider kết nối trực tiếp với Cloud Firestore. Mọi thay đổi dữ liệu từ bất kỳ thiết bị nào đều được phản hồi ngay lập tức trên màn hình ứng dụng mà không cần tải lại trang.

Quản Lý Trạng Thái (State Management): Kiến trúc ứng dụng được xây dựng chặt chẽ với thư viện flutter_riverpod, tách biệt hoàn toàn Logic xử lý khỏi Giao diện (UI).

Giao Diện Chuẩn (Custom UI/UX): Hệ thống AppTheme được định nghĩa nhất quán, tích hợp hiệu ứng tải mượt mà (Shimmer Effect) và tối ưu hóa bộ nhớ đệm hình ảnh (Cached Network Image).

CÔNG NGHỆ & THƯ VIỆN SỬ DỤNG
Core Framework
Flutter SDK: ^3.10.1

Ngôn ngữ: Dart

Backend & Cơ Sở Dữ Liệu
Firebase Core: ^4.6.0

Cloud Firestore: ^6.2.0

Firebase Auth: ^6.3.0

Packages Hỗ Trợ
flutter_riverpod: ^2.5.1 (Quản lý State)

uuid: ^4.3.3 (Định danh dữ liệu độc nhất)

cached_network_image: ^3.4.1 (Quản lý hình ảnh)

shimmer: ^3.0.0 (Hiệu ứng UI)

CẤU TRÚC THƯ MỤC CHÍNH
Dự án được tổ chức theo mô hình phân lớp rõ ràng nhằm dễ dàng mở rộng và bảo trì:

Plaintext
lib/
├── core/                   # Cấu hình lõi (Theme, Constants)
│   └── app_theme.dart      # Bộ quy chuẩn màu sắc, font chữ
├── models/                 # Lớp đối tượng dữ liệu
│   ├── ingredient.dart     # Model Nguyên liệu
│   └── recipe.dart         # Model Công thức
├── viewmodels/             # Khối xử lý Logic
│   ├── pantry_provider.dart  # Thuật toán Smart Pantry
│   └── recipe_provider.dart  # Xử lý luồng dữ liệu CRUD
├── views/                  # Giao diện người dùng (UI)
│   ├── home_page.dart        # Màn hình chính
│   ├── recipe_form_page.dart # Màn hình Thêm/Sửa công thức
│   └── smart_pantry_page.dart# Màn hình Tủ lạnh thông minh
├── widgets/                # Các thành phần tái sử dụng
└── main.dart               # Điểm khởi chạy ứng dụng
HƯỚNG DẪN CÀI ĐẶT & KHỞI CHẠY
Bước 1: Sao chép dự án về máy

Bash
git clone https://github.com/Tuanask4/RecipeApp_Tuan_Giap_1_2026.git
cd RecipeApp_Tuan_Giap_1_2026
Bước 2: Cài đặt các gói thư viện phụ thuộc

Bash
flutter pub get
Bước 3: Thiết lập Firebase

Tạo một dự án mới trên Firebase Console.

Kích hoạt Firestore Database.

Sử dụng Firebase CLI để tự động thiết lập liên kết:

Bash
dart pub global activate flutterfire_cli
flutterfire configure
Bước 4: Khởi chạy ứng dụng

Bash
flutter run
KIẾN TRÚC TỐI ƯU HÓA
Ngăn Chặn Rò Rỉ Bộ Nhớ (Memory Leak): Quản lý nghiêm ngặt vòng đời của các TextEditingController được tạo động trong RecipeFormPage. Đảm bảo giải phóng bộ nhớ (dispose) ngay khi người dùng xóa một trường nhập liệu hoặc đóng biểu mẫu.

Cập Nhật Dữ Liệu An Toàn: Sử dụng phương thức .set(data, SetOptions(merge: true)) của Firestore thay vì ghi đè toàn bộ tài liệu, đảm bảo tính toàn vẹn của dữ liệu trong môi trường nhiều người dùng.