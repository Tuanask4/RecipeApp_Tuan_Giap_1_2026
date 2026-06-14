import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe.dart';
import '../core/app_theme.dart';
import '../viewmodels/auth_provider.dart';
import '../viewmodels/recipe_provider.dart'; // THÊM IMPORT NÀY
import '../widgets/app_cached_image.dart';
import 'recipe_form_page.dart';

class RecipeDetailPage extends ConsumerStatefulWidget {
  final Recipe recipe;
  const RecipeDetailPage({super.key, required this.recipe});

  @override
  ConsumerState<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends ConsumerState<RecipeDetailPage> {
  late int _currentServings;
  final Set<String> _checkedIngredients = {};
  final Set<int> _completedSteps = {};

  @override
  void initState() {
    super.initState();
    _currentServings = widget.recipe.defaultServings;
  }

  // ===========================================================================
  // PHÂN QUYỀN: Chỉ tác giả mới thấy nút Sửa và Xóa
  // ===========================================================================
  bool get _isOwner {
    final uid = ref.read(currentUserProvider)?.uid;
    // Fallback: nếu recipe cũ chưa có authorId thì không ai được sửa/xóa
    return uid != null &&
        widget.recipe.authorId.isNotEmpty &&
        uid == widget.recipe.authorId;
  }

  // ===========================================================================
  // XÓA công thức — chỉ owner mới gọi được hàm này
  // ===========================================================================
  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusM),
        title: const Text('Xóa công thức?', style: AppTheme.heading2),
        content: Text(
          'Bạn có chắc muốn xóa "${widget.recipe.title}"?\nHành động này không thể hoàn tác.',
          style: AppTheme.bodyText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Hủy',
              style: TextStyle(color: AppTheme.textLight),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Xóa ngay',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await FirebaseFirestore.instance
            .collection('recipes')
            .doc(widget.recipe.id)
            .delete();
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã xóa "${widget.recipe.title}"'),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusM),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
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

  // ===========================================================================
  // BUILD
  // ===========================================================================
  @override
  Widget build(BuildContext context) {
    // ---- LOGIC MỚI: Lắng nghe Realtime ----
    final recipesAsync = ref.watch(recipeListProvider);

    final currentRecipe = recipesAsync.maybeWhen(
      data: (recipes) => recipes.firstWhere(
        (r) => r.id == widget.recipe.id,
        orElse: () => widget.recipe,
      ),
      orElse: () => widget.recipe,
    );
    // ---------------------------------------

    // Đổi widget.recipe.defaultServings thành currentRecipe.defaultServings
    final double multiplier = _currentServings / currentRecipe.defaultServings;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // ---- SLIVER APP BAR với ảnh hero ----
          SliverAppBar(
            expandedHeight: 340.0,
            pinned: true,
            stretch: true,
            backgroundColor: AppTheme.background,
            iconTheme: const IconThemeData(color: Colors.white),

            actions: _isOwner
                ? [
                    // Nút Sửa
                    IconButton(
                      tooltip: 'Sửa công thức',
                      icon: _appBarIconButton(Icons.edit_outlined),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          // Truyền currentRecipe để khi sửa nó lấy data mới nhất
                          builder: (_) =>
                              RecipeFormPage(existingRecipe: currentRecipe),
                        ),
                      ),
                    ),
                    // Nút Xóa
                    IconButton(
                      tooltip: 'Xóa công thức',
                      icon: _appBarIconButton(Icons.delete_outline),
                      onPressed: _confirmDelete,
                    ),
                    const SizedBox(width: 4),
                  ]
                : null, // Người khác không thấy nút nào

            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              title: Text(
                currentRecipe.title, // Thay widget.recipe bằng currentRecipe
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black87, blurRadius: 12)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  AppCachedImage(
                    imageUrl: currentRecipe
                        .imageUrl, // Thay widget.recipe bằng currentRecipe
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
                  // ---- Tác giả ----
                  if (currentRecipe.authorName.isNotEmpty &&
                      currentRecipe.authorName != 'Ẩn danh')
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppTheme.primary.withOpacity(0.15),
                            child: Text(
                              currentRecipe.authorName[0]
                                  .toUpperCase(), // Thay thế
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            currentRecipe.authorName, // Thay thế
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark,
                            ),
                          ),
                          if (currentRecipe.createdAt != null) ...[
                            // Thay thế
                            const SizedBox(width: 8),
                            Text(
                              _formatDate(currentRecipe.createdAt!), // Thay thế
                              style: AppTheme.bodyText,
                            ),
                          ],
                        ],
                      ),
                    ),

                  // ---- Nguyên liệu ----
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
                          color: AppTheme.primary.withOpacity(0.1),
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
                              color: AppTheme.primary,
                              onPressed: () =>
                                  setState(() => _currentServings++),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  ...currentRecipe.ingredients.map((ingredient) {
                    // Thay thế
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
                                  : AppTheme.textLight,
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

                  // ---- Cách làm ----
                  const Text('Cách làm', style: AppTheme.heading2),
                  const SizedBox(height: 16),

                  ...currentRecipe.steps.asMap().entries.map((entry) {
                    // Thay thế
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
                                    : AppTheme.primary,
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

  // ===========================================================================
  // HELPER: Icon button có nền tối — dễ nhìn trên ảnh hero
  // ===========================================================================
  Widget _appBarIconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.black45,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  // ===========================================================================
  // HELPER: Format ngày tháng thân thiện
  // ===========================================================================
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Hôm nay';
    if (diff.inDays == 1) return 'Hôm qua';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${date.day}/${date.month}/${date.year}';
  }
}
