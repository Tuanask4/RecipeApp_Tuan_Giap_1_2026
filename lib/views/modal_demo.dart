// import 'package:flutter/material.dart';

// class ModalBottomSheetDemo extends StatefulWidget {
//   const ModalBottomSheetDemo({Key? key}) : super(key: key);

//   @override
//   State<ModalBottomSheetDemo> createState() => _ModalBottomSheetDemoState();
// }

// class _ModalBottomSheetDemoState extends State<ModalBottomSheetDemo> {
//   final List<String> _records = ['Bản ghi mẫu 1', 'Bản ghi mẫu 2'];
//   final TextEditingController _textController = TextEditingController();

//   // Hàm gọi Modal Popup
//   void _openAddRecordModal() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true, // Hỗ trợ đẩy giao diện lên khi bàn phím xuất hiện
//       builder: (BuildContext context) {
//         return Padding(
//           padding: EdgeInsets.only(
//             bottom: MediaQuery.of(context).viewInsets.bottom, // Tránh bị bàn phím che
//             left: 16, right: 16, top: 16,
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min, // Chỉ chiếm không gian tối thiểu cần thiết
//             children: [
//               const Text('Thêm Bản Ghi Mới', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               TextField(
//                 controller: _textController,
//                 decoration: const InputDecoration(labelText: 'Nhập tên bản ghi'),
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () {
//                   if (_textController.text.isNotEmpty) {
//                     // Cập nhật lại UI với bản ghi mới
//                     setState(() {
//                       _records.add(_textController.text);
//                     });
//                     _textController.clear();
//                     Navigator.pop(context); // Đóng Modal Popup
//                   }
//                 },
//                 child: const Text('Lưu & Đóng'),
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Demo Modal Popup')),
//       body: ListView.builder(
//         itemCount: _records.length,
//         itemBuilder: (context, index) {
//           return ListTile(
//             leading: const Icon(Icons.data_object),
//             title: Text(_records[index]),
//           );
//         },
//       ),
//       // Nút bấm góc dưới màn hình để gọi hàm showModalBottomSheet
//       floatingActionButton: FloatingActionButton(
//         onPressed: _openAddRecordModal,
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }