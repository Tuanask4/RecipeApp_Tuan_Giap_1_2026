import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_theme.dart';
import '../viewmodels/auth_provider.dart';
import 'home_page.dart';
import 'community_feed_page.dart';
import 'recipe_form_page.dart';

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  int _currentIndex = 0;
  bool _isBottomNavVisible = true;

  final ScrollController _homeScrollController = ScrollController();
  final ScrollController _communityScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _homeScrollController.dispose();
    _communityScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Danh sách các trang dựa trên Index
    final List<Widget> pages = [
      HomePage(scrollController: _homeScrollController),
      CommunityFeedPage(scrollController: _communityScrollController),
      _ProfileTab(),
    ];

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is UserScrollNotification) {
          if (notification.direction == ScrollDirection.reverse) {
            if (_isBottomNavVisible)
              setState(() => _isBottomNavVisible = false);
          } else if (notification.direction == ScrollDirection.forward) {
            if (!_isBottomNavVisible)
              setState(() => _isBottomNavVisible = true);
          }
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        extendBody: true,

        body: IndexedStack(index: _currentIndex, children: pages),

        // ================= FAB CỐ ĐỊNH GÓC PHẢI DƯỚi =================
        // Bỏ centerDocked — dùng endFloat để tránh xung đột với nav bar 3 tab
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: _currentIndex == 2
            ? null // Ẩn hoàn toàn ở tab Tài khoản
            : AnimatedScale(
                scale: _isBottomNavVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutBack,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: AppTheme.primaryShadow,
                  ),
                  child: FloatingActionButton(
                    backgroundColor: AppTheme.primary,
                    elevation: 0,
                    shape: const CircleBorder(),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RecipeFormPage()),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 30),
                  ),
                ),
              ),

        // ================= NAV BAR 3 TAB SẠH ĐỀU =================
        bottomNavigationBar: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _isBottomNavVisible ? 72 : 0,
          child: Wrap(
            children: [
              BottomAppBar(
                color: AppTheme.surface,
                elevation: 12,
                child: SizedBox(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(
                        icon: Icons.home_filled,
                        label: 'Trang chủ',
                        index: 0,
                      ),
                      _buildNavItem(
                        icon: Icons.people_outline,
                        label: 'Cộng đồng',
                        index: 1,
                      ),
                      _buildNavItem(
                        icon: Icons.person_outline,
                        label: 'Tài khoản',
                        index: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ); // NotificationListener
  }

  // ================= HÀM VẼ NÚT ĐIỀU HƯỚNG =================
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      highlightColor: Colors.transparent, // Bỏ hiệu ứng nháy xám mặc định
      splashColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? AppTheme.primary : AppTheme.textLight,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.primary : AppTheme.textLight,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// PROFILE TAB: Hiển thị thông tin user + nút đăng xuất
// Sẽ được mở rộng thành full Profile Page ở Phase 1
// ===========================================================================
class _ProfileTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildAboutBody(context, ref, user)),
        ],
      ),
    );
  }

  Widget _buildAboutBody(BuildContext context, WidgetRef ref, user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(32, 80, 32, 60),
          color: AppTheme.surface,
          child: Column(
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                    height: 1.45,
                    fontFamily: 'serif',
                  ),
                  children: [
                    const TextSpan(text: 'Chúng tôi là những '),
                    TextSpan(
                      text: 'người nấu ăn',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(text: ', '),
                    const TextSpan(
                      text: 'người chia sẻ',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    const TextSpan(text: ', và '),
                    const TextSpan(
                      text: 'người yêu ẩm thực',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    const TextSpan(text: ' Việt Nam.'),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Nút CTA — giống "Browse our shop" của Figma
              SizedBox(
                width: 200,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppTheme.radiusM,
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Khám phá công thức',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // =========================================================
        // PHẦN 2: IMAGE GRID — 2 ảnh song song từ Unsplash
        // Giống layout ảnh rau củ trong Figma About
        // =========================================================
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // Ảnh trái — cao hơn một chút
              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: AppTheme.radiusL,
                  child: Image.network(
                    'https://images.unsplash.com/photo-1543353071-873f17a7a088'
                    '?w=600&auto=format&fit=crop',
                    height: 240,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(height: 240, color: Colors.grey.shade100),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Ảnh phải — có text caption bên dưới giống Figma
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: AppTheme.radiusL,
                      child: Image.network(
                        'https://images.unsplash.com/photo-1504674900247-0877df9cc836'
                        '?w=600&auto=format&fit=crop',
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(height: 180, color: Colors.grey.shade100),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Caption giống Figma "Central California —..."
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textLight,
                          height: 1.5,
                        ),
                        children: [
                          TextSpan(
                            text: 'Việt Nam',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark.withOpacity(0.7),
                            ),
                          ),
                          const TextSpan(
                            text:
                                ' — Nơi ẩm thực phong phú và đa dạng '
                                'nhất Đông Nam Á.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 48),

        // =========================================================
        // PHẦN 3: WHAT WE BELIEVE — label trái + text phải
        // Giống layout 2 cột của Figma About
        // =========================================================
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label bên trái — ALL CAPS nhỏ
              const SizedBox(
                width: 110,
                child: Text(
                  'WHAT WE\nBELIEVE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textLight,
                    letterSpacing: 1.2,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Text dài bên phải
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chúng tôi tin rằng mọi người đều có thể nấu ăn ngon. '
                      'Không cần đầu bếp chuyên nghiệp — chỉ cần công thức đúng '
                      'và một chút tình yêu với bếp núc.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textDark,
                        height: 1.75,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Phở bò. Bún bò Huế. Bánh mì. Cơm tấm. Bánh xèo. '
                      'Gỏi cuốn. Chả giò. Bò lúc lắc. Cá kho tộ. Canh chua. '
                      'Thịt kho trứng. Mì Quảng. Bánh cuốn.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textLight,
                        height: 1.85,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Chúng tôi đang quên gì không?\n\n'
                      'Còn bún riêu. Bánh khọt. Hủ tiếu. Súp cua. Lẩu thái. '
                      'Bò kho. Xôi gà. Bánh tét. Nem nướng. Cháo lòng. '
                      'Và rất nhiều món ngon đang chờ bạn khám phá...',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textLight,
                        height: 1.85,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 48),
        Divider(color: Colors.grey.shade200, height: 1),
        const SizedBox(height: 20),

        // ---- Đăng xuất + copyright ở cuối ----
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // User info nhỏ gọn
              if (user != null)
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppTheme.primary.withOpacity(0.15),
                      child: Text(
                        (user.displayName ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.displayName ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppTheme.textDark,
                            ),
                          ),
                          Text(
                            user.email ?? '',
                            style: AppTheme.bodyText.copyWith(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: AppTheme.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppTheme.radiusM,
                            ),
                            title: const Text(
                              'Đăng xuất?',
                              style: AppTheme.heading2,
                            ),
                            content: const Text(
                              'Bạn sẽ cần đăng nhập lại để tiếp tục.',
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
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.error,
                                ),
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text(
                                  'Đăng xuất',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await ref.read(authServiceProvider).signOut();
                        }
                      },
                      icon: const Icon(
                        Icons.logout,
                        size: 16,
                        color: AppTheme.error,
                      ),
                      label: const Text(
                        'Đăng xuất',
                        style: TextStyle(color: AppTheme.error, fontSize: 13),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 16),
              Text(
                '© 2026 Recipe App · Phenikaa University',
                style: AppTheme.bodyText.copyWith(fontSize: 11),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }
}
