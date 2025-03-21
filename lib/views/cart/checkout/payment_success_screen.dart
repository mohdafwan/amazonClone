// ignore_for_file: use_build_context_synchronously

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:amazon_clone/core/theme/color_palette.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final String orderId;

  const PaymentSuccessScreen({Key? key, required this.orderId})
    : super(key: key);

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  int _countdown = 3;

  @override
  void initState() {
    super.initState();
    clearCart(); // Clear cart when payment is successful
    startCountdown();
  }

  Future<void> clearCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final cartRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart');
          
      final cartItems = await cartRef.get();
      final batch = FirebaseFirestore.instance.batch();
      
      for (var doc in cartItems.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }

  Future<void> startCountdown() async {
    for (int i = _countdown; i > 0; i--) {
      if (!mounted) return;
      setState(() => _countdown = i);
      await Future.delayed(const Duration(seconds: 1));
    }
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: FlipInX(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ZoomInDown(
                  child: Image.asset(
                    'assets/icons/paymentDone.png',
                    height: 200.h,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  textAlign: TextAlign.center,
                  'Your order has been placed successfully!',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.sp),
                  child: Text(
                    textAlign: TextAlign.center,
                    'Thank you for choosing us! Feel free to continue shopping and explore our wide range of products. Happy Shopping!',
                    style: TextStyle(color: Colors.grey[600], fontSize: 10.sp),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Order ID: ${widget.orderId}',
                  style: TextStyle(color: AppColors.accent),
                ),
                SizedBox(height: 12.h),
                StatefulBuilder(
                  builder: (context, setState) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.sp,
                          vertical: 12.sp,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(2.sp),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Continue Shopping',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                              ),
                            ),
                            if (_countdown > 0) ...[
                              SizedBox(width: 8.sp),
                              Text(
                                '($_countdown)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
