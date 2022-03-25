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
  CategoryModel? _selectedCategoryModel;

  String? _categoryID;

  final _purposeTextEditingController = TextEditingController();
  final _amountTextEditingController = TextEditingController();

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
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //purpose
              TextFormField(
                controller: _purposeTextEditingController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Purpose'),
              ),
              const SizedBox(
                height: 10,
              ),
              //amount
              TextFormField(
                controller: _amountTextEditingController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Amount'),
              ),
              const SizedBox(height: 10,),
              //Date
              TextButton.icon(
                onPressed: () async {
                  final _selectedDateTemp = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 49)),
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
                      : DateFormat('dd-MM-yyyy')
                          .format(_selectedDate!),
                ),
              ),
              //Category
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                      const Text('Income'),
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
                      const Text('Expense'),
                    ],
                  ),
                ],
              ),
              //Category Type
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: DropdownButton<String>(
                  hint: const Text('Select Category'),
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
                          _selectedCategoryModel = e;
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      addTransaction();
                    },
                    child: const Text('Submit'),
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
      category: _selectedCategoryModel!,
    );
    await TransactionDB.instance.insertTransaction(_transaction);
    Navigator.of(context).pop();
  }
}
