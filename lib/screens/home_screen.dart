// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../widgets/recipe_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thực đơn của Tuấn & Giáp'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      // ListView.builder giúp tạo danh sách cuộn mượt mà
      body: ListView.builder(
        itemCount: dummyRecipes.length,
        itemBuilder: (context, index) {
          // Lấy từng món ăn ra và truyền vào RecipeCard
          final recipe = dummyRecipes[index];
          return RecipeCard(recipe: recipe);
        },
      ),
    );
  }
}