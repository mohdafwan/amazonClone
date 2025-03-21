import 'package:amazon_clone/core/theme/color_palette.dart';
import 'package:amazon_clone/views/home/widgets/default_appbar.dart';
import 'package:amazon_clone/views/home/widgets/product_widgets.dart';
import 'package:amazon_clone/views/home/widgets/carousel_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Future<void> _onRefresh() async {
    refreshData();
    setState(() {});
  }

  void refreshData() {
    CarouselViewX();
    // ProductsWidgets(miniTitle: "Today Deals",);
    setState(() {});
  }

  Future<void> toggleCartStatus(String productId, bool currentStatus) async {
    await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .update({'addtocart': !currentStatus});
    setState(() {}); // Rebuild UI after update
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppbar(showSearch: false,),
      body: SafeArea(
        child: RefreshIndicator(
          backgroundColor: Colors.white,
          color: AppColors.accent,
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CarouselViewX(),
                  const SizedBox(height: 10),
                  ProductsWidgets(miniTitle: "Today Deals", collectionName: 'todaydeals'),
                ],
              ),
            ),
          ),
        ),
      ),
      // Remove the floatingActionButton
    );
  }
}

