import 'package:amazon_clone/core/theme/color_palette.dart';
import 'package:amazon_clone/core/theme/theme.dart';
import 'package:amazon_clone/views/cart/cart_screen.dart';
import 'package:amazon_clone/views/home/widgets/default_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:badges/badges.dart' as badges;
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailscreen extends ConsumerStatefulWidget {
  final String? productId;
  final String? productname;
  final String? productprice;
  final String? productimage;
  final String? dealPercentage;
  final String? totalPrice;
  final int? productdescription;
  // final List<dynamic>? review;
  const ProductDetailscreen(
    this.productId,
    this.productname,
    this.productprice,
    this.productimage,
    this.dealPercentage,
    this.productdescription,
    this.totalPrice, {
    // this.review,
    super.key,
  });

  @override
  ConsumerState<ProductDetailscreen> createState() =>
      _ProductDetailscreenState();
}

class _ProductDetailscreenState extends ConsumerState<ProductDetailscreen> {
  var totalReview = 0;
  Future<void> toggleCartStatus(String productId, bool currentStatus) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to add items to cart')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(productId)
          .set({
            'productId': productId,
            'addedAt': FieldValue.serverTimestamp(),
            'addtocart': !currentStatus,
          });
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating cart: $e')));
    }
  }

  void _showAddReviewSheet(BuildContext context) {
    final reviewController = TextEditingController();

    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add Review',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reviewController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Write your review...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    if (reviewController.text.isNotEmpty) {
                      try {
                        await FirebaseFirestore.instance
                            .collection('todaydeals')
                            .doc(widget.productId)
                            .collection('reviews')
                            .add({
                              'text': reviewController.text.trim(),
                              'userProfileImage':
                                  FirebaseAuth.instance.currentUser?.photoURL ??
                                  '',
                              'userName':
                                  FirebaseAuth
                                      .instance
                                      .currentUser
                                      ?.displayName ??
                                  FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(
                                        FirebaseAuth.instance.currentUser?.uid,
                                      )
                                      .get()
                                      .then((value) => value.data()!['name']),
                              'timestamp': FieldValue.serverTimestamp(),
                            });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Review added successfully'),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error adding review: $e')),
                        );
                      }
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: 4.0.sp,
                      horizontal: 24.sp,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(5.sp),
                    ),

                    child: Center(
                      child: const Text(
                        'Submit Review',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> collections = [
      'products',
      'todaydeals',
      'trending',
    ]; // Add all your collection names
    final size = MediaQuery.of(context).size;
    return Scaffold(
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
        height: 60.h,
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                SizedBox(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "₹${widget.totalPrice}",
                        style: TextStyle(
                          fontSize: 12.sp,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: Colors.red,
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        "${widget.dealPercentage}",
                        style: TextStyle(
                          fontSize: 12.sp,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: Colors.red,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "₹${widget.productprice}",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            StreamBuilder<DocumentSnapshot>(
              stream:
                  FirebaseAuth.instance.currentUser != null
                      ? FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .collection('cart')
                          .doc(widget.productId)
                          .snapshots()
                      : const Stream.empty(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }
                final data = snapshot.data?.data() as Map<String, dynamic>?;
                final isInCart = data?['addtocart'] ?? false;

                return GestureDetector(
                  onTap: () {
                    setState(() {});
                    toggleCartStatus(widget.productId!, isInCart);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isInCart ? Colors.grey : Colors.orange,
                      borderRadius: BorderRadius.circular(5.sp),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 6.0.sp,
                      horizontal: 24.sp,
                    ),
                    child: Text(
                      isInCart ? 'Remove to Cart' : 'Add to Cart',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      appBar: DefaultAppbar(showSearch: false),
      backgroundColor: Colors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(0).copyWith(top: 0.sp),
        child: SizedBox(
          width: 35,
          height: 35,
          child: FloatingActionButton(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: AppColors.accent,
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartScreen()),
                ),
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseAuth.instance.currentUser != null
                      ? FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .collection('cart')
                          .where('addtocart', isEqualTo: true)
                          .snapshots()
                      : const Stream.empty(),
              builder: (context, snapshot) {
                int cartCount = 0;
                if (snapshot.hasData) {
                  cartCount = snapshot.data!.docs.length;
                }
                return badges.Badge(
                  position: badges.BadgePosition.topEnd(top: -12, end: -12),
                  badgeContent: Text(
                    cartCount.toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                  child: Image.asset('assets/icons/Bag.png', height: 22.h),
                );
              },
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 400,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: widget.productId ?? '',
                    child: Image.network(
                      widget.productimage ?? '',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: const CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Icon(Icons.arrow_back, color: Colors.transparent),
                  ),
                  onPressed: () {},
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              textAlign: TextAlign.start,
                              widget.productname ?? 'No name',
                              style: Theme.of(
                                context,
                              ).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text('Shop: ', style: TextStyle(fontSize: 15.sp)),
                              Text(
                                'Mopio',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              ...List.generate(
                                5,
                                (index) => Icon(
                                  Icons.star,
                                  size: 15.sp,
                                  color:
                                      index < (widget.productdescription ?? 0)
                                          ? Colors.amber
                                          : Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 8),
                              StreamBuilder<QuerySnapshot>(
                                stream:
                                    FirebaseFirestore.instance
                                        .collection('todaydeals')
                                        .doc(widget.productId)
                                        .collection('reviews')
                                        .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Text(
                                      '${snapshot.data!.docs.length}',
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }
                                  return Text(
                                    '0',
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 22.sp,
                                child: Image.asset("assets/icons/fastcat.png"),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'FREE delivery',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _showAddReviewSheet(context);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 4.0.sp,
                                    horizontal: 24.sp,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent,
                                    borderRadius: BorderRadius.circular(5.sp),
                                  ),
                                  child: Text(
                                    'Add Review',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (widget.productId != null) ...[
                        Text('Reviews'),
                        const SizedBox(height: 16),
                        StreamBuilder<QuerySnapshot>(
                          stream:
                              FirebaseFirestore.instance
                                  .collection('todaydeals')
                                  .doc(widget.productId)
                                  .collection('reviews')
                                  .orderBy('timestamp', descending: true)
                                  .snapshots(),
                          builder: (context, snapshot) {
                            totalReview = snapshot.data!.docs.length;
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }

                            // if (snapshot.connectionState ==
                            //     ConnectionState.waiting) {
                            //   return const CircularProgressIndicator();
                            // }

                            final reviews = snapshot.data?.docs ?? [];

                            return Column(
                              children:
                                  reviews.map((doc) {
                                    final reviewData =
                                        doc.data() as Map<String, dynamic>;
                                    return Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      margin: const EdgeInsets.only(bottom: 16),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              100,
                                            ),
                                            child: Image.network(
                                              reviewData['userProfileImage'] ??
                                                  '',
                                              height: 40.h,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          SizedBox(
                                            width: size.width * 0.6,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  reviewData['userName'] ??
                                                      'USER',
                                                  style: TextStyle(
                                                    height: 1.5,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12.sp,
                                                  ),
                                                ),
                                                Text(
                                                  textAlign: TextAlign.end,
                                                  maxLines: 2,
                                                  reviewData['text'] ?? '',
                                                  style: TextStyle(
                                                    height: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    fontSize: 12.sp,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                            );
                          },
                        ),
                      ],
                      // const SizedBox(height: 80), // Bottom padding for FAB
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
