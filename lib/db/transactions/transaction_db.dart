import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:money_management/models/category/category_model.dart';
import 'package:money_management/models/transaction/transaction_model.dart';

const transactionDb = "transaction_db";

abstract class TransactionDbFunctions {
  Future<List<TransactionModel>> getallTransactions();
  Future<List<TransactionModel>> getTransactionCategories(
      CategoryType type, String name);
  Future<void> totalIncomeExpense();
  Future<void> insertTransaction(TransactionModel value);
  Future<void> deleteTransaction(int id);
}

class TransactionDB implements TransactionDbFunctions {
  TransactionDB._internal();
  static TransactionDB instance = TransactionDB._internal();

  factory TransactionDB() {
    return instance;
  }
  ValueNotifier<List<TransactionModel>> transactionListNotifier =
      ValueNotifier([]);

  ValueNotifier<double> incomeTotalNotifier = ValueNotifier(0);
  ValueNotifier<double> expenseTotalNotifier = ValueNotifier(0);
  ValueNotifier<double> totalNotifier = ValueNotifier(0);

  Future<void> refresh() async {
    final _list = await getallTransactions();
    _list.sort((first, second) => second.date.compareTo(first.date));
    transactionListNotifier.value.clear();
    transactionListNotifier.value.addAll(_list);
    await totalIncomeExpense();
    transactionListNotifier.notifyListeners();
  }

  @override
  Future<List<TransactionModel>> getallTransactions() async {
    final _transactionDB = await Hive.openBox<TransactionModel>(transactionDb);
    return _transactionDB.values.toList();
  }

  @override
  Future<void> insertTransaction(TransactionModel value) async {
    final _transactionDB = await Hive.openBox<TransactionModel>(transactionDb);
    final _id = await _transactionDB.add(value);
    value.id = _id;
    await _transactionDB.put(_id, value);
    refresh();
  }

  @override
  Future<void> deleteTransaction(int id) async {
    final _transactionDB = await Hive.openBox<TransactionModel>(transactionDb);
    _transactionDB.delete(id);
    refresh();
  }

  @override
  Future<void> totalIncomeExpense() async {
    final _transactionDB = await Hive.openBox<TransactionModel>(transactionDb);
    double income = 0;
    double expense = 0;
    List<TransactionModel> incomeCategory = _transactionDB.values
        .where((value) => value.type == CategoryType.income)
        .toList();
    List<TransactionModel> expenseCategory = _transactionDB.values
        .where((value) => value.type == CategoryType.expense)
        .toList();

    for (int i = 0; i < incomeCategory.length; i++) {
      income += incomeCategory[i].amount;
    }
    for (int i = 0; i < expenseCategory.length; i++) {
      expense += expenseCategory[i].amount;
    }
    incomeTotalNotifier.value = income;
    expenseTotalNotifier.value = expense;
    double total = income - expense;
    totalNotifier.value = total;
    incomeTotalNotifier.notifyListeners();
    expenseTotalNotifier.notifyListeners();
    totalNotifier.notifyListeners();
  }

  @override
  Future<List<TransactionModel>> getTransactionCategories(
      CategoryType type, String name) async {
    final _transactionDB = await Hive.openBox<TransactionModel>(transactionDb);
    var result = _transactionDB.values
        .where((val) => val.category == name)
        .where((val) => val.type == type)
        .toList();
    return result;
  }
}
