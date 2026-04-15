import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe.dart';
import 'dart:async';

// =======================================================================
// 1. BỘ XỬ LÝ DEBOUNCE (CHỐNG SPAM SERVER KHI TÌM KIẾM)
// =======================================================================
class SearchNotifier extends StateNotifier<String> {
  SearchNotifier() : super('');
  Timer? _debounce;

  // Hàm này sẽ được gọi mỗi khi người dùng gõ 1 ký tự
  void onTextChanged(String text) {
    // Nếu đang đếm ngược mà người dùng gõ tiếp -> Hủy bộ đếm cũ
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Đặt lại bộ đếm 500ms (0.5 giây).
    // Chỉ khi nào người dùng dừng gõ 0.5s thì mới cập nhật từ khóa để gọi Firebase
    _debounce = Timer(const Duration(milliseconds: 500), () {
      state = text;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

// Khởi tạo Provider cho bộ tìm kiếm
final searchQueryProvider = StateNotifierProvider<SearchNotifier, String>((
  ref,
) {
  return SearchNotifier();
});

// =======================================================================
// 2. STREAM PROVIDER: LẮNG NGHE FIREBASE THỜI GIAN THỰC
// =======================================================================
final recipeListProvider = StreamProvider<List<Recipe>>((ref) {
  // Lấy từ khóa tìm kiếm hiện tại
  final query = ref.watch(searchQueryProvider);
  var collection = FirebaseFirestore.instance.collection('recipes');

  if (query.isEmpty) {
    // KỊCH BẢN 1: KHÔNG TÌM KIẾM -> Tải 20 món mới nhất (Tối ưu chi phí)
    return collection.limit(20).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Recipe.fromMap(doc.data(), doc.id))
          .toList();
    });
  } else {
    // KỊCH BẢN 2: CÓ TÌM KIẾM -> Lọc trực tiếp trên Firebase
    // Kỹ thuật gộp điều kiện của Firebase để tìm các món bắt đầu bằng từ khóa
    return collection
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThan: '$query\uf8ff')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Recipe.fromMap(doc.data(), doc.id))
              .toList();
        });
  }
});

