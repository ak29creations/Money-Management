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

    return Column(
      children: [
        const IncomeExpenseTotal(),
        ValueListenableBuilder(
          valueListenable: TransactionDB.instance.transactionListNotifier,
          builder:
              (BuildContext ctx, List<TransactionModel> newList, Widget? _) {
            return Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25)),
                child: Container(
                  color: Colors.grey[200],
                  child: ListView.separated(
                    padding: const EdgeInsets.only(left: 10,right: 10,bottom: 10,top: 15),
                    itemBuilder: (ctx, index) {
                      final _value = newList[index];
                      return Slidable(
                        key: Key(_value.id.toString()),
                        startActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (ctx) {
                                TransactionDB.instance
                                    .deleteTransaction(_value.id!);
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
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              backgroundColor:
                                  _value.type == CategoryType.income
                                      ? Colors.green[300]
                                      : Colors.red[300],
                            ),
                            title: Text(
                              (_value.type == CategoryType.income
                                      ? "+ "
                                      : "- ") +
                                  "\u{20B9}${_value.amount.toString()}",
                              style: TextStyle(
                                color: _value.type == CategoryType.income
                                    ? Colors.green
                                    : Colors.red,
                                    fontWeight: FontWeight.bold,
                              ),
                              
                            ),
                            subtitle:
                                Text(_value.category + " - " + _value.purpose),
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
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String parseDate(DateTime date) {
    final _date = DateFormat('MMM d\nyyyy').format(date);
    return _date;
  }
}

class IncomeExpenseTotal extends StatelessWidget {
  const IncomeExpenseTotal({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 8, right: 8, bottom: 5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 250,
          color: Colors.pink[50],
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  'Welcome to Money Manager',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: ValueListenableBuilder(
                  valueListenable: TransactionDB.instance.totalNotifier,
                  builder: (BuildContext ctx, double total, _) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 80,
                        width: 340,
                        color: Colors.blue[100],
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Total",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Text(
                                "\u{20B9} " + total.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ValueListenableBuilder(
                    valueListenable: TransactionDB.instance.incomeTotalNotifier,
                    builder: (BuildContext ctx, double incomeTotal, _) {
                      return Padding(
                        padding: const EdgeInsets.all(3),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 100,
                            width: 170,
                            color: Colors.green[100],
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10, top: 9),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Income\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    "+ \u{20B9} " + incomeTotal.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable:
                        TransactionDB.instance.expenseTotalNotifier,
                    builder: (BuildContext ctx, double expenseTotal, _) {
                      return Padding(
                        padding: const EdgeInsets.all(3),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 100,
                            width: 170,
                            color: Colors.red[100],
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10, top: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Expense\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    "- \u{20B9} " + expenseTotal.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
