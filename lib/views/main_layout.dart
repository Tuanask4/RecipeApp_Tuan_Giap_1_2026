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

        // FIX: IndexedStack dùng đúng _currentIndex, không map tay nữa
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
                    boxShadow: AppTheme.primaryShadow, // Cam phát sáng
                  ),
                  child: FloatingActionButton(
                    backgroundColor: AppTheme.primary,
                    elevation: 0, // Shadow đã do Container lo
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
                // Bỏ notch — không còn FAB centerDocked nữa
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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Tài khoản', style: AppTheme.heading2),
        backgroundColor: AppTheme.background,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        children: [
          // ---- Avatar + Tên ----
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: AppTheme.radiusL,
              boxShadow: AppTheme.softShadow,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppTheme.primary.withOpacity(0.15),
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  child: user?.photoURL == null
                      ? Text(
                          (user?.displayName ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'Người dùng',
                        style: AppTheme.heading2,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: AppTheme.bodyText,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingM),

          // ---- Nút Đăng xuất ----
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: AppTheme.radiusM,
              boxShadow: AppTheme.softShadow,
            ),
            child: ListTile(
              shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusM),
              leading: const Icon(Icons.logout, color: AppTheme.error),
              title: const Text(
                'Đăng xuất',
                style: TextStyle(
                  color: AppTheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppTheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppTheme.radiusM,
                    ),
                    title: const Text('Đăng xuất?', style: AppTheme.heading2),
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
                  // AuthGate sẽ tự chuyển về AuthPage
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
