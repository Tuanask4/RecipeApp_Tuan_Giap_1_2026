import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_theme.dart';
import '../models/recipe.dart';
import '../viewmodels/auth_provider.dart';
import '../viewmodels/recipe_provider.dart';
import '../widgets/app_cached_image.dart';
import '../widgets/animated_scale_card.dart';
import 'recipe_detail_page.dart';

class CommunityFeedPage extends ConsumerWidget {
  final ScrollController scrollController;
  const CommunityFeedPage({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(recipeListProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: recipesAsync.when(
        loading: () => _buildShimmer(),
        error: (e, _) => _buildError(e.toString()),
        data: (recipes) {
          if (recipes.isEmpty) return _buildEmpty();

          // Đếm số tác giả unique
          final authorCount = recipes.map((r) => r.authorId).toSet().length;

          return RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: () async => ref.invalidate(recipeListProvider),
            child: CustomScrollView(
              controller: scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // =====================================================
                // HEADER — "Basket · 3 items" style từ Figma Content
                // =====================================================
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title + số lượng — giống "Basket  3 items"
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            const Text(
                              'Cộng đồng',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${recipes.length} công thức',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textLight,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // =====================================================
                        // STATS BOX — giống "Order Summary" từ Figma Content
                        // Collapse xuống dưới header thay vì đứng cạnh (mobile)
                        // =====================================================
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: AppTheme.radiusM,
                            boxShadow: AppTheme.softShadow,
                          ),
                          child: Column(
                            children: [
                              const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Tổng quan',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Divider(color: Colors.grey.shade100, height: 1),
                              const SizedBox(height: 12),
                              _statRow(
                                'Tổng công thức',
                                '${recipes.length} món',
                              ),
                              const SizedBox(height: 8),
                              _statRow(
                                'Đầu bếp cộng đồng',
                                '$authorCount người',
                              ),
                              const SizedBox(height: 8),
                              _statRow(
                                'Mới nhất',
                                recipes.first.createdAt != null
                                    ? _formatDate(recipes.first.createdAt!)
                                    : '—',
                              ),
                              const SizedBox(height: 14),
                              Divider(color: Colors.grey.shade100, height: 1),
                              const SizedBox(height: 12),
                              // CTA — "Continue to payment" style
                              SizedBox(
                                width: double.infinity,
                                height: 44,
                                child: ElevatedButton.icon(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: AppTheme.radiusM,
                                    ),
                                    elevation: 0,
                                  ),
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'Chia sẻ công thức',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Divider(color: Colors.grey.shade200, height: 1),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ),

                // =====================================================
                // LIST — mỗi item dạng hàng ngang giống basket items
                // =====================================================
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _BasketCard(
                        recipe: recipes[index],
                        index: index,
                        isOwner: currentUser?.uid == recipes[index].authorId,
                      ),
                      childCount: recipes.length,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Stat row — giống Subtotal / Shipping / Tax trong Order Summary
  Widget _statRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTheme.bodyText),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 80, 20, 16),
      itemCount: 5,
      itemBuilder: (_, __) => const _BasketCardSkeleton(),
    );
  }

  Widget _buildError(String msg) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
        const SizedBox(height: 12),
        const Text('Có lỗi xảy ra', style: AppTheme.heading2),
        const SizedBox(height: 4),
        Text(msg, style: AppTheme.bodyText, textAlign: TextAlign.center),
      ],
    ),
  );

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🍳', style: TextStyle(fontSize: 56)),
        const SizedBox(height: 16),
        const Text('Chưa có công thức nào', style: AppTheme.heading2),
        const SizedBox(height: 8),
        Text('Hãy là người đầu tiên chia sẻ!', style: AppTheme.bodyText),
      ],
    ),
  );
}

// ===========================================================================
// BASKET CARD — layout hàng ngang giống basket items trong Figma
// Ảnh vuông bên trái + thông tin bên phải + thời gian nấu thay giá
// ===========================================================================
class _BasketCard extends StatelessWidget {
  final Recipe recipe;
  final int index;
  final bool isOwner;

  const _BasketCard({
    required this.recipe,
    required this.index,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScaleCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RecipeDetailPage(recipe: recipe)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ---- Ảnh vuông bên trái — giống ảnh sản phẩm basket ----
                  ClipRRect(
                    borderRadius: AppTheme.radiusM,
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: AppCachedImage(
                        imageUrl: recipe.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // ---- Thông tin giữa ----
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tên món — giống tên sản phẩm
                        Text(
                          recipe.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Tác giả — giống giá/lb
                        Row(
                          children: [
                            Text(
                              recipe.authorName,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (isOwner) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: const Text(
                                  'Bạn',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Số lượng — giống "1 lb" với icon edit
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.background,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Text(
                                '${recipe.durationMinutes} phút',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textDark,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.people_outline,
                              size: 13,
                              color: AppTheme.textLight,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${recipe.defaultServings} người',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  // ---- Độ khó — giống giá tiền bên phải ----
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _difficultyLabel(recipe.difficulty),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      if (recipe.createdAt != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(recipe.createdAt!),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Divider giữa các item — giống basket list
            Divider(color: Colors.grey.shade100, height: 1),
          ],
        ),
      ),
    );
  }

  String _difficultyLabel(Difficulty d) => switch (d) {
    Difficulty.easy => 'Dễ',
    Difficulty.medium => 'Vừa',
    Difficulty.hard => 'Khó',
  };

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}p trước';
    if (diff.inHours < 24) return '${diff.inHours}h trước';
    if (diff.inDays < 7) return '${diff.inDays}d trước';
    return '${date.day}/${date.month}';
  }
}

// ===========================================================================
// SKELETON — loading placeholder cho basket card
// ===========================================================================
class _BasketCardSkeleton extends StatelessWidget {
  const _BasketCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: AppTheme.radiusM,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 70,
                      height: 26,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 30,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
        Divider(color: Colors.grey.shade100, height: 1),
      ],
    );
  }
}
