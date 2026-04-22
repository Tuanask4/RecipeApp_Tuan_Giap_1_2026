<div align="center">

# Recipe App

**Ứng dụng Quản lý Công thức & Tủ lạnh Thông minh**

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=flat-square&logo=firebase&logoColor=black)
![Riverpod](https://img.shields.io/badge/Riverpod-1A2B3C?style=flat-square&logo=dart&logoColor=white)

<p>
  <i>Xây dựng trải nghiệm nấu nướng thông minh, tiện lợi và tối ưu hóa hiệu năng.</i>
</p>

</div>

---

## Tính năng nổi bật

-  **Real-time CRUD:** Thêm, sửa, xóa công thức với dữ liệu được đồng bộ ngay lập tức nhờ sức mạnh của Cloud Firestore.
-  **Debounced Search:** Công cụ tìm kiếm tối ưu, tự động trì hoãn 0.5s khi gõ để tiết kiệm băng thông và giảm tải cho Server.
-  **Smart Pantry (Tủ lạnh thông minh):** Thuật toán tự động đối chiếu nguyên liệu bạn đang có với cơ sở dữ liệu để đưa ra các gợi ý món ăn có tỷ lệ trùng khớp cao nhất.
- 🛠 **Dynamic Form:** Hệ thống biểu mẫu nhập liệu linh hoạt, cho phép thêm không giới hạn nguyên liệu và các bước làm.

---

## Công nghệ & Kiến trúc

Dự án được phân lớp rõ ràng (MVVM) nhằm đảm bảo tính dễ bảo trì và mở rộng:

- **Framework:** Flutter (Dart)
- **State Management:** Riverpod
- **Backend:** Firebase (Core, Firestore, Auth)
- **Utilities:** `uuid` (định danh), `cached_network_image` (tải ảnh), `shimmer` (hiệu ứng skeleton).

<details>
<summary><b>📂 Xem cấu trúc thư mục</b></summary>

```text
lib/
├── core/           # Cấu hình lõi (AppTheme, màu sắc, font)
├── models/         # Các lớp đối tượng dữ liệu (Recipe, Ingredient)
├── viewmodels/     # Logic xử lý (PantryProvider, RecipeProvider)
├── views/          # Màn hình giao diện (UI)
└── widgets/        # Thành phần giao diện tái sử dụng (Components)
