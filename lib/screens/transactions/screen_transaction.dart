import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:money_management/db/category/category_db.dart';
import 'package:money_management/db/transactions/transaction_db.dart';
import 'package:money_management/models/category/category_model.dart';
import 'package:money_management/models/transaction/transaction_model.dart';

class ScreenTransaction extends StatelessWidget {
  const ScreenTransaction({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TransactionDB.instance.refresh();
    CategoryDB().refreshUI();

    return ValueListenableBuilder(
        valueListenable: TransactionDB.instance.transactionListNotifier,
        builder: (BuildContext ctx, List<TransactionModel> newList, Widget? _) {
          return ListView.separated(
            padding: const EdgeInsets.all(10),
            itemBuilder: (ctx, index) {
              final _value = newList[index];
              return Slidable(
                key: Key(_value.id.toString()),
                startActionPane: ActionPane(
                  motion:DrawerMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (ctx) {
                        TransactionDB.instance.deleteTransaction(_value.id!);
                      },
                      foregroundColor: Colors.red,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                  ],
                ),
                child: Card(
                  elevation: 3,
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 50,
                      child: Text(
                        parseDate(_value.date),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13),
                      ),
                      backgroundColor: _value.type == CategoryType.income
                          ? Colors.green
                          : Colors.red,
                    ),
                    title: Text("RS ${_value.amount.toString()}"),
                    subtitle: Text(_value.category.name),
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

  String parseDate(DateTime date) {
    final _date = DateFormat.yMMMEd().format(date);
    final _splitedDate = _date.split(',');
    return '${_splitedDate[1]}\n${_splitedDate[2]}';
  }
}
