import 'package:flutter/material.dart';
import 'package:money_management/screens/category/category_add_popup.dart';
import 'package:money_management/screens/category/screen_category.dart';
import 'package:money_management/screens/transactions/screen_add_transaction.dart';
import 'package:money_management/screens/transactions/screen_transaction.dart';

class MoneyManagementBottomNavigation extends StatelessWidget {
  const MoneyManagementBottomNavigation({Key? key}) : super(key: key);

  static ValueNotifier<int> selectedIndexNotifier = ValueNotifier(0);

  final _pages = const [
    ScreenTransaction(),
    ScreenCategory(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ValueListenableBuilder(
            valueListenable: selectedIndexNotifier,
            builder: (BuildContext cxt, int updatedIndex, _) {
              return _pages[updatedIndex];
            }),
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        onPressed: () {
          if (selectedIndexNotifier.value == 0) {
            Navigator.of(context).pushNamed(AddTransaction.routeName);
          } else {
            showCategoryAddPopup(context);
          }
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: selectedIndexNotifier,
        builder: (BuildContext ctx, int updatedIndex, _) {
          return BottomNavigationBar(
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            type: BottomNavigationBarType.fixed,
            elevation: 5,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            selectedFontSize: 15,
            currentIndex: updatedIndex,
            onTap: (newIndex) {
              selectedIndexNotifier.value = newIndex;
            },
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  label: "Transactions",
                  tooltip: "Transactions"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.category_outlined),
                  label: "Category",
                  tooltip: "Category"),
            ],
          );
        },
      ),
    );
  }
}
