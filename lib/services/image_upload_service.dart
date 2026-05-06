import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadResult {
  final bool success;
  final String? downloadUrl;
  final String? errorMessage;

  const ImageUploadResult.ok(this.downloadUrl)
      : success = true,
        errorMessage = null;
  const ImageUploadResult.fail(this.errorMessage)
      : success = false,
        downloadUrl = null;
  const ImageUploadResult.cancelled()
      : success = false,
        downloadUrl = null,
        errorMessage = null; // null = người dùng tự hủy, không phải lỗi
}

class ImageUploadService {
  final _picker = ImagePicker();
  final _storage = FirebaseStorage.instance;

  // ===========================================================================
  // CHỌN ẢNH: Từ thư viện hoặc camera
  // ===========================================================================
  Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 80,   // Nén 80% — cân bằng chất lượng vs dung lượng
      maxWidth: 1200,     // Giới hạn kích thước để tiết kiệm Storage cost
      maxHeight: 1200,
    );
    if (picked == null) return null;
    return File(picked.path);
  }

  // ===========================================================================
  // UPLOAD: Lên Firebase Storage, trả về download URL
  // Path: recipe_images/{uid}/{timestamp}.jpg
  // ===========================================================================
  Future<ImageUploadResult> uploadRecipeImage(File imageFile) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return const ImageUploadResult.fail('Chưa đăng nhập.');

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('recipe_images/$uid/$fileName');

      // Upload với metadata để browser biết content type
      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return ImageUploadResult.ok(downloadUrl);
    } on FirebaseException catch (e) {
      return ImageUploadResult.fail('Lỗi upload: ${e.message}');
    } catch (e) {
      return ImageUploadResult.fail('Có lỗi xảy ra. Thử lại nhé!');
    }
  }

  // ===========================================================================
  // PICK + UPLOAD trong 1 bước — dùng trong RecipeFormPage
  // ===========================================================================
  Future<ImageUploadResult> pickAndUpload({
    ImageSource source = ImageSource.gallery,
  }) async {
    final file = await pickImage(source: source);
    if (file == null) return const ImageUploadResult.cancelled();
    return uploadRecipeImage(file);
  }
}
