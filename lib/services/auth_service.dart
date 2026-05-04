import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Kết quả trả về sau mỗi thao tác Auth — tránh dùng exception để xử lý UI
class AuthResult {
  final bool success;
  final String? errorMessage;

  const AuthResult.ok() : success = true, errorMessage = null;
  const AuthResult.fail(this.errorMessage) : success = false;
}

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _googleSignIn = GoogleSignIn();

  // Stream để MainLayout lắng nghe trạng thái đăng nhập realtime
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // ===========================================================================
  // ĐĂNG KÝ bằng Email + Password
  // ===========================================================================
  Future<AuthResult> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Cập nhật tên hiển thị ngay sau khi tạo tài khoản
      await credential.user?.updateDisplayName(displayName.trim());

      // Tạo document người dùng trên Firestore để lưu thêm thông tin
      await _createUserDocument(
        uid: credential.user!.uid,
        displayName: displayName.trim(),
        email: email.trim(),
        photoUrl: null,
      );

      return const AuthResult.ok();
    } on FirebaseAuthException catch (e) {
      return AuthResult.fail(_mapErrorCode(e.code));
    } catch (e) {
      return AuthResult.fail('Có lỗi xảy ra. Vui lòng thử lại.');
    }
  }

  // ===========================================================================
  // ĐĂNG NHẬP bằng Email + Password
  // ===========================================================================
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return const AuthResult.ok();
    } on FirebaseAuthException catch (e) {
      return AuthResult.fail(_mapErrorCode(e.code));
    } catch (e) {
      return AuthResult.fail('Có lỗi xảy ra. Vui lòng thử lại.');
    }
  }

  // ===========================================================================
  // ĐĂNG NHẬP bằng Google
  // ===========================================================================
  Future<AuthResult> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      // Người dùng bấm nút back trên màn hình chọn tài khoản Google
      if (googleUser == null) return const AuthResult.fail('Đã hủy đăng nhập.');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      // Chỉ tạo document lần đầu — nếu đã có thì bỏ qua
      final docRef = _firestore.collection('users').doc(user.uid);
      final doc = await docRef.get();
      if (!doc.exists) {
        await _createUserDocument(
          uid: user.uid,
          displayName: user.displayName ?? 'Người dùng',
          email: user.email ?? '',
          photoUrl: user.photoURL,
        );
      }

      return const AuthResult.ok();
    } on FirebaseAuthException catch (e) {
      return AuthResult.fail(_mapErrorCode(e.code));
    } catch (e) {
      return AuthResult.fail('Đăng nhập Google thất bại. Thử lại nhé!');
    }
  }

  // ===========================================================================
  // ĐĂNG XUẤT
  // ===========================================================================
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // ===========================================================================
  // HELPER: Tạo document user trên Firestore
  // ===========================================================================
  Future<void> _createUserDocument({
    required String uid,
    required String displayName,
    required String email,
    required String? photoUrl,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'recipesCount': 0,
    });
  }

  // ===========================================================================
  // HELPER: Dịch mã lỗi Firebase sang tiếng Việt thân thiện
  // ===========================================================================
  String _mapErrorCode(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Email này đã được dùng cho tài khoản khác.';
      case 'invalid-email':
        return 'Email không đúng định dạng.';
      case 'weak-password':
        return 'Mật khẩu quá yếu. Dùng ít nhất 6 ký tự.';
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email hoặc mật khẩu không đúng.';
      case 'too-many-requests':
        return 'Quá nhiều lần thử. Vui lòng đợi vài phút.';
      case 'network-request-failed':
        return 'Mất kết nối mạng. Kiểm tra Wifi hoặc 4G nhé.';
      default:
        return 'Có lỗi xảy ra ($code). Thử lại nhé!';
    }
  }
}
