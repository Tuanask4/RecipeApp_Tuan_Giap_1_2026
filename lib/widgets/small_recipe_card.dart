import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/app_cached_image.dart';
import '../models/recipe.dart';
import '../views/recipe_detail_page.dart';
import 'animated_scale_card.dart';
import '../core/app_theme.dart'; // IMPORT THEME

class SmallRecipeCard extends StatelessWidget {
  final Recipe recipe;
  const SmallRecipeCard({super.key, required this.recipe});

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
        margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: AppTheme.radiusM,
          boxShadow: AppTheme.softShadow,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: AppTheme.radiusS,
              child: AppCachedImage(
                imageUrl: recipe.imageUrl,
                height: 80,
                width: 80,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 14,
                        color: AppTheme.textLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.durationMinutes} phút',
                        style: AppTheme.bodyText,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.favorite_border,
                color: AppTheme.textLight,
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
