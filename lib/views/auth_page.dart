import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_theme.dart';
import '../services/auth_service.dart';
import '../widgets/app_cached_image.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  // ---- State ----
  bool _isLogin = true;         // true = form Login, false = form Register
  bool _isLoading = false;
  bool _obscurePassword = true;

  // ---- Controllers ----
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  // ---- Animation cho việc mở rộng form (thêm field Tên) ----
  late AnimationController _animCtrl;
  late Animation<double> _expandAnim;   // chiều cao field Tên
  late Animation<double> _fadeAnim;     // opacity field Tên
  late Animation<double> _slideAnim;    // slide nhẹ toàn bộ form

  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _expandAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _fadeAnim   = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _slideAnim  = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ===========================================================================
  // TOGGLE: Chuyển qua lại Login ↔ Register với animation
  // ===========================================================================
  void _toggleMode() {
    HapticFeedback.selectionClick();
    setState(() => _isLogin = !_isLogin);
    if (_isLogin) {
      _animCtrl.reverse();  // Thu gọn field Tên
    } else {
      _animCtrl.forward();  // Mở rộng thêm field Tên
    }
    _formKey.currentState?.reset();
  }

  // ===========================================================================
  // SUBMIT: Login hoặc Register tùy trạng thái hiện tại
  // ===========================================================================
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus(); // Đóng bàn phím

    final AuthResult result;
    if (_isLogin) {
      result = await _authService.login(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );
    } else {
      result = await _authService.register(
        displayName: _nameCtrl.text,
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!result.success) {
      _showError(result.errorMessage!);
    }
    // Nếu success -> authStateProvider sẽ emit user mới -> MainLayout tự navigate
  }

  // ===========================================================================
  // GOOGLE SIGN-IN
  // ===========================================================================
  Future<void> _googleSignIn() async {
    setState(() => _isLoading = true);
    final result = await _authService.signInWithGoogle();
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (!result.success) _showError(result.errorMessage!);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusM),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      // Tránh overflow khi bàn phím bật lên
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // ---- HERO ẢNH (đồng nhất với HomeHeroHeader) ----
              _buildHero(),

              // ---- FORM CARD ----
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: AppTheme.radiusL,
                    boxShadow: AppTheme.softShadow,
                  ),
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ---- Tab Toggle: Đăng nhập / Đăng ký ----
                        _buildToggleTab(),
                        const SizedBox(height: AppTheme.spacingL),

                        // ---- Field Tên (chỉ hiện khi Register) ----
                        _buildNameField(),

                        // ---- Email ----
                        _buildEmailField(),
                        const SizedBox(height: AppTheme.spacingM),

                        // ---- Password ----
                        _buildPasswordField(),
                        const SizedBox(height: AppTheme.spacingL),

                        // ---- Nút Submit chính ----
                        _buildSubmitButton(),
                        const SizedBox(height: AppTheme.spacingM),

                        // ---- Divider "hoặc" ----
                        _buildDivider(),
                        const SizedBox(height: AppTheme.spacingM),

                        // ---- Nút Google ----
                        _buildGoogleButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // HERO: Ảnh nền + gradient + tagline — đồng nhất với HomeHeroHeader
  // ===========================================================================
  Widget _buildHero() {
    return Stack(
      children: [
        // Ảnh nền
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(32),
          ),
          child: SizedBox(
            height: 280,
            width: double.infinity,
            child: AppCachedImage(
              imageUrl:
                  'https://images.unsplash.com/photo-1490645935967-10de6ba17061?q=80&w=1000&auto=format&fit=crop',
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Gradient đen phía dưới — y hệt HomeHeroHeader
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(32),
          ),
          child: Container(
            height: 280,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black87, Colors.transparent],
              ),
            ),
          ),
        ),
        // Tagline
        const Positioned(
          left: 24,
          bottom: 36,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nấu ngon mỗi ngày 🍳',
                style: AppTheme.heroTitleStyle,
              ),
              SizedBox(height: 6),
              Text(
                'Khám phá và chia sẻ công thức với cộng đồng',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  shadows: [Shadow(color: Colors.black87, blurRadius: 6)],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // TOGGLE TAB: Đăng nhập | Đăng ký
  // ===========================================================================
  Widget _buildToggleTab() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: AppTheme.radiusM,
      ),
      child: Row(
        children: [
          _tabItem(label: 'Đăng nhập', isActive: _isLogin),
          _tabItem(label: 'Đăng ký', isActive: !_isLogin),
        ],
      ),
    );
  }

  Widget _tabItem({required String label, required bool isActive}) {
    return Expanded(
      child: GestureDetector(
        onTap: isActive ? null : _toggleMode,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.surface : Colors.transparent,
            borderRadius: AppTheme.radiusS,
            boxShadow: isActive ? AppTheme.softShadow : null,
          ),
          alignment: Alignment.center,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? AppTheme.primary : AppTheme.textLight,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // FIELD TÊN: AnimatedSize để trượt xuống mượt mà khi toggle Register
  // ===========================================================================
  Widget _buildNameField() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      child: _isLogin
          ? const SizedBox.shrink()
          : FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDecoration(
                      label: 'Tên hiển thị',
                      icon: Icons.person_outline,
                    ),
                    validator: (v) {
                      if (_isLogin) return null; // Bỏ qua validation khi Login
                      if (v == null || v.trim().isEmpty) return 'Nhập tên của bạn nhé';
                      if (v.trim().length < 2) return 'Tên ít nhất 2 ký tự';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                ],
              ),
            ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailCtrl,
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      decoration: _inputDecoration(label: 'Email', icon: Icons.email_outlined),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Nhập email của bạn nhé';
        if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(v.trim())) {
          return 'Email không đúng định dạng';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordCtrl,
      obscureText: _obscurePassword,
      decoration: _inputDecoration(
        label: 'Mật khẩu',
        icon: Icons.lock_outline,
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: AppTheme.textLight,
            size: 20,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Nhập mật khẩu của bạn nhé';
        if (!_isLogin && v.length < 6) return 'Mật khẩu ít nhất 6 ký tự';
        return null;
      },
    );
  }

  // ===========================================================================
  // NÚT SUBMIT
  // ===========================================================================
  Widget _buildSubmitButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 52,
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: AppTheme.radiusM,
        boxShadow: AppTheme.primaryShadow, // Cam phát sáng — đồng nhất app
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppTheme.radiusM,
          onTap: _isLoading ? null : _submit,
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    _isLogin ? 'Đăng nhập' : 'Tạo tài khoản',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // DIVIDER "hoặc"
  // ===========================================================================
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('hoặc', style: AppTheme.bodyText),
        ),
        Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
      ],
    );
  }

  // ===========================================================================
  // NÚT GOOGLE
  // ===========================================================================
  Widget _buildGoogleButton() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: AppTheme.radiusM,
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: AppTheme.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppTheme.radiusM,
          onTap: _isLoading ? null : _googleSignIn,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Google bằng Text có màu (tránh cần asset file)
              const _GoogleLogo(),
              const SizedBox(width: 10),
              Text(
                'Tiếp tục với Google',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // HELPER: InputDecoration đồng nhất toàn form
  // ===========================================================================
  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppTheme.primary, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppTheme.background,
      border: OutlineInputBorder(
        borderRadius: AppTheme.radiusM,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppTheme.radiusM,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppTheme.radiusM,
        borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppTheme.radiusM,
        borderSide: const BorderSide(color: AppTheme.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppTheme.radiusM,
        borderSide: const BorderSide(color: AppTheme.error, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

// ===========================================================================
// WIDGET PHỤ: Logo Google bằng RichText (không cần asset)
// ===========================================================================
class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // 4 góc phần tư màu Google
    final colors = [
      const Color(0xFF4285F4), // Xanh dương — phải trên
      const Color(0xFF34A853), // Xanh lá   — phải dưới
      const Color(0xFFFBBC05), // Vàng       — trái dưới
      const Color(0xFFEA4335), // Đỏ         — trái trên
    ];

    for (int i = 0; i < 4; i++) {
      final paint = Paint()..color = colors[i];
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        (i * 90 - 45) * (3.14159 / 180),
        90 * (3.14159 / 180),
        true,
        paint,
      );
    }

    // Vòng trắng giữa
    canvas.drawCircle(c, r * 0.55, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
