import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import '../models/recipe.dart';
import '../models/ingredient.dart';
import '../core/app_theme.dart';
import '../viewmodels/auth_provider.dart';
import '../services/image_upload_service.dart';

class IngControllers {
  final name = TextEditingController();
  final amount = TextEditingController();
  final unit = TextEditingController();
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

  final _titleCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _servingsCtrl = TextEditingController();
  Difficulty _difficulty = Difficulty.medium;

  final List<IngControllers> _ingCtrls = [];
  final List<TextEditingController> _stepCtrls = [];

  // Khai báo các biến cho việc chọn và tải ảnh
  XFile? _selectedImage;
  String? _existingImageUrl;
  final _imagePicker = ImagePicker();
  final _uploadService = ImageUploadService();

  @override
  void initState() {
    super.initState();
    if (widget.existingRecipe != null) {
      final r = widget.existingRecipe!;
      _titleCtrl.text = r.title;
      _existingImageUrl = r.imageUrl; // Lấy URL ảnh cũ nếu đang Edit
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
      _servingsCtrl.text = '1';
      _ingCtrls.add(IngControllers());
      _stepCtrls.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _durationCtrl.dispose();
    _servingsCtrl.dispose();
    for (var c in _ingCtrls) {
      c.dispose();
    }
    for (var c in _stepCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  // Hàm mở bộ sưu tập để chọn ảnh
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Nén ảnh 70% để tiết kiệm dung lượng Storage
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = pickedFile;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi chọn ảnh: $e')));
      }
    }
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    // Chặn người dùng lưu nếu tạo món mới mà lười không chọn ảnh
    if (widget.existingRecipe == null && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chưa có ảnh món ăn. Chọn 1 tấm thật đẹp nhé!'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    setState(() => _isLoading = true);
    try {
      // 1. LUỒNG XỬ LÝ ẢNH
      String finalImageUrl = _existingImageUrl ?? '';

      if (_selectedImage != null) {
        final uploadedUrl = await _uploadService.uploadRecipeImage(
          _selectedImage!,
          currentUser.uid,
        );
        if (uploadedUrl == null) {
          throw Exception('Tải ảnh lên máy chủ thất bại. Vui lòng thử lại.');
        }
        finalImageUrl = uploadedUrl;
      }

      // 2. LUỒNG LƯU DỮ LIỆU CHÍNH
      final docRef = widget.existingRecipe == null
          ? FirebaseFirestore.instance.collection('recipes').doc()
          : FirebaseFirestore.instance
                .collection('recipes')
                .doc(widget.existingRecipe!.id);

      final ingredients = _ingCtrls
          .map(
            (c) => Ingredient(
              id: const Uuid().v4(),
              name: c.name.text.trim(),
              amount: double.tryParse(c.amount.text.trim()) ?? 1.0,
              unit: c.unit.text.trim(),
            ),
          )
          .toList();

      final steps = _stepCtrls
          .map((c) => c.text.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final recipe = Recipe(
        id: docRef.id,
        title: _titleCtrl.text.trim(),
        imageUrl: finalImageUrl, // Gán URL thật vừa đẩy lên Firebase
        durationMinutes: int.tryParse(_durationCtrl.text.trim()) ?? 30,
        difficulty: _difficulty,
        defaultServings: int.tryParse(_servingsCtrl.text.trim()) ?? 1,
        ingredients: ingredients,
        steps: steps,
        authorId: widget.existingRecipe?.authorId ?? currentUser.uid,
        authorName:
            widget.existingRecipe?.authorName ??
            (currentUser.displayName ?? 'Người dùng'),
        createdAt: widget.existingRecipe?.createdAt,
        isPublic: true,
      );

      await docRef.set(recipe.toMap(), SetOptions(merge: true));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingRecipe == null
                  ? '🎉 Đã thêm công thức thành công!'
                  : '✅ Đã cập nhật thành công!',
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
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppTheme.error),
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
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: AppTheme.primary,
                  strokeWidth: 2,
                ),
              ),
            )
          else
            TextButton.icon(
              onPressed: _saveRecipe,
              icon: const Icon(Icons.save_rounded, color: AppTheme.primary),
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
            _sectionTitle('Thông tin cơ bản'),
            _field(_titleCtrl, 'Tên món ăn', Icons.restaurant_menu),
            const SizedBox(height: AppTheme.spacingM),

            // GIAO DIỆN CHỌN ẢNH MỚI
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: AppTheme.radiusM,
                  border: Border.all(
                    color: AppTheme.primary.withOpacity(0.5),
                    style: BorderStyle.solid,
                  ),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: AppTheme.radiusM,
                        child: Image.file(
                          File(_selectedImage!.path),
                          fit: BoxFit.cover,
                          // BẮT LỖI FILE HỎNG: Hiển thị icon thay vì văng màn hình đỏ
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: AppTheme.error,
                                  size: 50,
                                ),
                              ),
                        ),
                      )
                    : (_existingImageUrl != null &&
                          _existingImageUrl!.isNotEmpty)
                    ? ClipRRect(
                        borderRadius: AppTheme.radiusM,
                        child: Image.network(
                          _existingImageUrl!,
                          fit: BoxFit.cover,
                          // BẮT LỖI MẠNG / LINK HỎNG
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                                child: Icon(
                                  Icons.wifi_off,
                                  color: AppTheme.error,
                                  size: 50,
                                ),
                              ),
                        ),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            color: AppTheme.primary,
                            size: 40,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Nhấn để tải ảnh món ăn lên',
                            style: AppTheme.bodyText,
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),

            Row(
              children: [
                Expanded(
                  child: _field(
                    _durationCtrl,
                    'Phút',
                    Icons.schedule,
                    isNumber: true,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: _field(
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
              decoration: _deco('Độ khó', Icons.local_fire_department),
              items: const [
                DropdownMenuItem(value: Difficulty.easy, child: Text('Dễ')),
                DropdownMenuItem(
                  value: Difficulty.medium,
                  child: Text('Trung bình'),
                ),
                DropdownMenuItem(value: Difficulty.hard, child: Text('Khó')),
              ],
              onChanged: (val) => setState(() => _difficulty = val!),
            ),
            const SizedBox(height: AppTheme.spacingL),

            // NGUYÊN LIỆU
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionTitle('Nguyên liệu'),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppTheme.success),
                  onPressed: () =>
                      setState(() => _ingCtrls.add(IngControllers())),
                ),
              ],
            ),
            ..._ingCtrls.asMap().entries.map((e) {
              final idx = e.key;
              final ctrl = e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: _field(ctrl.name, 'Tên', null)),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: _field(ctrl.amount, 'SL', null, isNumber: true),
                    ),
                    const SizedBox(width: 8),
                    Expanded(flex: 1, child: _field(ctrl.unit, 'ĐV', null)),
                    IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: AppTheme.error,
                      ),
                      onPressed: () =>
                          setState(() => _ingCtrls.removeAt(idx).dispose()),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: AppTheme.spacingL),

            // CÁCH LÀM
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionTitle('Các bước làm'),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppTheme.success),
                  onPressed: () =>
                      setState(() => _stepCtrls.add(TextEditingController())),
                ),
              ],
            ),
            ..._stepCtrls.asMap().entries.map((e) {
              final idx = e.key;
              final ctrl = e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
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
                        decoration: _deco('Mô tả bước ${idx + 1}', null),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: AppTheme.error,
                      ),
                      onPressed: () =>
                          setState(() => _stepCtrls.removeAt(idx).dispose()),
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

  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(t, style: AppTheme.heading2),
  );

  InputDecoration _deco(String label, IconData? icon, {String? hint}) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12, color: AppTheme.textLight),
        prefixIcon: icon != null ? Icon(icon, color: AppTheme.primary) : null,
        filled: true,
        fillColor: AppTheme.surface,
        border: OutlineInputBorder(
          borderRadius: AppTheme.radiusM,
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      );

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData? icon, {
    bool isNumber = false,
    String? hint,
  }) => TextFormField(
    controller: ctrl,
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    validator: (v) => v == null || v.trim().isEmpty ? 'Bắt buộc' : null,
    decoration: _deco(label, icon, hint: hint),
  );
}
