import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/recipe_provider.dart';
import 'smart_pantry_page.dart';
import '../widgets/large_recipe_card.dart';
import '../widgets/small_recipe_card.dart';


class HomePage extends ConsumerWidget {
  final ScrollController scrollController;

  const HomePage({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(recipeListProvider);

    return recipesAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Colors.orange)),
      ),
      error: (error, stackTrace) => Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text('Đã xảy ra lỗi:\n$error', textAlign: TextAlign.center),
        ),
      ),
      data: (recipes) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: CustomScrollView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // ================= HEADER =================
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
                            shadows: [
                              Shadow(color: Colors.black87, blurRadius: 8),
                            ],
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
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 46,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const TextField(
                              decoration: InputDecoration(
                                icon: Icon(
                                  Icons.search,
                                  color: Colors.orange,
                                  size: 22,
                                ),
                                hintText: 'Tìm kiếm công thức...',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SmartPantryPage(),
                            ),
                          ),
                          child: Container(
                            height: 46,
                            width: 46,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.kitchen,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ================= NỘI DUNG =================
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const SectionTitle(title: 'Nạp năng lượng sau tập 💪'),
                    const SizedBox(height: 16),

                    // Danh sách ngang
                    SizedBox(
                      height: 260,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: recipes.length,
                        itemBuilder: (context, index) {
                          // TỐI ƯU: Gọi Class độc lập thay vì hàm
                          return LargeRecipeCard(recipe: recipes[index]);
                        },
                      ),
                    ),

                    const SizedBox(height: 30),
                    const SectionTitle(title: 'Khám phá hôm nay 🔥'),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // Danh sách dọc
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    // TỐI ƯU: Gọi Class độc lập
                    (context, index) => SmallRecipeCard(recipe: recipes[index]),
                    childCount: recipes.length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
      },
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

