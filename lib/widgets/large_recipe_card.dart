import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/app_cached_image.dart';
import '../models/recipe.dart';
import '../views/recipe_detail_page.dart';
import 'animated_scale_card.dart';
import '../core/app_theme.dart'; // IMPORT THEME

class LargeRecipeCard extends StatelessWidget {
  final Recipe recipe;
  const LargeRecipeCard({super.key, required this.recipe});

  String _getDifficultyText(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Dễ';
      case Difficulty.medium:
        return 'Trung bình';
      case Difficulty.hard:
        return 'Khó';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScaleCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecipeDetailPage(recipe: recipe),
        ),
      ),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: AppTheme.spacingM),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: AppTheme.radiusL,
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ), // Vừa khít với radiusL
              child: AppCachedImage(
                imageUrl: recipe.imageUrl,
                height: 140,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: AppTheme.heading2,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 16,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.durationMinutes} phút',
                        style: AppTheme.bodyText,
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                      const Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getDifficultyText(recipe.difficulty),
                        style: AppTheme.bodyText,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
