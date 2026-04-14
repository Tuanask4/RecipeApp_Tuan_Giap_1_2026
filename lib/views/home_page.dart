import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/recipe_provider.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/large_recipe_card.dart';
import '../widgets/small_recipe_card.dart';

class HomePage extends ConsumerWidget {
  final ScrollController scrollController;

  const HomePage({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Lấy dữ liệu Stream
    final recipesAsync = ref.watch(recipeListProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        controller: scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // ================= LỚP 1: MÓNG NHÀ (HEADER & TÌM KIẾM) =================
          SliverAppBar(
            expandedHeight: 320.0,
            pinned: true,
            stretch: true,
            toolbarHeight: 0,
            elevation: 0,
            backgroundColor: Colors.grey[50],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1504674900247-0877df9cc836?q=80&w=1000&auto=format&fit=crop',
                    fit: BoxFit.cover,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black87, Colors.transparent],
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 20,
                    bottom: 90,
                    child: Text(
                      'Món ngon hôm nay',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        shadows: [Shadow(color: Colors.black87, blurRadius: 8)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: Container(
                height: 70,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: const HomeSearchBar(),
              ),
            ),
          ),

          // ================= LỚP 2: NỘI THẤT (THAY ĐỔI THEO TRẠNG THÁI) =================

          // Trạng thái 1: Đang tải mạng (Chỉ hiện vòng xoay ở phần dưới, giữ nguyên Header)
          if (recipesAsync.isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: Colors.orange),
              ),
            )
          // Trạng thái 2: Lỗi mạng
          else if (recipesAsync.hasError)
            SliverFillRemaining(
              child: Center(
                child: Text('Đã xảy ra lỗi: ${recipesAsync.error}'),
              ),
            )
          // Trạng thái 3: Tìm kiếm nhưng không có món nào khớp
          else if (recipesAsync.value != null && recipesAsync.value!.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text(
                  'Không tìm thấy món ăn nào! 😢',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          // Trạng thái 4: Tải thành công và có dữ liệu (Vẽ danh sách ra)
          else if (recipesAsync.value != null) ...[
            SliverToBoxAdapter(
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
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: recipesAsync.value!.length,
                      itemBuilder: (context, index) =>
                          LargeRecipeCard(recipe: recipesAsync.value![index]),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const SectionTitle(title: 'Khám phá hôm nay 🔥'),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      SmallRecipeCard(recipe: recipesAsync.value![index]),
                  childCount: recipesAsync.value!.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ],
      ),
    );
  }
}

// ============================================================================
// TỐI ƯU: TÁCH CÁC COMPONENT THÀNH CLASS ĐỘC LẬP (ĐỂ TẬN DỤNG CONST CACHE)
// ============================================================================

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}
