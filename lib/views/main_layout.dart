import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../core/app_theme.dart';
import 'home_page.dart';
import 'recipe_form_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  bool _isBottomNavVisible = true;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_isBottomNavVisible)
          setState(() => _isBottomNavVisible = false); // Kéo xuống -> Ẩn
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_isBottomNavVisible)
          setState(() => _isBottomNavVisible = true); // Kéo lên -> Hiện
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Danh sách các trang dựa trên Index
    final List<Widget> pages = [
      HomePage(scrollController: _scrollController),
      // Trang tài khoản (Tạm thời là Placeholder)
      const Center(
        child: Text(
          'Trang Tài Khoản\\n(Đang xây dựng)',
          textAlign: TextAlign.center,
          style: AppTheme.heading2,
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      // Cho phép nội dung cuộn luồn xuống dưới thanh điều hướng trong suốt
      extendBody: true,

      // Nội dung chính
      body: IndexedStack(index: _currentIndex == 0 ? 0 : 1, children: pages),

      // ================= NÚT THÊM MỚI (FAB) =================
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: AnimatedScale(
        scale: _isBottomNavVisible ? 1.0 : 0.0, // Ẩn/Hiện nút mượt mà
        duration: const Duration(milliseconds: 300),
        child: FloatingActionButton(
          backgroundColor: AppTheme.primary,
          elevation: 6,
          shape: const CircleBorder(), // Nút hình tròn chuẩn Material 3
          onPressed: () {
            // Mở form thêm món mới
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RecipeFormPage()),
            );
          },
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),

      // ================= THANH ĐIỀU HƯỚNG DƯỚI =================
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        // Nếu cuộn xuống, chiều cao = 0 (giấu đi). Nếu cuộn lên, cao = 80 (hiện ra)
        height: _isBottomNavVisible ? 80 : 0,
        child: Wrap(
          children: [
            BottomAppBar(
              color: AppTheme.surface, // ĐỒNG BỘ THEME
              elevation: 20,
              notchMargin: 8.0, // Khoảng hở giữa nút FAB và thanh điều hướng
              shape:
                  const CircularNotchedRectangle(), // Đường khoét lõm cho nút FAB
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
                    const SizedBox(
                      width: 48,
                    ), // Khoảng trống ở giữa nhường chỗ cho FAB
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
    );
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
