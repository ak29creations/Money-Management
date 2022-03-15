import 'package:flutter/material.dart';
import 'package:money_management/screens/category/category_add_popup.dart';
import 'package:money_management/screens/category/screen_category.dart';
import 'package:money_management/screens/home/widgets/bottom_navigation.dart';
import 'package:money_management/screens/transactions/screen_add_transaction.dart';
import 'package:money_management/screens/transactions/screen_transaction.dart';

class ScreenHome extends StatelessWidget {
  const ScreenHome({Key? key}) : super(key: key);

  static ValueNotifier<int> selectedIndexNotifier = ValueNotifier(0);

  final _pages = const [
    ScreenTransaction(),
    ScreenCategory(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("MONEY MANAGER"),
        centerTitle: true,
      ),
      bottomNavigationBar: const MoneyManagementBottomNavigation(),
      body: SafeArea(
        child: ValueListenableBuilder(
            valueListenable: selectedIndexNotifier,
            builder: (BuildContext cxt, int updatedIndex, _) {
              return _pages[updatedIndex];
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedIndexNotifier.value == 0) {
            Navigator.of(context).pushNamed(AddTransaction.routeName);
          } else {
            showCategoryAddPopup(context);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
