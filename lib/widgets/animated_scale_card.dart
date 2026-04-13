import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Bắt buộc phải có thư viện này để dùng hiệu ứng Rung (Haptic)

class AnimatedScaleCard extends StatefulWidget {
  final Widget child; // Khối giao diện bên trong thẻ (ví dụ: hình ảnh, chữ...)
  final VoidCallback onTap; // Hành động khi bấm vào thẻ

  const AnimatedScaleCard({
    super.key,
    required this.child,
    required this.onTap,
  });

  @override
  State<AnimatedScaleCard> createState() => _AnimatedScaleCardState();
}

// Bắt buộc phải dùng SingleTickerProviderStateMixin để làm mượt Animation
class _AnimatedScaleCardState extends State<AnimatedScaleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Khởi tạo bộ điều khiển, thời gian hiệu ứng lún xuống là 150ms (rất nhanh và mượt)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    // Cài đặt tỷ lệ: 1.0 là kích thước gốc, 0.95 là thu nhỏ 5%
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose(); // Bắt buộc phải giải phóng bộ nhớ khi thẻ bị hủy
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Bắt đầu chạm tay xuống -> Thẻ lún xuống & Rung nhẹ
      onTapDown: (_) {
        _controller.forward();
        // HapticFeedback.lightImpact() tạo độ rung nhẹ như chạm vào phím cơ
        HapticFeedback.lightImpact();
      },
      // Nhấc tay lên thành công -> Nảy lên và thực hiện hành động chuyển trang
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      // Vuốt trượt đi chỗ khác (Hủy bấm) -> Nảy lên về cũ nhưng không làm gì cả
      onTapCancel: () {
        _controller.reverse();
      },
      // ScaleTransition sẽ liên tục vẽ lại widget con với tỷ lệ lấy từ _scaleAnimation
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}
