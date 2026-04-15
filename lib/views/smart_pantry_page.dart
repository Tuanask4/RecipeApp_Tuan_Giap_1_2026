import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_theme.dart';
import '../viewmodels/pantry_provider.dart';
import '../widgets/animated_scale_card.dart';
import 'recipe_detail_page.dart';

// Đổi sang ConsumerStatefulWidget để quản lý text tìm kiếm nguyên liệu
class SmartPantryPage extends ConsumerStatefulWidget {
  const SmartPantryPage({super.key});

  @override
  ConsumerState<SmartPantryPage> createState() => _SmartPantryPageState();
}

class _SmartPantryPageState extends ConsumerState<SmartPantryPage> {
  // Biến lưu trữ từ khóa tìm kiếm nguyên liệu
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final allIngredients = ref.watch(allIngredientsProvider);
    final selectedIngredients = ref.watch(selectedIngredientsProvider);
    final suggestedRecipes = ref.watch(smartPantryProvider);

    // LOGIC TÌM KIẾM: Lọc danh sách nguyên liệu dựa trên từ khóa người dùng gõ
    final filteredIngredients = allIngredients.where((ingredient) {
      return ingredient.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Tủ Lạnh Thông Minh',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- KHO NGUYÊN LIỆU (CÓ TÌM KIẾM) ---
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bạn đang có gì trong bếp?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // THANH TÌM KIẾM NGUYÊN LIỆU
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value; // Cập nhật từ khóa mỗi khi gõ
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Tìm nhanh nguyên liệu (VD: Trứng, Bò...)',
                    prefixIcon: const Icon(Icons.search, color: Colors.orange),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // HIỂN THỊ CÁC NGUYÊN LIỆU ĐÃ ĐƯỢC LỌC
                filteredIngredients.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Không tìm thấy nguyên liệu này',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    : Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: filteredIngredients.map((ingredientName) {
                          final isSelected = selectedIngredients.contains(
                            ingredientName,
                          );
                          return FilterChip(
                            label: Text(ingredientName),
                            selected: isSelected,
                            selectedColor: Colors.orange[100],
                            checkmarkColor: Colors.orange,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.orange[800]
                                  : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            onSelected: (bool selected) {
                              final notifier = ref.read(
                                selectedIngredientsProvider.notifier,
                              );
                              final currentState = notifier.state;
                              if (selected) {
                                notifier.state = {
                                  ...currentState,
                                  ingredientName,
                                };
                              } else {
                                notifier.state = {...currentState}
                                  ..remove(ingredientName);
                              }
                            },
                          );
                        }).toList(),
                      ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // --- KẾT QUẢ GỢI Ý (Giữ nguyên) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Món ăn có thể làm',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${suggestedRecipes.length} kết quả',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: suggestedRecipes.isEmpty
                ? Center(
                    child: Text(
                      'Hãy chọn nguyên liệu để xem gợi ý nhé!',
                      style: TextStyle(color: Colors.grey[500], fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: suggestedRecipes.length,
                    itemBuilder: (context, index) {
                      final match = suggestedRecipes[index];
                      final recipe = match.recipe;
                      final percent = (match.matchPercentage * 100).toInt();

                      return AnimatedScaleCard(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RecipeDetailPage(recipe: recipe),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(16),
                                ),
                                child: Image.network(
                                  recipe.imageUrl,
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        recipe.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: LinearProgressIndicator(
                                                value: match.matchPercentage,
                                                backgroundColor:
                                                    Colors.grey[200],
                                                color: percent == 100
                                                    ? Colors.green
                                                    : Colors.orange,
                                                minHeight: 8,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            '$percent%',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: percent == 100
                                                  ? Colors.green
                                                  : Colors.orange,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Có ${match.matchedCount}/${match.totalCount} nguyên liệu',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
