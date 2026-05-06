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
      appBar: AppBar(
        title: const Text('Cộng đồng', style: AppTheme.heading2),
        backgroundColor: AppTheme.background,
        elevation: 0,
      ),
      body: recipesAsync.when(
        loading: () => _buildShimmerList(),
        error: (e, _) => _buildError(e.toString()),
        data: (recipes) {
          if (recipes.isEmpty) return _buildEmpty();
          return RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: () async => ref.invalidate(recipeListProvider),
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              itemCount: recipes.length,
              itemBuilder: (context, index) => _FeedCard(
                recipe: recipes[index],
                isOwner: currentUser?.uid == recipes[index].authorId,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => const _FeedCardSkeleton(),
    );
  }

  Widget _buildError(String message) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
        const SizedBox(height: 12),
        Text('Có lỗi xảy ra', style: AppTheme.heading2),
        const SizedBox(height: 4),
        Text(message, style: AppTheme.bodyText, textAlign: TextAlign.center),
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
// FEED CARD: Mỗi công thức trong community feed
// ===========================================================================
class _FeedCard extends StatelessWidget {
  final Recipe recipe;
  final bool isOwner;

  const _FeedCard({required this.recipe, required this.isOwner});

  @override
  Widget build(BuildContext context) {
    return AnimatedScaleCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RecipeDetailPage(recipe: recipe)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: AppTheme.radiusL,
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- Ảnh ----
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: AppCachedImage(
                  imageUrl: recipe.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---- Tác giả + thời gian ----
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppTheme.primary.withOpacity(0.15),
                        child: Text(
                          recipe.authorName.isNotEmpty
                              ? recipe.authorName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  recipe.authorName,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                if (isOwner) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
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
                            if (recipe.createdAt != null)
                              Text(
                                _formatDate(recipe.createdAt!),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textLight,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ---- Tên món ----
                  Text(
                    recipe.title,
                    style: AppTheme.heading2,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),

                  // ---- Thông tin nhanh ----
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.schedule,
                        label: '${recipe.durationMinutes} phút',
                      ),
                      const SizedBox(width: 8),
                      _InfoChip(
                        icon: Icons.people_outline,
                        label: '${recipe.defaultServings} người',
                      ),
                      const SizedBox(width: 8),
                      _InfoChip(
                        icon: Icons.local_fire_department,
                        label: _difficultyLabel(recipe.difficulty),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _difficultyLabel(Difficulty d) => switch (d) {
    Difficulty.easy => 'Dễ',
    Difficulty.medium => 'Vừa',
    Difficulty.hard => 'Khó',
  };
}

// ===========================================================================
// INFO CHIP: Tag thông tin nhỏ gọn
// ===========================================================================
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppTheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// SKELETON: Shimmer loading placeholder cho feed card
// ===========================================================================
class _FeedCardSkeleton extends StatelessWidget {
  const _FeedCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: AppTheme.radiusL,
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(color: Colors.grey.shade200),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey.shade200,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 100,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 160,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
