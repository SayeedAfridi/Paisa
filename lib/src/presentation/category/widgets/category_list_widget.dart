import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../main.dart';
import '../../../core/common.dart';
import '../../../data/category/model/category_model.dart';
import '../../../domain/category/entities/category.dart';
import '../../widgets/paisa_empty_widget.dart';
import '../bloc/category_bloc.dart';
import 'category_item_desktop_widget.dart';
import 'category_item_mobile_widget.dart';
import 'category_item_tablet_widget.dart';

class CategoryListWidget extends StatelessWidget {
  const CategoryListWidget({
    Key? key,
    required this.addCategoryBloc,
    this.crossAxisCount = 1,
  }) : super(key: key);

  final CategoryBloc addCategoryBloc;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<CategoryModel>>(
      valueListenable: getIt.get<Box<CategoryModel>>().listenable(),
      builder: (BuildContext context, value, Widget? child) {
        final List<Category> categories = value.values.toEntities();
        if (categories.isEmpty) {
          return EmptyWidget(
            icon: Icons.category,
            title: context.loc.emptyCategoriesLabel,
            description: context.loc.emptyCategoriesDescriptionLabel,
          );
        }
        return ScreenTypeLayout(
          breakpoints: const ScreenBreakpoints(
            tablet: 600,
            desktop: 700,
            watch: 300,
          ),
          mobile: ListView.builder(
            padding: const EdgeInsets.only(
              bottom: 124,
              left: 8,
              right: 8,
              top: 8,
            ),
            itemCount: categories.length,
            shrinkWrap: true,
            itemBuilder: (_, index) {
              final category = categories[index];
              return CategoryItemMobileWidget(
                category: category,
                onPressed: () =>
                    addCategoryBloc.add(CategoryDeleteEvent(category)),
              );
            },
          ),
          tablet: GridView.builder(
            padding: const EdgeInsets.only(
              bottom: 124,
              left: 8,
              right: 8,
              top: 8,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemCount: categories.length,
            shrinkWrap: true,
            itemBuilder: (_, index) {
              final category = categories[index];
              return CategoryItemTabletWidget(
                category: category,
                onPressed: () =>
                    addCategoryBloc.add(CategoryDeleteEvent(category)),
              );
            },
          ),
          desktop: SafeArea(
            child: GridView.builder(
              padding: const EdgeInsets.only(
                bottom: 124,
                left: 8,
                right: 8,
                top: 8,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
              ),
              itemCount: categories.length,
              shrinkWrap: true,
              itemBuilder: (_, index) {
                final category = categories[index];
                return CategoryItemDesktopWidget(
                  category: category,
                  onPressed: () =>
                      addCategoryBloc.add(CategoryDeleteEvent(category)),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
