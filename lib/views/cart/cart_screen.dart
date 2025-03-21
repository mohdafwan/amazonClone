import 'package:amazon_clone/core/theme/color_palette.dart';
import 'package:amazon_clone/views/home/widgets/default_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:amazon_clone/views/cart/checkout/checkout_screen.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  String addressx = '';

  Future<void> removeFromCart(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(productId)
          .delete();
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error removing item: $e')));
      }
    }
  }

  Future<List<Map<String, dynamic>>> getAllCartItems() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    List<Map<String, dynamic>> allItems = [];

    try {
      final cartSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('cart')
              .where('addtocart', isEqualTo: true)
              .get();

      for (var cartDoc in cartSnapshot.docs) {
        final productId = cartDoc.id;
        // Try to fetch product details from all collections
        for (String collection in [
          'todaydeals',
          'products',
          'watchs',
          'bags',
          'glasses',
          'clothing',
        ]) {
          try {
            final productDoc =
                await FirebaseFirestore.instance
                    .collection(collection)
                    .doc(productId)
                    .get();

            if (productDoc.exists) {
              allItems.add({
                ...productDoc.data()!,
                'productId': productId,
                'collection': collection,
              });
              break; // Break once we find the product
            }
          } catch (e) {
            print('Error fetching from $collection: $e');
          }
        }
      }
    } catch (e) {
      print('Error fetching cart items: $e');
    }

    return allItems;
  }

  double safeParsePrice(String? priceString) {
    if (priceString == null) return 0.0;
    // Remove commas and any trailing backslashes
    String cleanPrice =
        priceString.replaceAll(',', '').replaceAll('\\', '').trim();
    try {
      return double.parse(cleanPrice);
    } catch (e) {
      return 0.0;
    }
  }

  double calculateTotal(List<Map<String, dynamic>> items) {
    return items.fold(
      0,
      (sum, item) => sum + safeParsePrice(item['dealAmount']?.toString()),
    );
  }

  Future<String?> getUserAddress() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return null;

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (!userDoc.exists) return null;

    final address = userDoc.data()?['address'] as String?;
    addressx = address.toString();
    return address;
  }

  Future<void> createOrder(
    List<Map<String, dynamic>> items,
    double total,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to place order')),
        );
        return;
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final address = await getUserAddress();
      if (address == null) {
        Navigator.pop(context);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please add a delivery address')),
          );
        }
        return;
      }

      // Create order
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('orders')
          .add({
            'items':
                items
                    .map(
                      (item) => {
                        'name': item['name'],
                        'dealAmount': item['dealAmount'],
                        'dealImage': item['dealImage'],
                        'productId': item['productId'],
                        'collection': item['collection'],
                      },
                    )
                    .toList(),
            'total': total,
            'status': 'pending',
            'address': address,
            'orderDate': FieldValue.serverTimestamp(),
          });

      // Clear cart
      final batch = FirebaseFirestore.instance.batch();
      final cartRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart');

      for (var item in items) {
        batch.delete(cartRef.doc(item['productId']));
      }
      await batch.commit();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error placing order: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppbar(showLogoutButton: false, showSearch: false),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getAllCartItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                strokeWidth: 2,
              ),
            );
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text('Your cart is empty'),
                  const SizedBox(height: 8),
                  Text('Add items to start shopping'),
                ],
              ),
            );
          }

          final items = snapshot.data!;
          final total = calculateTotal(items);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 10.sp),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(1),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item['dealImage'] ?? '',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'] ?? 'No name',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '₹${item['dealAmount'] ?? '0'}',
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: AppColors.accent,
                                ),
                                onPressed:
                                    () => removeFromCart(item['productId']),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '₹${total.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => CheckoutScreen(
                                      items: items,
                                      total: total,
                                    ),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              vertical: 10.0.sp,
                              horizontal: 24.sp,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(5.sp),
                            ),
                            child: Center(
                              child: Text(
                                'Proceed to Checkout',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
