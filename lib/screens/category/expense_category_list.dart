import 'package:flutter/material.dart';
import 'package:money_management/db/category/category_db.dart';
import 'package:money_management/db/transactions/transaction_db.dart';
import 'package:money_management/models/category/category_model.dart';
import 'package:money_management/models/transaction/transaction_model.dart';

class ExpenseCategoryList extends StatelessWidget {
  const ExpenseCategoryList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: CategoryDB().expenseCategoryListListener,
        builder: (BuildContext ctx, List<CategoryModel> newList, Widget? _) {
          return newList.isEmpty
              ? const Center(child: Text("⚠️ No Expense Categories Found"))
              : ListView.separated(
                  itemBuilder: (ctx, index) {
                    final category = newList[index];
                    return Card(
                      elevation: 3,
                      child: ListTile(
                        title: Text(
                          category.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: IconButton(
                          onPressed: () async {
                            List<TransactionModel> result = await TransactionDB
                                .instance
                                .getTransactionCategories(
                                    category.type, category.name);

                            if (result.isEmpty) {
                              CategoryDB.instance.deleteCategory(category.id!);
                            } else {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Can’t Delete this Expense category. Transactions have been made."),
                                ),
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (ctx, index) {
                    return const SizedBox(
                      height: 5,
                    );
                  },
                  itemCount: newList.length,
                );
        });
  }
}
