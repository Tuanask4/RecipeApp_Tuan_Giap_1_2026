// lib/data/mock_data.dart
import '../models/recipe_model.dart';

final List<Recipe> dummyRecipes = [
  Recipe(
    id: 'r1',
    title: 'Phở Bò Hà Nội',
    imageUrl: 'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?q=80&w=1000&auto=format&fit=crop',
    prepTime: 120,
    difficulty: 'Khó',
    ingredients: [
      Ingredient(name: 'Bánh phở', quantity: 500, unit: 'g'),
      Ingredient(name: 'Thịt bò', quantity: 300, unit: 'g'),
      Ingredient(name: 'Xương ống', quantity: 1, unit: 'kg'),
    ],
    steps: [
      'Ninh xương ống trong 2 tiếng để lấy nước dùng.',
      'Thái mỏng thịt bò.',
      'Chần bánh phở qua nước sôi.',
      'Cho phở, thịt bò ra bát, chan nước dùng nóng lên.'
    ],
  ),
  Recipe(
    id: 'r2',
    title: 'Bánh Mì Trứng',
    imageUrl: 'https://images.unsplash.com/photo-1525351484163-7529414344d8?q=80&w=1000&auto=format&fit=crop',
    prepTime: 10,
    difficulty: 'Dễ',
    ingredients: [
      Ingredient(name: 'Bánh mì', quantity: 1, unit: 'ổ'),
      Ingredient(name: 'Trứng gà', quantity: 2, unit: 'quả'),
      Ingredient(name: 'Tương ớt', quantity: 1, unit: 'thìa'),
    ],
    steps: [
      'Ốp la 2 quả trứng.',
      'Rạch dọc ổ bánh mì, cho trứng vào.',
      'Thêm tương ớt, dưa leo tùy thích và thưởng thức.'
    ],
  ),
];