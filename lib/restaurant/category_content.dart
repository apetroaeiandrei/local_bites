import 'package:models/food_category_model.dart';
import 'package:models/food_model.dart';

class CategoryContent {
  final FoodCategoryModel category;
  final List<FoodModel> foods;

  CategoryContent({
    required this.category,
    required this.foods,
  });

}