import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../core/app_theme.dart';
import 'home_page.dart';

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
    // Khởi tạo controller và lắng nghe sự kiện cuộn
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
    _scrollController.dispose(); // Tránh rò rỉ bộ nhớ khi tắt app
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Đưa danh sách màn hình vào trong build để có thể truyền được _scrollController
    final List<Widget> screens = [
      HomePage(scrollController: _scrollController),
      const Center(child: Text('Màn hình Thêm công thức (Đang chờ Firebase)')),
      const Center(child: Text('Màn hình Tài khoản (Đang chờ Firebase)')),
    ];

    return Scaffold(
      body: screens[_currentIndex], // Hiển thị màn hình theo tab đang chọn

      floatingActionButton: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        // Thu nhỏ/Ẩn nút cộng khi cuộn xuống
        transform: Matrix4.translationValues(
          0,
          _isBottomNavVisible ? 0 : 100,
          0,
        ),
        child: FloatingActionButton(
          onPressed: () => setState(() => _currentIndex = 1),
          backgroundColor: AppTheme.primary,
          shape: const CircleBorder(),
          elevation: 8,
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _isBottomNavVisible ? 65 : 0, // Thu hồi chiều cao khi ẩn
        child: Wrap(
          children: [
            BottomAppBar(
              padding: EdgeInsets.zero,
              shape: const CircularNotchedRectangle(),
              notchMargin: 6.0,
              color: Colors.white,
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
                    const SizedBox(width: 40),
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

  // Hàm phụ trợ vẽ nút
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? Colors.orange : Colors.grey, size: 28),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.orange : Colors.grey,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
