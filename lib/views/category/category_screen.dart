import 'package:amazon_clone/views/home/widgets/default_appbar.dart';
import 'package:amazon_clone/views/home/widgets/product_widgets.dart';
import 'package:flutter/material.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppbar(showSearch: true, showLogoutButton: false),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ProductsWidgets(
            //   miniTitle: "Today Deals",
            //   widgetInHome: false,
            //   collectionName: 'todaydeals',
            // ),
            ProductsWidgets(
              miniTitle: "Sunglasses",
              widgetInHome: false,
              collectionName: 'glasses',
            ),
            ProductsWidgets(
              miniTitle: "Bags & Sleeves",
              widgetInHome: false,
              collectionName: 'bags',
            ),
            ProductsWidgets(
              miniTitle: "Fashion",
              widgetInHome: false,
              collectionName: 'clothing',
            ),
            ProductsWidgets(
              miniTitle: "Watches",
              collectionName: 'watchs',
            ),
          ],
        ),
      ),
    );
  }
}
