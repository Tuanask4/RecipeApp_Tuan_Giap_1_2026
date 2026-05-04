import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

// ===========================================================================
// SINGLETON: Một AuthService duy nhất cho toàn app
// ===========================================================================
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// ===========================================================================
// STREAM PROVIDER: Lắng nghe Firebase Auth thay đổi realtime
// Khi user đăng nhập / đăng xuất -> stream này emit -> UI tự rebuild
// ===========================================================================
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// ===========================================================================
// CURRENT USER: Lấy user hiện tại tiện dụng ở bất cứ đâu
// ===========================================================================
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});
