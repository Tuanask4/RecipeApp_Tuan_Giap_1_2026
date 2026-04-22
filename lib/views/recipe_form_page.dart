import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/recipe.dart';
import '../models/ingredient.dart';
import '../core/app_theme.dart';

// Lớp hỗ trợ quản lý Controller cho Nguyên liệu
class IngControllers {
  final name = TextEditingController();
  final amount = TextEditingController();
  final unit = TextEditingController();
}

class RecipeFormPage extends StatefulWidget {
  final Recipe? existingRecipe; // Nếu null => Thêm mới. Nếu có => Sửa.
  const RecipeFormPage({super.key, this.existingRecipe});

  @override
  State<RecipeFormPage> createState() => _RecipeFormPageState();
}

class _RecipeFormPageState extends State<RecipeFormPage> {
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
  // HÀM LƯU DỮ LIỆU LÊN FIREBASE
  // =======================================================================
  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // 1. Thu thập danh sách nguyên liệu
      List<Ingredient> finalIngredients = _ingCtrls.map((ctrl) {
        return Ingredient(
          id: const Uuid().v4(), // Tạo ID ngẫu nhiên cho nguyên liệu
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

      // 3. Xác định tài liệu trên Firebase
      final docRef = widget.existingRecipe == null
          ? FirebaseFirestore.instance.collection('recipes').doc() // Thêm mới (Tự sinh ID)
          : FirebaseFirestore.instance.collection('recipes').doc(widget.existingRecipe!.id); // Ghi đè ID cũ

      // 4. Đóng gói thành Model
      final newRecipe = Recipe(
        id: docRef.id,
        title: _titleCtrl.text.trim(),
        imageUrl: _imageCtrl.text.trim(),
        durationMinutes: int.tryParse(_durationCtrl.text.trim()) ?? 30,
        difficulty: _difficulty,
        defaultServings: int.tryParse(_servingsCtrl.text.trim()) ?? 1,
        ingredients: finalIngredients,
        steps: finalSteps,
      );

      // 5. Bắn lên Mây 🚀
      await docRef.set(newRecipe.toMap());

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingRecipe == null ? 'Đã thêm thành công!' : 'Đã cập nhật thành công!'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppTheme.error));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(widget.existingRecipe == null ? 'Thêm Món Mới' : 'Sửa Món Ăn', style: AppTheme.heading2),
        backgroundColor: AppTheme.background,
        elevation: 0,
        actions: [
          if (_isLoading)
            const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: AppTheme.primary))
          else
            TextButton.icon(
              onPressed: _saveRecipe,
              icon: const Icon(Icons.save, color: AppTheme.primary),
              label: const Text('Lưu', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 16)),
            )
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
                Expanded(child: _buildTextField(_durationCtrl, 'Phút', Icons.schedule, isNumber: true)),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(child: _buildTextField(_servingsCtrl, 'Số người', Icons.people, isNumber: true)),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            DropdownButtonFormField<Difficulty>(
              value: _difficulty,
              decoration: _inputDecoration('Độ khó', Icons.local_fire_department),
              items: Difficulty.values.map((d) {
                return DropdownMenuItem(value: d, child: Text(d.name.toUpperCase()));
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
                  onPressed: () => setState(() => _ingCtrls.add(IngControllers())),
                )
              ],
            ),
            ..._ingCtrls.asMap().entries.map((entry) {
              int idx = entry.key;
              IngControllers ctrl = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: _buildTextField(ctrl.name, 'Tên', null)),
                    const SizedBox(width: 8),
                    Expanded(flex: 1, child: _buildTextField(ctrl.amount, 'SL', null, isNumber: true)),
                    const SizedBox(width: 8),
                    Expanded(flex: 1, child: _buildTextField(ctrl.unit, 'ĐV', null)),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: AppTheme.error),
                      onPressed: () => setState(() => _ingCtrls.removeAt(idx)),
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
                  onPressed: () => setState(() => _stepCtrls.add(TextEditingController())),
                )
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
                      child: CircleAvatar(radius: 12, backgroundColor: AppTheme.primary, child: Text('${idx + 1}', style: const TextStyle(fontSize: 12, color: Colors.white))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: ctrl,
                        maxLines: 2,
                        decoration: _inputDecoration('Mô tả bước ${idx + 1}', null),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: AppTheme.error),
                      onPressed: () => setState(() => _stepCtrls.removeAt(idx)),
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
      border: OutlineInputBorder(borderRadius: AppTheme.radiusM, borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData? icon, {bool isNumber = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (val) => val == null || val.trim().isEmpty ? 'Bắt buộc' : null,
      decoration: _inputDecoration(label, icon),
    );
  }
}