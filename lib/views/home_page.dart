import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../viewmodels/contact_provider.dart';
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
                    const _ContactSection(),
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
// CONTACT SECTION — Layout từ Figma Home: Title + form liên hệ + footer links
// ===========================================================================
// Nhớ đổi thành ConsumerStatefulWidget
// ===========================================================================
// CONTACT SECTION — Được refactor hoàn chỉnh bằng Riverpod ConsumerState
// ===========================================================================
class _ContactSection extends ConsumerStatefulWidget {
  const _ContactSection();

  @override
  ConsumerState<_ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends ConsumerState<_ContactSection> {
  final _nameCtrl = TextEditingController();
  final _surnameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _surnameCtrl.dispose();
    _emailCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    ref
        .read(contactFormProvider.notifier)
        .submitContact(_nameCtrl.text, _emailCtrl.text, _messageCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(contactFormProvider);
    final isSuccess = formState == ContactFormState.success;
    final isLoading = formState == ContactFormState.loading;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      child: Column(
        children: [
          const Text(
            'Liên hệ với chúng tôi',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Góp ý, báo lỗi, hoặc đề xuất công thức mới',
            textAlign: TextAlign.center,
            style: AppTheme.bodyText,
          ),
          const SizedBox(height: 24),

          // ---- FORM CARD ----
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: AppTheme.radiusL,
              boxShadow: AppTheme.softShadow,
            ),
            child: isSuccess
                ? _buildSuccessState()
                : _buildFormFields(isLoading),
          ),

          const SizedBox(height: 32),

          // ---- FOOTER ----
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildFormFields(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: _field(_nameCtrl, 'Họ', 'Nguyễn')),
            const SizedBox(width: 12),
            Expanded(child: _field(_surnameCtrl, 'Tên', 'Minh Tuấn')),
          ],
        ),
        const SizedBox(height: 12),
        _field(
          _emailCtrl,
          'Email',
          'email@example.com',
          type: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _messageCtrl,
          maxLines: 4,
          decoration: _deco('Lời nhắn', 'Nhập nội dung...'),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.textDark,
              shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusM),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    'Gửi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Text('✅', style: TextStyle(fontSize: 48)),
          SizedBox(height: 12),
          Text(
            'Đã gửi thành công!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(height: 4),
          Text('Cảm ơn bạn đã góp ý 🙏', style: AppTheme.bodyText),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Divider(color: Colors.grey.shade200, thickness: 1),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.school_rounded,
                color: AppTheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Phenikaa University',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _socialIcon(Icons.facebook, 'Facebook'),
            const SizedBox(width: 16),
            _socialIcon(Icons.camera_alt_outlined, 'Instagram'),
            const SizedBox(width: 16),
            _socialIcon(Icons.play_circle_outline, 'YouTube'),
            const SizedBox(width: 16),
            _socialIcon(Icons.link, 'LinkedIn'),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _footerColumn('Thành viên', [
                'Nguyễn Minh Tuấn',
                'MSSV: 22010478',
                'Nguyễn Công Giáp',
                'MSSV: 22010369',
              ]),
            ),
            Expanded(
              child: _footerColumn('Công nghệ', [
                'Flutter',
                'Firebase',
                'Riverpod',
                'Cloud Firestore',
              ]),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '© 2026 Recipe App · Phenikaa University',
          style: AppTheme.bodyText.copyWith(fontSize: 11),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _socialIcon(IconData icon, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.background,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Icon(icon, size: 18, color: AppTheme.textDark),
      ),
    );
  }

  Widget _footerColumn(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(item, style: AppTheme.bodyText.copyWith(fontSize: 12)),
          ),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    String hint, {
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      decoration: _deco(label, hint),
    );
  }

  InputDecoration _deco(String label, String hint) => InputDecoration(
    labelText: label,
    hintText: hint,
    filled: true,
    fillColor: AppTheme.background,
    border: OutlineInputBorder(
      borderRadius: AppTheme.radiusM,
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );
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
