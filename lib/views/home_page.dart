import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/recipe_provider.dart';
import '../widgets/large_recipe_card.dart';
import '../widgets/small_recipe_card.dart';
import '../widgets/home_hero_header.dart';
import '../core/app_theme.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends ConsumerWidget {
  final ScrollController scrollController;
  const HomePage({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(recipeListProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        controller: scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          const HomeHeroHeader(),

          recipesAsync.when(
            loading: () => SliverFillRemaining(
              child: Shimmer.fromColors(
                baseColor: AppTheme.shimmerBase,
                highlightColor: AppTheme.shimmerHighlight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    // Giả lập tiêu đề
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      width: 200,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppTheme.radiusS,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Giả lập danh sách cuộn ngang (Large Cards)
                    SizedBox(
                      height: 260,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: 3,
                        itemBuilder: (_, __) => Container(
                          width: 200,
                          margin: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: AppTheme.radiusL,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Giả lập danh sách dọc (Small Cards)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: List.generate(
                          4,
                          (index) => Container(
                            height: 100,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: AppTheme.radiusM,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.wifi_off_rounded,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Úi, mất mạng rồi!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Vui lòng kiểm tra lại kết nối Wifi hoặc 4G nhé.',
                      style: TextStyle(color: AppTheme.textLight),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      // ref.invalidate giúp Riverpod khởi động lại quá trình lấy dữ liệu
                      onPressed: () => ref.invalidate(recipeListProvider),
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text(
                        'Thử lại',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppTheme.radiusM,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            data: (recipes) => SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const SectionTitle(title: 'Nạp năng lượng sau tập 💪'),
                  const SizedBox(height: 16),
                  _buildHorizontalList(recipes),
                  const SizedBox(height: 30),
                  const SectionTitle(title: 'Khám phá hôm nay 🔥'),
                  const SizedBox(height: 16),
                  _buildVerticalList(recipes),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalList(List recipes) {
    return SizedBox(
      height: 260,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: recipes.length,
        itemBuilder: (context, i) => LargeRecipeCard(recipe: recipes[i]),
      ),
    );
  }

  Widget _buildVerticalList(List recipes) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: recipes.map((r) => SmallRecipeCard(recipe: r)).toList(),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),
  );
}
