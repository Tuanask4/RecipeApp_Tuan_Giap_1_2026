import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ImageUploadService {
  final String _apiKey = 'c3363fd59745cbd9dca650a941e3a6a7';

  Future<String?> uploadRecipeImage(XFile imageFile, String userId) async {
    try {
      // 1. Đọc file ảnh dưới dạng bytes và mã hóa sang chuỗi Base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // 2. Gói hàng và bắn API (POST request) sang máy chủ ImgBB
      final uri = Uri.parse('https://api.imgbb.com/1/upload');
      final response = await http.post(
        uri,
        body: {'key': _apiKey, 'image': base64Image},
      );

      // 3. Xử lý kết quả trả về
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Trích xuất thành công đường link URL ảnh trực tiếp
        final imageUrl = jsonResponse['data']['url'];
        print('Upload ảnh thành công: $imageUrl');
        return imageUrl;
      } else {
        print('ImgBB từ chối tải ảnh: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Lỗi gọi API upload: $e');
      return null;
    }
  }
}
