// import 'package:flutter/material.dart';

// // ==========================================
// // YÊU CẦU 1: LỚP GENERICS CÓ PHƯƠNG THỨC CRUD
// // ==========================================

// abstract class BaseModel {
//   String get id;
// }

// // Lớp Generic CRUD tổng quát cho mọi đối tượng T kế thừa BaseModel
// class GenericCRUD<T extends BaseModel> {
//   final Map<String, T> _storage = {};

//   // Create
//   void create(T item) {
//     _storage[item.id] = item;
//   }

//   // Read
//   T? read(String id) {
//     return _storage[id];
//   }

//   // Update
//   void update(T item) {
//     if (_storage.containsKey(item.id)) {
//       _storage[item.id] = item;
//     }
//   }

//   // Delete
//   void delete(String id) {
//     _storage.remove(id);
//   }

//   // Get All
//   List<T> getAll() {
//     return _storage.values.toList();
//   }
// }

// // ==========================================
// // YÊU CẦU 2: THỰC HIỆN 02 ĐỐI TƯỢNG MỚI
// // ==========================================

// // Đối tượng 1: Dụng cụ nhà bếp (Appliance)
// class Appliance implements BaseModel {
//   @override
//   final String id;
//   final String name;
//   final double price;
//   final bool isElectric;

//   Appliance({
//     required this.id,
//     required this.name,
//     required this.price,
//     required this.isElectric,
//   });

//   // Phương thức hoạt động riêng: Tính giá sau khi giảm (trả về double)
//   double getDiscountedPrice(double discountPercent) {
//     return price - (price * discountPercent / 100);
//   }
// }

// // Đối tượng 2: Đánh giá món ăn (Review)
// class Review implements BaseModel {
//   @override
//   final String id;
//   final String author;
//   final int rating; // Thang điểm 1-5
//   final String content;

//   Review({
//     required this.id,
//     required this.author,
//     required this.rating,
//     required this.content,
//   });

//   // Phương thức hoạt động riêng: Phân tích cảm xúc đánh giá (trả về String)
//   String analyzeSentiment() {
//     if (rating >= 4) return "Tích cực 😊";
//     if (rating == 3) return "Bình thường 😐";
//     return "Tiêu cực 😞";
//   }
// }

// // ==========================================
// // YÊU CẦU 3: FRONTEND ĐƠN GIẢN HIỂN THỊ DỮ LIỆU
// // ==========================================

// class GenericsDemoPage extends StatefulWidget {
//   const GenericsDemoPage({Key? key}) : super(key: key);

//   @override
//   State<GenericsDemoPage> createState() => _GenericsDemoPageState();
// }

// class _GenericsDemoPageState extends State<GenericsDemoPage> {
//   // Khởi tạo 2 CRUD Controllers cho 2 kiểu dữ liệu khác nhau
//   final GenericCRUD<Appliance> applianceCRUD = GenericCRUD<Appliance>();
//   final GenericCRUD<Review> reviewCRUD = GenericCRUD<Review>();

//   @override
//   void initState() {
//     super.initState();
//     // Khởi tạo dữ liệu mẫu (Create)
//     applianceCRUD.create(
//       Appliance(id: 'A1', name: 'Lò vi sóng', price: 1500000, isElectric: true),
//     );
//     applianceCRUD.create(
//       Appliance(
//         id: 'A2',
//         name: 'Chảo chống dính',
//         price: 350000,
//         isElectric: false,
//       ),
//     );

//     reviewCRUD.create(
//       Review(
//         id: 'R1',
//         author: 'Minh Tuấn',
//         rating: 5,
//         content: 'Món ăn rất ngon',
//       ),
//     );
//     reviewCRUD.create(
//       Review(
//         id: 'R2',
//         author: 'Người dùng ẩn danh',
//         rating: 2,
//         content: 'Hơi mặn, cần điều chỉnh gia vị',
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final appliances = applianceCRUD.getAll();
//     final reviews = reviewCRUD.getAll();

//     return Scaffold(
//       appBar: AppBar(title: const Text('Generics CRUD Demo')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               '1. Danh sách dụng cụ',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             // Hiển thị Appliance - Trả về giá trị tính toán tiền tệ
//             ...appliances
//                 .map(
//                   (app) => Card(
//                     color: Colors.blue.shade50,
//                     child: ListTile(
//                       title: Text(app.name),
//                       subtitle: Text(
//                         'Giá gốc: ${app.price} VNĐ\nThuộc tính điện: ${app.isElectric ? "Có" : "Không"}',
//                       ),
//                       trailing: Text(
//                         // Gọi phương thức riêng của Appliance
//                         'Giảm 10%: ${app.getDiscountedPrice(10)} VNĐ',
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.blue,
//                         ),
//                       ),
//                     ),
//                   ),
//                 )
//                 .toList(),

//             const Divider(height: 40, thickness: 2),

//             const Text(
//               '2. Danh sách đánh giá',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             // Hiển thị Review
//             ...reviews
//                 .map(
//                   (rev) => Card(
//                     color: Colors.green.shade50,
//                     child: ListTile(
//                       title: Text('${rev.author} - ${rev.rating} Sao'),
//                       subtitle: Text('Nội dung: ${rev.content}'),
//                       trailing: Chip(
//                         // Gọi phương thức riêng của Review
//                         label: Text(rev.analyzeSentiment()),
//                         backgroundColor: rev.rating >= 4
//                             ? Colors.green.shade200
//                             : Colors.red.shade200,
//                       ),
//                     ),
//                   ),
//                 )
//                 .toList(),
//           ],
//         ),
//       ),
//     );
//   }
// }
