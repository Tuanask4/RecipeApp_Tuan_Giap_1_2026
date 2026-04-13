// flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8080
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'views/main_layout.dart'; // Import màn hình Home

void main() {
  // Bọc toàn bộ app bằng ProviderScope để kích hoạt State Management
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ứng dụng công thức nấu ăn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const MainLayout(),
    );
  }
}
