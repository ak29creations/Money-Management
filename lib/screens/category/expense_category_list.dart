import 'package:flutter/material.dart';
import 'package:money_management/db/category/category_db.dart';
import 'package:money_management/models/category/category_model.dart';

class ExpenseCategoryList extends StatelessWidget {
  const ExpenseCategoryList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: CategoryDB().expenseCategoryListListener,
        builder: (BuildContext ctx, List<CategoryModel> newList, Widget? _) {
          return ListView.separated(
            itemBuilder: (ctx, index) {
              final category = newList[index];
              return Card(
                elevation: 3,
                child: ListTile(
                  title: Text(category.name),
                  trailing: IconButton(
                    onPressed: () {
                      CategoryDB.instance.deleteCategory(category.id!);
                    },
                    icon: const Icon(Icons.delete,
                      color: Colors.red,
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (ctx, index) {
              return SizedBox(
                height: 5,
              );
            },
            itemCount: newList.length,
          );
        });
  }
}
