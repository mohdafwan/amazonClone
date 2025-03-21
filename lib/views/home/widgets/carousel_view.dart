import 'package:amazon_clone/core/theme/color_palette.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../../../views/home/widgets/banner_product.dart';

class CarouselViewX extends StatefulWidget {
  const CarouselViewX({super.key});

  @override
  State<CarouselViewX> createState() => _CarouselViewXState();
}

class _CarouselViewXState extends State<CarouselViewX> {
  int _currentIndex = 0;
  Future<QuerySnapshot>? _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = FirebaseFirestore.instance.collection('banners').get();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _productsFuture,
      builder: (context, snapshot) {
        if ((snapshot.connectionState == ConnectionState.waiting)) {
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20.0.sp, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Shimmer.fromColors(
                      baseColor: AppColors.accent.withOpacity(0.6),
                      highlightColor: AppColors.accent,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.sp),

                          color: Colors.white,
                        ),
                        width: 150,
                        height: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Shimmer.fromColors(
                baseColor: AppColors.accent.withOpacity(0.6),
                highlightColor: AppColors.accent,
                child: Container(
                  height: 450.h,
                  width: 0.9.sw,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ],
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No data available'));
        }

        final itemCount = snapshot.data!.docs.length;

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Brands Of The Week',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                if (itemCount > 1) // Only show indicators if more than one item
                  const SizedBox(height: 0),
                if (itemCount > 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      itemCount,
                      (index) => Container(
                        width: index == _currentIndex ? 20 : 8,
                        height: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color:
                              index == _currentIndex
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            CarouselSlider.builder(
              itemCount: itemCount,
              options: CarouselOptions(
                height: 450.h,
                viewportFraction: 0.80,
                enlargeCenterPage: true,
                autoPlay: itemCount > 1,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration: const Duration(milliseconds: 400),
                autoPlayCurve: Curves.easeInOut,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
              itemBuilder: (context, index, realIndex) {
                return GestureDetector(
                  onTap: () {
                    String collection = '';
                    switch (index) {
                      case 0:
                        collection = 'glasses';
                        break;
                      case 1:
                        collection = 'watchs';
                        break;
                      case 2:
                        collection = 'bags';
                        break;
                      case 3:
                        collection = 'clothing';
                        break;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BannerProduct(
                          collectionName: collection,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: Image.network(
                        filterQuality: FilterQuality.high,
                        alignment: Alignment.topCenter,
                        snapshot.data!.docs[index]['bannerUrl'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(child: Icon(Icons.error_outline));
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
