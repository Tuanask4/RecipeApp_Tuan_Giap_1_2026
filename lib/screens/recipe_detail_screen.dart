// lib/screens/recipe_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/recipe_model.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  // Biến lưu trữ trạng thái "Đã mua" của các nguyên liệu
  late List<bool> _checkedIngredients;
  bool _isFavorite = false; // Trạng thái thả tim

  @override
  void initState() {
    super.initState();
    // Ban đầu, tạo một danh sách toàn 'false' (chưa tick) bằng với số lượng nguyên liệu
    _checkedIngredients = List<bool>.filled(widget.recipe.ingredients.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. SliverAppBar: Ảnh tràn viền có thể cuộn
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true, // Giữ thanh tiêu đề lại khi cuộn xuống dưới
            backgroundColor: Colors.orange,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.recipe.title, style: const TextStyle(shadows: [Shadow(color: Colors.black, blurRadius: 10)])),
              background: Image.network(
                widget.recipe.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.restaurant, size: 100),
              ),
            ),
          ),
          
          // 2. Phần nội dung cuộn bên dưới
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- QUICK STATS (Chỉ số nhanh) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatChip(Icons.schedule, '${widget.recipe.prepTime} Phút'),
                      _buildStatChip(Icons.assessment, widget.recipe.difficulty),
                      _buildStatChip(Icons.local_fire_department, 'Nóng hổi'),
                    ],
                  ),
                  const Divider(height: 40, thickness: 1),

                  // --- NGUYÊN LIỆU (Trải nghiệm đi chợ) ---
                  const Text('Nguyên liệu', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  // Dùng ListView.builder thu gọn (shrinkWrap) để lồng vào trong Column
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(), // Tắt cuộn của list con
                    itemCount: widget.recipe.ingredients.length,
                    itemBuilder: (context, index) {
                      final ingredient = widget.recipe.ingredients[index];
                      return CheckboxListTile(
                        activeColor: Colors.orange,
                        title: Text(
                          '${ingredient.quantity} ${ingredient.unit} ${ingredient.name}',
                          // Hiệu ứng gạch ngang chữ nếu đã tick
                          style: TextStyle(
                            decoration: _checkedIngredients[index] ? TextDecoration.lineThrough : TextDecoration.none,
                            color: _checkedIngredients[index] ? Colors.grey : Colors.black,
                          ),
                        ),
                        value: _checkedIngredients[index],
                        onChanged: (bool? value) {
                          setState(() {
                            _checkedIngredients[index] = value!;
                          });
                        },
                      );
                    },
                  ),
                  const Divider(height: 40, thickness: 1),

                  // --- CÁC BƯỚC THỰC HIỆN ---
                  const Text('Cách làm', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.recipe.steps.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange.shade100,
                          child: Text('${index + 1}', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(widget.recipe.steps[index]),
                      );
                    },
                  ),
                  const SizedBox(height: 80), // Chừa không gian cho nút FloatingActionButton
                ],
              ),
            ),
          ),
        ],
      ),

      // 3. Nút Call to Action lơ lửng
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          setState(() {
            _isFavorite = !_isFavorite; // Đảo trạng thái thả tim
          });
        },
        child: Icon(
          _isFavorite ? Icons.favorite : Icons.favorite_border,
          color: Colors.red,
        ),
      ),
    );
  }

  // Hàm phụ để vẽ các nút chức năng nhỏ (Chip) cho gọn code
  Widget _buildStatChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 20, color: Colors.orange),
      label: Text(label),
      backgroundColor: Colors.orange.shade50,
      side: BorderSide.none, // Bỏ viền cho đẹp
    );
  }
}