import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../viewmodels/recipe_provider.dart';
import '../widgets/large_recipe_card.dart';
import '../widgets/small_recipe_card.dart';
import '../widgets/home_hero_header.dart';
import '../core/app_theme.dart';

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
            // GIAO DIỆN SHIMMER KHI ĐANG TẢI DỮ LIỆU
            loading: () => SliverToBoxAdapter(
              child: Shimmer.fromColors(
                baseColor: AppTheme.shimmerBase,
                highlightColor: AppTheme.shimmerHighlight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      width: 200,
                      height: 24,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
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

            // GIAO DIỆN KHI BỊ RỚT MẠNG HOẶC LỖI
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
                      'Úi, mất mạng rồi! 📡',
                      style: AppTheme.heading2,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Vui lòng kiểm tra lại kết nối Wifi hoặc 4G nhé.',
                      style: AppTheme.bodyText,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => ref.invalidate(recipeListProvider),
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text(
                        'Thử lại',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // GIAO DIỆN KHI TẢI THÀNH CÔNG
            data: (recipes) {
              if (recipes.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('Không tìm thấy món nào! 😢')),
                );
              }
              return SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const SectionTitle(title: 'Nạp năng lượng sau tập 💪'),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 260,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: recipes.length,
                        itemBuilder: (context, i) =>
                            LargeRecipeCard(recipe: recipes[i]),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const SectionTitle(title: 'Khám phá hôm nay 🔥'),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: recipes
                            .map((r) => SmallRecipeCard(recipe: r))
                            .toList(),
                      ),
                    ),
                    const _HomeFooter(),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// FOOTER: Thông tin sinh viên — đồng nhất với theme app
// ===========================================================================
class _HomeFooter extends StatelessWidget {
  const _HomeFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: AppTheme.radiusL,
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          // Logo trường — icon sách + tên
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: AppTheme.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Phenikaa University',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Divider(color: Colors.grey.shade100, thickness: 1, height: 1),
          const SizedBox(height: 14),

          // Sinh viên 1
          _StudentRow(
            index: '01',
            name: 'Nguyễn Minh Tuấn',
            studentId: '22010478',
          ),
          const SizedBox(height: 8),

          // Sinh viên 2
          _StudentRow(
            index: '02',
            name: 'Nguyễn Văn Giáp',
            studentId: '22010369',
          ),
        ],
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  final String index;
  final String name;
  final String studentId;

  const _StudentRow({
    required this.index,
    required this.name,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Số thứ tự — badge cam nhỏ
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            index,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Tên sinh viên
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
        ),

        // Mã sinh viên — pill xám
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            studentId,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.textLight,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Text(title, style: AppTheme.heading2),
  );
}
