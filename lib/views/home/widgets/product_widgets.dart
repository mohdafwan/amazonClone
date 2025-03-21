import 'package:amazon_clone/views/product/product_detailscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:amazon_clone/core/theme/color_palette.dart';
import 'package:shimmer/shimmer.dart';

class ProductsWidgets extends StatefulWidget {
  final String collectionName;
  final String miniTitle;
  final bool widgetInHome;
  const ProductsWidgets({
    super.key,
    this.collectionName = 'watchs',
    this.widgetInHome = true,
    required this.miniTitle,
  });

  @override
  State<ProductsWidgets> createState() => _ProductsWidgetsState();
}

class _ProductsWidgetsState extends State<ProductsWidgets> {
  Future<QuerySnapshot>? _productFuture;

  @override
  void initState() {
    super.initState();
    _productFuture =
        FirebaseFirestore.instance.collection(widget.collectionName).get();
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(right: 10.w),
          child: Shimmer.fromColors(
            baseColor: AppColors.accent.withOpacity(0.6),
            highlightColor: AppColors.accent,
            child: SizedBox(
              width: 200.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 200.w,
                    height: 200.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    width: 150.w,
                    height: 15.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Container(
                    width: 100.w,
                    height: 15.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.miniTitle,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(
            height: widget.widgetInHome ? 320.h : 258.h,
            child: FutureBuilder(
              future: _productFuture,
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }
                if ((snapshot.connectionState == ConnectionState.waiting)) {
                  return _buildShimmerLoading();
                }
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var deal = snapshot.data!.docs[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return ProductDetailscreen(
                                snapshot.data!.docs[index].id,
                                snapshot.data!.docs[index]['dealTitle'],
                                snapshot.data!.docs[index]['dealAmount'],
                                snapshot.data!.docs[index]['dealImage'],
                                snapshot.data!.docs[index]['dealPercentage'],
                                snapshot.data!.docs[index]['dealRating'],
                                snapshot.data!.docs[index]['totalprice'],
                                // snapshot.data!.docs[index]['dealReviews'] ?? [],
                              );
                            },
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: 10.w),
                        child: SizedBox(
                          width: 200.w,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                color: Colors.white,
                                child: Image.network(
                                  deal['dealImage'] ?? '',
                                  width: 200.w,
                                  height: 200.h,
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              SizedBox(
                                height: 15.h,
                                child: Text(
                                  deal['dealTitle'] ?? '',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Row(
                                children: [
                                  Row(
                                    children: List.generate(
                                      5,
                                      (index) => Icon(
                                        Icons.star,
                                        size: 15.sp,
                                        color:
                                            index < (deal['dealRating'] ?? 0)
                                                ? Colors.amber
                                                : Colors.grey,
                                      ),
                                    ),
                                  ),
                                  // SizedBox(width: 5.w),
                                  // Text(
                                  //   '(${deal['dealReviews'].length ?? 0})',
                                  //   style: TextStyle(
                                  //     fontSize: 10.sp,
                                  //     color: Colors.grey,
                                  //   ),
                                  // ),
                                ],
                              ),
                              SizedBox(height: 5.h),
                              Text(
                                '₹ ${deal['dealAmount']?.toString() ?? '0.00'}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // SizedBox(height: 200),
        ],
      ),
    );
  }
}
