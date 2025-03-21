import 'dart:ffi';

import 'package:amazon_clone/views/home/widgets/default_appbar.dart';
import 'package:amazon_clone/views/product/product_detailscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:amazon_clone/core/theme/color_palette.dart';
import 'package:shimmer/shimmer.dart';

class BannerProduct extends StatefulWidget {
  final String collectionName;

  const BannerProduct({super.key, this.collectionName = 'watchs'});

  @override
  State<BannerProduct> createState() => _BannerProductState();
}

class _BannerProductState extends State<BannerProduct> {
  Future<QuerySnapshot>? _productFuture;

  @override
  void initState() {
    super.initState();
    _productFuture =
        FirebaseFirestore.instance.collection(widget.collectionName).get();
  }

  Widget _buildShimmerLoading() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: AppColors.accent.withOpacity(0.6),
          highlightColor: AppColors.accent,
          child: Container(
            height: 185.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppbar(showSearch: false, showLogoutButton: false,title: widget.collectionName,showTitle: true,),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.collectionName,
                style: TextStyle(
                  
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: _productFuture,
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }
                  if ((snapshot.connectionState == ConnectionState.waiting)) {
                    return _buildShimmerLoading();
                  }
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: .65.sp,
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 20.h,
                    ),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var deal = snapshot.data!.docs[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailscreen(
                                snapshot.data!.docs[index].id,
                                snapshot.data!.docs[index]['dealTitle'],
                                snapshot.data!.docs[index]['dealAmount'],
                                snapshot.data!.docs[index]['dealImage'],
                                snapshot.data!.docs[index]['dealPercentage'],
                                snapshot.data!.docs[index]['dealRating'],
                                snapshot.data!.docs[index]['totalprice'],
                              ),
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.white,
                          elevation: 0.1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 150.h,
                                width: double.infinity,
                                color: Colors.white,
                                child: Image.network(
                                  deal['dealImage'] ?? '',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      deal['dealTitle'] ?? '',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 5.h),
                                    Row(
                                      children: List.generate(
                                        5,
                                        (index) => Icon(
                                          Icons.star,
                                          size: 15.sp,
                                          color: index < (deal['dealRating'] ?? 0)
                                              ? Colors.amber
                                              : Colors.grey,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 5.h),
                                    Text(
                                      '₹ ${deal['dealAmount']?.toString() ?? '0.00'}',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
