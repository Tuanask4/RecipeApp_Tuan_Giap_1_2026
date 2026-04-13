import 'package:flutter/material.dart';
import '../models/recipe.dart';

class RecipeDetailPage extends StatefulWidget {
  final Recipe recipe;
  const RecipeDetailPage({super.key, required this.recipe});

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  late int _currentServings;
  final Set<String> _checkedIngredients = {};
  final Set<int> _completedSteps = {};

  @override
  void initState() {
    super.initState();
    _currentServings = widget.recipe.defaultServings;
  }

  @override
  Widget build(BuildContext context) {
    final double multiplier = _currentServings / widget.recipe.defaultServings;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        // FIX LỖI KÉO: Thêm AlwaysScrollableScrollPhysics để luôn cho phép kéo giãn ảnh
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverAppBar(
            expandedHeight: 340.0,
            pinned: true,
            stretch: true, // Kích hoạt tính năng giãn
            backgroundColor: Colors.orange,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground, // Phóng to khi kéo xuống
              ],
              title: Text(
                widget.recipe.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black87, blurRadius: 12)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(widget.recipe.imageUrl, fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black54, Colors.transparent],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Phần Nguyên liệu ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Nguyên liệu',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 18),
                              color: _currentServings > 1
                                  ? Colors.orange
                                  : Colors.grey,
                              onPressed: _currentServings > 1
                                  ? () => setState(() => _currentServings--)
                                  : null,
                            ),
                            Text(
                              '$_currentServings người',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              color: Colors.orange,
                              onPressed: () =>
                                  setState(() => _currentServings++),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  ...widget.recipe.ingredients.map((ingredient) {
                    final dynamicIngredient = ingredient.copyWithMultiplier(
                      multiplier,
                    );
                    final isChecked = _checkedIngredients.contains(
                      ingredient.id,
                    );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: InkWell(
                        onTap: () => setState(() {
                          if (isChecked)
                            _checkedIngredients.remove(ingredient.id);
                          else
                            _checkedIngredients.add(ingredient.id);
                        }),
                        child: Row(
                          children: [
                            // Đồng bộ Icon màu xanh khi check
                            Icon(
                              isChecked
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              color: isChecked
                                  ? Colors.green
                                  : Colors.grey[400],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                dynamicIngredient.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isChecked
                                      ? Colors.green.withOpacity(0.7)
                                      : Colors.black87,
                                  // ĐỒNG BỘ: Gạch ngang màu xanh cho nguyên liệu
                                  decoration: isChecked
                                      ? TextDecoration.lineThrough
                                      : null,
                                  decorationColor: Colors.green,
                                  decorationThickness: 2,
                                ),
                              ),
                            ),
                            Text(
                              '${dynamicIngredient.amount.toStringAsFixed(dynamicIngredient.amount.truncateToDouble() == dynamicIngredient.amount ? 0 : 1)} ${dynamicIngredient.unit}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isChecked
                                    ? Colors.green.withOpacity(0.7)
                                    : Colors.orange,
                                decoration: isChecked
                                    ? TextDecoration.lineThrough
                                    : null,
                                decorationColor: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 32),

                  // --- Phần Cách làm ---
                  const Text(
                    'Cách làm',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  ...widget.recipe.steps.asMap().entries.map((entry) {
                    int idx = entry.key;
                    String step = entry.value;
                    bool isDone = _completedSteps.contains(idx);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: InkWell(
                        onTap: () => setState(() {
                          if (isDone)
                            _completedSteps.remove(idx);
                          else
                            _completedSteps.add(idx);
                        }),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDone ? Colors.green : Colors.orange,
                              ),
                              child: isDone
                                  ? const Icon(
                                      Icons.done,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  : Text(
                                      '${idx + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                step,
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.6,
                                  color: isDone
                                      ? Colors.green.withOpacity(0.8)
                                      : Colors.black87,
                                  decoration: isDone
                                      ? TextDecoration.lineThrough
                                      : null,
                                  decorationColor: Colors.green,
                                  decorationThickness: 2.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
