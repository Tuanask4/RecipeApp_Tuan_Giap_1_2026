import 'package:flutter_riverpod/flutter_riverpod.dart';

// Định nghĩa các trạng thái của form
enum ContactFormState { idle, loading, success, error }

class ContactFormNotifier extends StateNotifier<ContactFormState> {
  ContactFormNotifier() : super(ContactFormState.idle);

  // Hàm xử lý logic submit
  Future<void> submitContact(String name, String email, String message) async {
    if (name.trim().isEmpty || email.trim().isEmpty) {
      // Có thể set state error ở đây nếu muốn hiện câu thông báo lỗi
      return; 
    }

    state = ContactFormState.loading; // Báo cho UI hiện vòng xoay hoặc vô hiệu hóa nút bấm

    // Giả lập gọi API mất 2 giây (Sau này em nối Firebase Functions hoặc API backend vào đây)
    await Future.delayed(const Duration(seconds: 2));

    state = ContactFormState.success; // Báo UI hiện dấu ✅ thành công

    // Tự động reset form về trạng thái ban đầu sau 3 giây
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      state = ContactFormState.idle;
    }
  }
}

// Khởi tạo Provider tự động hủy khi không dùng đến (autoDispose)
final contactFormProvider = StateNotifierProvider.autoDispose<ContactFormNotifier, ContactFormState>((ref) {
  return ContactFormNotifier();
});