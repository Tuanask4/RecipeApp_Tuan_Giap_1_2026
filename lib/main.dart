// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'core/app_theme.dart';
// import 'views/main_layout.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   runApp(const ProviderScope(child: MyApp()));
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ProviderScope(
//       child: MaterialApp(
//         title: 'Ứng dụng công thức nấu ăn',
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//           useMaterial3: true,
//           primarySwatch: Colors.orange,
//           primaryColor: AppTheme.primary,
//           scaffoldBackgroundColor: AppTheme.background,
//         ),
//         home: const MainLayout(),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'models/recipe.dart';
import 'models/ingredient.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      home: const Exercise2Screen(), 
    );
  }
}

// ========================================================================
// BÀI THỰC HÀNH 2
// ========================================================================
class Exercise2Screen extends StatelessWidget {
  const Exercise2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    // ---------------------------------------------------------
    // YÊU CẦU 1: Khai báo biến
    // ---------------------------------------------------------
    String appName = "Smart Recipe & Pantry"; 
    int totalUsers = 1500; 
    bool isServerOnline = true; 

    // ---------------------------------------------------------
    // YÊU CẦU 2: Collections (List String, Map)
    // ---------------------------------------------------------
    List<String> userTags = ['Ăn kiêng', 'Tăng cơ', 'Nấu nhanh'];

    Map<String, dynamic> appConfig = {
      'Phiên bản': '1.0.2',
      'Ngôn ngữ': 'Tiếng Việt',
      'Chế độ tối (Dark Mode)': false,
    };

    // ---------------------------------------------------------
    // YÊU CẦU 4: TẠO LIST OBJECT (Recipe & Ingredient)
    // ---------------------------------------------------------
    List<Recipe> myRecipes = [
      Recipe(
        id: 'r1',
        title: 'Cơm chiên Dương Châu',
        imageUrl: '',
        durationMinutes: 15,
        difficulty: Difficulty.easy,
        defaultServings: 2,
        ingredients: [
          Ingredient(id: 'i1', name: 'Cơm nguội', amount: 2, unit: 'chén'),
          Ingredient(id: 'i2', name: 'Trứng gà', amount: 2, unit: 'quả'),
        ],
        steps: ['Đánh trứng', 'Chiên cơm', 'Trộn đều'],
      ),
      Recipe(
        id: 'r2',
        title: 'Bò Lúc Lắc Khoai Tây',
        imageUrl: '',
        durationMinutes: 30,
        difficulty: Difficulty.medium,
        defaultServings: 4,
        ingredients: [
          Ingredient(id: 'i3', name: 'Thịt bò', amount: 500, unit: 'gram'),
          Ingredient(id: 'i4', name: 'Khoai tây', amount: 3, unit: 'củ'),
        ],
        steps: ['Thái vuông thịt bò', 'Chiên khoai', 'Áp chảo thịt bò'],
      ),
    ];

    // ---------------------------------------------------------
    // YÊU CẦU 3 & 4: Hiển thị giao diện
    // ---------------------------------------------------------
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thực Hành 2: List Object', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Hiển thị Biến & Map ---
            const Text('THÔNG TIN ỨNG DỤNG', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
            Text('📱 Tên App: $appName ($totalUsers users)', style: const TextStyle(fontSize: 16)),
            Text('🟢 Trạng thái Server: ${isServerOnline ? "Hoạt động" : "Bảo trì"}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            ...appConfig.entries.map((e) => Row(
              children: [
                Text('- ${e.key}: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('${e.value}'),
              ],
            )),
            
            const Divider(height: 30, thickness: 1),

            // --- YÊU CẦU 4: Hiển thị List<Recipe> ---
            const Text('🍲 DANH SÁCH MÓN ĂN (OBJECT THẬT)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
            const SizedBox(height: 12),
            ...myRecipes.map((recipe) {
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tên món và độ khó
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(recipe.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Chip(
                            label: Text(recipe.difficulty.name.toUpperCase()),
                            backgroundColor: recipe.difficulty == Difficulty.easy ? Colors.green[100] : Colors.orange[100],
                          )
                        ],
                      ),
                      Text('⏳ Thời gian: ${recipe.durationMinutes} phút | 👤 Khẩu phần: ${recipe.defaultServings} người'),
                      const Divider(),
                      
                      // Hiển thị danh sách Ingredient Nằm TRONG Object Recipe
                      const Text('Nguyên liệu:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ...recipe.ingredients.map((ing) => Text(' • ${ing.name}: ${ing.amount} ${ing.unit}')),
                      
                      const SizedBox(height: 8),
                      // Hiển thị danh sách các bước
                      const Text('Các bước làm:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ...recipe.steps.asMap().entries.map((step) => Text(' ${step.key + 1}. ${step.value}')),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}