import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_theme.dart';
import '../viewmodels/recipe_provider.dart';
import '../views/smart_pantry_page.dart';

class HomeSearchBar extends ConsumerWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // 1. Ô Nhập liệu Tìm kiếm
        Expanded(
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: AppTheme.searchBarDecoration,
            child: TextField(
              onChanged: (text) {
                // Gọi thẳng Provider từ đây
                ref.read(searchQueryProvider.notifier).onTextChanged(text);
              },
              decoration: const InputDecoration(
                icon: Icon(
                  Icons.search,
                  color: AppTheme.primary,
                  size: 22,
                ),
                hintText: 'Tìm kiếm công thức...',
                border: InputBorder.none,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // 2. Nút bấm Tủ Lạnh Thông Minh (Smart Pantry)
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SmartPantryPage()),
          ),
          child: Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.kitchen, color: Colors.white, size: 22),
          ),
        ),
      ],
    );
  }
}
