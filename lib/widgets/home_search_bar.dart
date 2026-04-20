import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/recipe_provider.dart';
import '../views/smart_pantry_page.dart';
import '../core/app_theme.dart'; // IMPORT THEME

class HomeSearchBar extends ConsumerWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // Ô TÌM KIẾM
        Expanded(
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
            decoration: BoxDecoration(
              color: AppTheme.surface, // Dùng màu thẻ chuẩn
              borderRadius: AppTheme.radiusL, // Bo góc lớn chuẩn
              boxShadow: AppTheme.softShadow, // Đổ bóng mềm
            ),
            child: TextField(
              onChanged: (text) =>
                  ref.read(searchQueryProvider.notifier).onTextChanged(text),
              decoration: const InputDecoration(
                icon: Icon(Icons.search, color: AppTheme.primary, size: 22),
                hintText: 'Tìm kiếm công thức...',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spacingS),

        // NÚT TỦ LẠNH (SMART PANTRY)
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SmartPantryPage()),
          ),
          child: Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: AppTheme.primary, // Màu cam thương hiệu
              shape: BoxShape.circle,
              boxShadow: AppTheme.primaryShadow, // Đổ bóng cam phát sáng
            ),
            child: const Icon(Icons.kitchen, color: Colors.white, size: 22),
          ),
        ),
      ],
    );
  }
}
