import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/recipe.dart';
import '../models/ingredient.dart';
import '../core/app_theme.dart';
import '../viewmodels/auth_provider.dart';

// Lớp hỗ trợ quản lý Controller cho Nguyên liệu
class IngControllers {
  final name = TextEditingController();
  final amount = TextEditingController();
  final unit = TextEditingController();

  // FIX: Thêm hàm dispose để dọn dẹp bộ nhớ của riêng cụm controller này
  void dispose() {
    name.dispose();
    amount.dispose();
    unit.dispose();
  }
}

class RecipeFormPage extends ConsumerStatefulWidget {
  final Recipe? existingRecipe;
  const RecipeFormPage({super.key, this.existingRecipe});

  @override
  ConsumerState<RecipeFormPage> createState() => _RecipeFormPageState();
}

class _RecipeFormPageState extends ConsumerState<RecipeFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers cho thông tin cơ bản
  final _titleCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _servingsCtrl = TextEditingController();
  Difficulty _difficulty = Difficulty.medium;

  // Danh sách Controllers động cho Nguyên liệu và Cách làm
  final List<IngControllers> _ingCtrls = [];
  final List<TextEditingController> _stepCtrls = [];

  @override
  void initState() {
    super.initState();
    // NẾU LÀ CHẾ ĐỘ SỬA: Đổ dữ liệu cũ lên form
    if (widget.existingRecipe != null) {
      final r = widget.existingRecipe!;
      _titleCtrl.text = r.title;
      _imageCtrl.text = r.imageUrl;
      _durationCtrl.text = r.durationMinutes.toString();
      _servingsCtrl.text = r.defaultServings.toString();
      _difficulty = r.difficulty;

      for (var ing in r.ingredients) {
        final ctrl = IngControllers();
        ctrl.name.text = ing.name;
        ctrl.amount.text = ing.amount.toString();
        ctrl.unit.text = ing.unit;
        _ingCtrls.add(ctrl);
      }
      for (var step in r.steps) {
        _stepCtrls.add(TextEditingController(text: step));
      }
    } else {
      // NẾU LÀ CHẾ ĐỘ THÊM: Tạo sẵn 1 ô nguyên liệu và 1 ô cách làm trống
      _servingsCtrl.text = '1';
      _ingCtrls.add(IngControllers());
      _stepCtrls.add(TextEditingController());
    }
  }

  // =======================================================================
  // FIX: HÀM DỌN DẸP BỘ NHỚ KHI ĐÓNG TRANG (TRÁNH MEMORY LEAK)
  // =======================================================================
  @override
  void dispose() {
    _titleCtrl.dispose();
    _imageCtrl.dispose();
    _durationCtrl.dispose();
    _servingsCtrl.dispose();

    // Dọn dẹp toàn bộ controller trong danh sách động
    for (var ctrl in _ingCtrls) {
      ctrl.dispose();
    }
    for (var ctrl in _stepCtrls) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    // Kiểm tra user đã đăng nhập chưa trước khi làm bất cứ gì
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn cần đăng nhập để lưu công thức.'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Thu thập danh sách nguyên liệu
      List<Ingredient> finalIngredients = _ingCtrls.map((ctrl) {
        return Ingredient(
          id: const Uuid().v4(),
          name: ctrl.name.text.trim(),
          amount: double.tryParse(ctrl.amount.text.trim()) ?? 1.0,
          unit: ctrl.unit.text.trim(),
        );
      }).toList();

      // 2. Thu thập các bước làm (bỏ qua ô trống)
      List<String> finalSteps = _stepCtrls
          .map((c) => c.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      // 3. Xác định document trên Firebase
      final docRef = widget.existingRecipe == null
          ? FirebaseFirestore.instance.collection('recipes').doc()
          : FirebaseFirestore.instance
              .collection('recipes')
              .doc(widget.existingRecipe!.id);

      // 4. Đóng gói thành Model — gắn authorId và authorName từ user hiện tại
      final newRecipe = Recipe(
        id: docRef.id,
        title: _titleCtrl.text.trim(),
        imageUrl: _imageCtrl.text.trim(),
        durationMinutes: int.tryParse(_durationCtrl.text.trim()) ?? 30,
        difficulty: _difficulty,
        defaultServings: int.tryParse(_servingsCtrl.text.trim()) ?? 1,
        ingredients: finalIngredients,
        steps: finalSteps,
        // ===========================================================
        // Khi THÊM MỚI: gán user hiện tại làm tác giả
        // Khi SỬA: giữ nguyên authorId gốc, không cho đổi chủ sở hữu
        // ===========================================================
        authorId: widget.existingRecipe?.authorId ?? currentUser.uid,
        authorName: widget.existingRecipe?.authorName ??
            (currentUser.displayName ?? 'Người dùng'),
        createdAt: widget.existingRecipe?.createdAt, // null → serverTimestamp
        isPublic: true,
      );

      // 5. Lưu lên Firestore
      await docRef.set(newRecipe.toMap(), SetOptions(merge: true));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingRecipe == null
                  ? 'Đã thêm công thức thành công!'
                  : 'Đã cập nhật thành công!',
            ),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusM),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          widget.existingRecipe == null ? 'Thêm Món Mới' : 'Sửa Món Ăn',
          style: AppTheme.heading2,
        ),
        backgroundColor: AppTheme.background,
        elevation: 0,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          else
            TextButton.icon(
              onPressed: _saveRecipe,
              icon: const Icon(Icons.save, color: AppTheme.primary),
              label: const Text(
                'Lưu',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          physics: const BouncingScrollPhysics(),
          children: [
            // --- THÔNG TIN CƠ BẢN ---
            _buildSectionTitle('Thông tin cơ bản'),
            _buildTextField(_titleCtrl, 'Tên món ăn', Icons.restaurant_menu),
            const SizedBox(height: AppTheme.spacingM),
            _buildTextField(_imageCtrl, 'Đường dẫn Ảnh (URL)', Icons.image),
            const SizedBox(height: AppTheme.spacingM),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _durationCtrl,
                    'Phút',
                    Icons.schedule,
                    isNumber: true,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: _buildTextField(
                    _servingsCtrl,
                    'Số người',
                    Icons.people,
                    isNumber: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            DropdownButtonFormField<Difficulty>(
              value: _difficulty,
              decoration: _inputDecoration(
                'Độ khó',
                Icons.local_fire_department,
              ),
              items: Difficulty.values.map((d) {
                return DropdownMenuItem(
                  value: d,
                  child: Text(d.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (val) => setState(() => _difficulty = val!),
            ),
            const SizedBox(height: AppTheme.spacingL),

            // --- NGUYÊN LIỆU ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle('Nguyên liệu'),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppTheme.success),
                  onPressed: () =>
                      setState(() => _ingCtrls.add(IngControllers())),
                ),
              ],
            ),
            ..._ingCtrls.asMap().entries.map((entry) {
              int idx = entry.key;
              IngControllers ctrl = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildTextField(ctrl.name, 'Tên', null),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: _buildTextField(
                        ctrl.amount,
                        'SL',
                        null,
                        isNumber: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: _buildTextField(ctrl.unit, 'ĐV', null),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: AppTheme.error,
                      ),
                      onPressed: () {
                        setState(() {
                          // FIX: Giải phóng bộ nhớ của ô text bị xóa trước khi gỡ khỏi list
                          final removedCtrl = _ingCtrls.removeAt(idx);
                          removedCtrl.dispose();
                        });
                      },
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: AppTheme.spacingL),

            // --- CÁCH LÀM ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle('Các bước làm'),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppTheme.success),
                  onPressed: () =>
                      setState(() => _stepCtrls.add(TextEditingController())),
                ),
              ],
            ),
            ..._stepCtrls.asMap().entries.map((entry) {
              int idx = entry.key;
              TextEditingController ctrl = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: AppTheme.primary,
                        child: Text(
                          '${idx + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: ctrl,
                        maxLines: 2,
                        decoration: _inputDecoration(
                          'Mô tả bước ${idx + 1}',
                          null,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: AppTheme.error,
                      ),
                      onPressed: () {
                        setState(() {
                          // FIX: Giải phóng bộ nhớ của ô text bị xóa trước khi gỡ khỏi list
                          final removedCtrl = _stepCtrls.removeAt(idx);
                          removedCtrl.dispose();
                        });
                      },
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: AppTheme.heading2),
    );
  }

  InputDecoration _inputDecoration(String label, IconData? icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: AppTheme.primary) : null,
      filled: true,
      fillColor: AppTheme.surface,
      border: OutlineInputBorder(
        borderRadius: AppTheme.radiusM,
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String label,
    IconData? icon, {
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (val) => val == null || val.trim().isEmpty ? 'Bắt buộc' : null,
      decoration: _inputDecoration(label, icon),
    );
  }
}
