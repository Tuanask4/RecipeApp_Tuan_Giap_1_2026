# 🍳 Smart Recipe App - Nền tảng Chia sẻ & Khám phá Ẩm thực 

Một ứng dụng di động đa nền tảng được xây dựng nhằm kết nối cộng đồng yêu ẩm thực. Không chỉ dừng lại ở việc chia sẻ công thức, ứng dụng còn tích hợp tính năng **"Tủ lạnh thông minh" (Smart Pantry)**, giúp người dùng tự động đối chiếu và tìm ra món ăn phù hợp nhất dựa trên nguyên liệu đang có sẵn, tối ưu hóa chống lãng phí thực phẩm.

---

## 👨‍💻 Đội ngũ phát triển (Phenikaa University)
* **Nguyễn Minh Tuấn** (MSSV: 22010478)
* **Nguyễn Công Giáp** (MSSV: 22010369)
* Link demo: "https://youtu.be/nkCC6EIa-zA"
---

## 🛠 Công nghệ sử dụng (Tech Stack)

Dự án tuân thủ nghiêm ngặt **Kiến trúc MVVM** nhằm đảm bảo tính mở rộng và khả năng bảo trì mã nguồn.

| Thành phần | Công nghệ / Package | Mục đích sử dụng trong dự án |
| :--- | :--- | :--- |
| **Framework** | `Flutter` | Phát triển giao diện đa nền tảng (Android/iOS). |
| **State Management** | `flutter_riverpod` | Quản lý trạng thái tập trung, tiêm phụ thuộc (Dependency Injection) và luồng dữ liệu thời gian thực. |
| **Database** | `cloud_firestore` | Cơ sở dữ liệu NoSQL (Realtime sync). |
| **Authentication** | `firebase_auth`, `google_sign_in`| Xác thực danh tính người dùng (Email/Password & Google). |
| **Storage (API)** | `http`, ImgBB API | Xử lý upload ảnh thông qua RESTful API để tối ưu chi phí lưu trữ hạ tầng. |
| **Tiện ích** | `image_picker`, `cached_network_image` | Truy xuất tệp tin cục bộ và tối ưu hóa bộ nhớ đệm (cache) cho hình ảnh mạng. |

---
## 🎯 Câu chuyện người dùng (User Stories)
Dự án được phân tích và phát triển dựa trên các nhu cầu thực tế của người dùng:

* **US01a - Quản lý Công thức:** "Là một người yêu nấu ăn, tôi muốn tạo công thức của riêng mình để có thể lưu trữ và chia sẻ với cộng đồng."
* **US01b - Quản lý Công thức:** "Là một người yêu nấu ăn, tôi muốn tải hình ảnh món ăn của riêng mình để có thể lưu trữ và chia sẻ với cộng đồng."
* **US01c - Quản lý Công thức:** "Là một người yêu nấu ăn, tôi muốn tạo chỉnh sửa công thức nấu ăn của riêng mình để có thể lưu trữ và chia sẻ với cộng đồng."
* **US02 - Tủ lạnh thông minh (Smart Pantry):** "Là một sinh viên hoặc người đi làm bận rộn, tôi muốn đánh dấu những nguyên liệu tôi đang có sẵn trong tủ lạnh, để hệ thống tự động gợi ý những món tôi có thể nấu ngay lập tức mà không cần đi siêu thị."
* **US03 - Tìm kiếm & Khám phá:** "Là một người dùng đang tìm cảm hứng, tôi muốn tìm kiếm công thức theo tên hoặc từ khóa, để nhanh chóng có được hướng dẫn chi tiết về nguyên liệu và các bước làm."
* **US04 - Tùy chỉnh khẩu phần:** "Là người nấu ăn cho gia đình, tôi muốn thay đổi số lượng người ăn trên ứng dụng để định lượng nguyên liệu tự động nhân lên tương ứng mà tôi không cần phải tự tính nhẩm."

---

## 🎨 Thiết kế Giao diện (UI/UX Mockup)
Giao diện ứng dụng được thiết kế theo ngôn ngữ hiện đại, tối giản và tập trung vào hình ảnh trực quan của món ăn.

Link Figma: https://www.figma.com/design/MBysYvniPYg7E4CYpX2RDn/Flow-of-work?node-id=0-1&t=SVP39zctsGJfLW6q-1

---

## 🏗 Kiến trúc Hệ thống (System Architecture)

Hệ thống được thiết kế xoay quanh hai thực thể cốt lõi là `Recipe` (Công thức) và `Ingredient` (Nguyên liệu), tận dụng mô hình Embed Document của NoSQL để tăng tốc độ truy vấn.

> **[!!! CHÈN SƠ ĐỒ CẤU TRÚC (CLASS DIAGRAM) VÀO ĐÂY !!!]**
*(Giải thích: Sơ đồ trên thể hiện mối quan hệ cấu thành (Composition) giữa Recipe và Ingredient, kèm theo các phương thức xử lý logic nghiệp vụ ngay tại tầng Model).*

---

## 🚀 Các tính năng cốt lõi & Luồng hoạt động

### 1. Xác thực người dùng (Authentication)
Quản lý phiên đăng nhập an toàn, sử dụng `AuthGate` để tự động điều hướng luồng người dùng (Navigation) dựa trên trạng thái (State) từ Firebase.

<img width="1595" height="846" alt="Đk, ĐN" src="https://github.com/user-attachments/assets/1cd713d8-2529-4245-92f4-4cdcf564db51" />


### 2. Khám phá & Lọc tìm kiếm thời gian thực (Discovery & Realtime Search)
Thuật toán tìm kiếm được tối ưu hóa bằng cách tách chuỗi (tokenization) và lưu trữ dưới dạng mảng `searchKeywords` trên Firestore. Điều này giúp truy vấn dữ liệu lớn mà không gây quá tải cho bộ nhớ thiết bị.

<img width="682" height="852" alt="lấy dữ liệu" src="https://github.com/user-attachments/assets/7ea675b9-c401-40a1-b3bc-374f88c02886" />


### 3. Tủ lạnh thông minh (Smart Pantry) - *[Tính năng nổi bật]*
Giải quyết bài toán "Hôm nay ăn gì?". Thuật toán thực hiện tính toán độ tương đồng (Matching Percentage) giữa tập hợp nguyên liệu có sẵn trong `PantryNotifier` và toàn bộ cơ sở dữ liệu công thức.

<img width="381" height="882" alt="smart pantry" src="https://github.com/user-attachments/assets/68a3c37c-7b0a-438d-aa87-241a79dbe37e" />


### 4. Quản lý Khẩu phần ăn Động (Dynamic Servings)
Sử dụng công thức toán học tỷ lệ thuận để tự động tính toán lại định lượng nguyên liệu ngay trên giao diện (UI) mà không cần thực hiện thêm luồng đọc (Read request) từ Database.

<img width="557" height="892" alt="quản lý khẩu phần ăn" src="https://github.com/user-attachments/assets/048f56fd-91d6-4a57-b205-bd7c4af8677d" />


### 5. Tạo mới & Upload công thức (Creation & Upload)
Luồng dữ liệu được tách biệt rõ ràng: Hình ảnh được mã hóa Base64 và đẩy sang máy chủ ImgBB qua HTTP POST; sau khi nhận URL trả về, toàn bộ chuỗi dữ liệu văn bản mới được ghi nhận vào Cloud Firestore.

<img width="1357" height="847" alt="upload CTNA" src="https://github.com/user-attachments/assets/4e9cde44-1e7b-4bac-ad15-bbcf6ec9f295" />

---

## 🧪 Kiểm thử (Testing)
Dự án áp dụng phương pháp kiểm thử đơn vị (Unit Test) cho các logic nghiệp vụ phức tạp ở tầng State Management, điển hình là bộ kiểm thử kịch bản thêm/xóa/đặt lại dữ liệu của `PantryNotifier` nhằm đảm bảo tính toàn vẹn của trạng thái bộ nhớ.

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/05e30e97-d596-425c-ae13-8e46470dda91" />


---

