import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/app_theme.dart';
import 'viewmodels/auth_provider.dart';
import 'views/auth_page.dart';
import 'views/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}

// ===========================================================================
// AUTH GATE: Lắng nghe authStateProvider, tự chuyển màn hình khi login/logout
// Không cần Navigator.push thủ công ở bất kỳ đâu
// ===========================================================================
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      // Đang kiểm tra trạng thái Auth lần đầu (cold start)
      loading: () => const Scaffold(
        backgroundColor: Color(0xFFFAFAFA),
        body: Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
      ),

      // Lỗi Firebase (hiếm gặp)
      error: (_, __) => const AuthPage(),

      data: (user) {
        if (user != null) return const MainLayout(); // Đã đăng nhập → vào app
        return const AuthPage();                      // Chưa đăng nhập → Auth
      },
    );
  }
}
