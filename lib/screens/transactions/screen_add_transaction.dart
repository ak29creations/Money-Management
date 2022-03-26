import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_management/db/category/category_db.dart';
import 'package:money_management/db/transactions/transaction_db.dart';
import 'package:money_management/models/category/category_model.dart';
import 'package:money_management/models/transaction/transaction_model.dart';

class AddTransaction extends StatefulWidget {
  static const routeName = 'add-transaction';
  const AddTransaction({Key? key}) : super(key: key);

  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  DateTime? _selectedDate;
  CategoryType? _selectedCategoryType;
  String? _categoryName;

  String? _categoryID;

  final _purposeTextEditingController = TextEditingController();
  final _amountTextEditingController = TextEditingController();
  final _textEditingController = TextEditingController();

  @override
  void initState() {
    _selectedCategoryType = CategoryType.income;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                  child: Text(
                "Add Transaction",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              )),
              const SizedBox(
                height: 50,
              ),
              //purpose
              TextFormField(
                controller: _purposeTextEditingController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Purpose'),
              ),
              const SizedBox(
                height: 10,
              ),
              //amount
              TextFormField(
                controller: _amountTextEditingController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    prefixText: "\u{20B9}",
                    suffixText: "Rs.",
                    border: OutlineInputBorder(),
                    labelText: 'Amount'),
              ),
              const SizedBox(
                height: 10,
              ),
              //Date
              TextButton.icon(
                onPressed: () async {
                  final _selectedDateTemp = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2022),
                    lastDate: DateTime.now(),
                  );
                  if (_selectedDateTemp == null) {
                    return;
                  } else {
                    setState(() {
                      _selectedDate = _selectedDateTemp;
                    });
                  }
                },
                icon: const Icon(Icons.calendar_month),
                label: Text(
                  _selectedDate == null
                      ? 'Select Date'
                      : DateFormat('dd-MM-yyyy').format(_selectedDate!),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              //Category
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Radio(
                          value: CategoryType.income,
                          groupValue: _selectedCategoryType,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedCategoryType = CategoryType.income;
                              _categoryID = null;
                            });
                          }),
                      const Text(
                        'Income',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Radio(
                          value: CategoryType.expense,
                          groupValue: _selectedCategoryType,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedCategoryType = CategoryType.expense;
                              _categoryID = null;
                            });
                          }),
                      const Text(
                        'Expense',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) {
                              return SimpleDialog(
                                title: Center(
                                  child: Text(
                                    (_selectedCategoryType ==
                                            CategoryType.income)
                                        ? "Add Income Category"
                                        : "Add Expense Category",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      controller: _textEditingController,
                                      decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: "Category Name"),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final _name =
                                            _textEditingController.text;
                                        if (_name.isEmpty) {
                                          return;
                                        }
                                        final _category = CategoryModel(
                                            name: _name,
                                            type: _selectedCategoryType!);
                                        int result = await CategoryDB.instance
                                            .insertCategory(_category);
                                        Navigator.of(ctx).pop();
                                        setState(() {
                                          CategoryDB().refreshUI();
                                          _categoryID = result.toString();
                                          _categoryName = _name;
                                        });
                                      },
                                      child: const Text(
                                        "Add",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              );
                            },
                          );
                        },
                        child: const Icon(Icons.add),
                      )
                    ],
                  )
                ],
              ),
              //Category Type
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: DropdownButton<String>(
                  hint: const Text(
                    '--Select Category--',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  value: _categoryID,
                  items: (_selectedCategoryType == CategoryType.income
                          ? CategoryDB.instance.incomeCategoryListListener
                          : CategoryDB.instance.expenseCategoryListListener)
                      .value
                      .map(
                    (e) {
                      return DropdownMenuItem(
                        value: e.id.toString(),
                        child: Text(e.name),
                        onTap: () {
                          _categoryName = e.name;
                        },
                      );
                    },
                  ).toList(),
                  onChanged: (selectedValue) {
                    setState(() {
                      _categoryID = selectedValue;
                    });
                  },
                ),
              ),
              //Submit
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      addTransaction();
                    },
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> addTransaction() async {
    final _purposeText = _purposeTextEditingController.text;
    final _amountText = _amountTextEditingController.text;
    if (_purposeText.isEmpty) {
      return;
    }
    if (_amountText.isEmpty) {
      return;
    }
    if (_categoryID == null) {
      return;
    }
    if (_selectedDate == null) {
      return;
    }

    final _parsedAmount = double.tryParse(_amountText);
    if (_parsedAmount == null) {
      return;
    }
    final _transaction = TransactionModel(
      purpose: _purposeText,
      amount: _parsedAmount,
      date: _selectedDate!,
      type: _selectedCategoryType!,
      category: _categoryName!,
    );
    await TransactionDB.instance.insertTransaction(_transaction);
    Navigator.of(context).pop();
  }
}
