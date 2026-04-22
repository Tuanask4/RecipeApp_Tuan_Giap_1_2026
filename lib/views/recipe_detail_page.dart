import 'package:flutter/material.dart';
import '../models/recipe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/app_theme.dart';
import '../widgets/app_cached_image.dart';
import 'recipe_form_page.dart';

class RecipeDetailPage extends StatefulWidget {
  final Recipe recipe;
  const RecipeDetailPage({super.key, required this.recipe});

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  late int _currentServings;
  final Set<String> _checkedIngredients = {};
  final Set<int> _completedSteps = {};

  @override
  void initState() {
    super.initState();
    _currentServings = widget.recipe.defaultServings;
  }

  // Hàm xử lý Xóa với Hộp thoại xác nhận
  Future<void> _confirmDelete(BuildContext context, Recipe recipe) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Xóa công thức?', style: AppTheme.heading2),
        content: Text(
          'Bạn có chắc chắn muốn xóa "${recipe.title}" không? Hành động này không thể hoàn tác.',
          style: AppTheme.bodyText,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusM),
        actions: [
          IconButton(
             icon: Container(
               padding: const EdgeInsets.all(8),
               decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
               child: const Icon(Icons.edit, color: Colors.white, size: 20),
             ),
             onPressed: () {
               Navigator.push(
                 context,
                 MaterialPageRoute(
                   // TRUYỀN DỮ LIỆU CŨ SANG ĐỂ FORM HIỂN THỊ
                   builder: (context) => RecipeFormPage(existingRecipe: widget.recipe),
                 ),
               );
             },
           ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Hủy',
              style: TextStyle(color: AppTheme.textLight),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Xóa ngay',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await FirebaseFirestore.instance
            .collection('recipes')
            .doc(recipe.id)
            .delete();
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã xóa thành công "${recipe.title}"'),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi xóa: $e'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double multiplier = _currentServings / widget.recipe.defaultServings;

    return Scaffold(
      backgroundColor: AppTheme.background, // ĐỒNG BỘ THEME
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverAppBar(
            expandedHeight: 340.0,
            pinned: true,
            stretch: true,
            backgroundColor: AppTheme.background, // ĐỒNG BỘ THEME
            iconTheme: const IconThemeData(
              color: Colors.white,
            ), // Đổi màu nút Back thành trắng cho dễ nhìn
            // LẮP NÚT XÓA VÀO ĐÂY
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                onPressed: () => _confirmDelete(context, widget.recipe),
              ),
              const SizedBox(width: 8),
            ],

            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              title: Text(
                widget.recipe.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black87, blurRadius: 12)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // THAY BẰNG APP CACHED IMAGE
                  AppCachedImage(
                    imageUrl: widget.recipe.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black54, Colors.transparent],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Phần Nguyên liệu ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Nguyên liệu', style: AppTheme.heading2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(
                            0.1,
                          ), // ĐỒNG BỘ THEME
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 18),
                              color: _currentServings > 1
                                  ? AppTheme.primary
                                  : AppTheme.textLight,
                              onPressed: _currentServings > 1
                                  ? () => setState(() => _currentServings--)
                                  : null,
                            ),
                            Text(
                              '$_currentServings người',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              color: AppTheme.primary, // ĐỒNG BỘ THEME
                              onPressed: () =>
                                  setState(() => _currentServings++),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  ...widget.recipe.ingredients.map((ingredient) {
                    final dynamicIngredient = ingredient.copyWithMultiplier(
                      multiplier,
                    );
                    final isChecked = _checkedIngredients.contains(
                      ingredient.id,
                    );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: InkWell(
                        onTap: () => setState(() {
                          if (isChecked) {
                            _checkedIngredients.remove(ingredient.id);
                          } else {
                            _checkedIngredients.add(ingredient.id);
                          }
                        }),
                        child: Row(
                          children: [
                            Icon(
                              isChecked
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              color: isChecked
                                  ? AppTheme.success
                                  : AppTheme.textLight, // ĐỒNG BỘ THEME
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                dynamicIngredient.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isChecked
                                      ? AppTheme.success.withOpacity(0.8)
                                      : AppTheme.textDark,
                                  decoration: isChecked
                                      ? TextDecoration.lineThrough
                                      : null,
                                  decorationColor: AppTheme.success,
                                  decorationThickness: 2,
                                ),
                              ),
                            ),
                            Text(
                              '${dynamicIngredient.amount.toStringAsFixed(dynamicIngredient.amount.truncateToDouble() == dynamicIngredient.amount ? 0 : 1)} ${dynamicIngredient.unit}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isChecked
                                    ? AppTheme.success.withOpacity(0.8)
                                    : AppTheme.primary,
                                decoration: isChecked
                                    ? TextDecoration.lineThrough
                                    : null,
                                decorationColor: AppTheme.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 32),

                  // --- Phần Cách làm ---
                  const Text('Cách làm', style: AppTheme.heading2),
                  const SizedBox(height: 16),

                  ...widget.recipe.steps.asMap().entries.map((entry) {
                    int idx = entry.key;
                    String step = entry.value;
                    bool isDone = _completedSteps.contains(idx);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: InkWell(
                        onTap: () => setState(() {
                          if (isDone) {
                            _completedSteps.remove(idx);
                          } else {
                            _completedSteps.add(idx);
                          }
                        }),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDone
                                    ? AppTheme.success
                                    : AppTheme.primary, // ĐỒNG BỘ THEME
                              ),
                              child: isDone
                                  ? const Icon(
                                      Icons.done,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  : Text(
                                      '${idx + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                step,
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.6,
                                  color: isDone
                                      ? AppTheme.success.withOpacity(0.8)
                                      : AppTheme.textDark,
                                  decoration: isDone
                                      ? TextDecoration.lineThrough
                                      : null,
                                  decorationColor: AppTheme.success,
                                  decorationThickness: 2.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
