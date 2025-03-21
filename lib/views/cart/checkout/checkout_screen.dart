import 'package:amazon_clone/core/theme/color_palette.dart';
import 'package:amazon_clone/views/cart/checkout/payment_success_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final double total;

  const CheckoutScreen({Key? key, required this.items, required this.total})
    : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int currentStep = 0;
  String? selectedAddress;
  String paymentMethod = 'Cash on Delivery';

  @override
  void initState() {
    super.initState();
    loadAddress();
  }

  Future<void> loadAddress() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();
      if (doc.exists) {
        setState(() {
          selectedAddress = doc.data()?['address'];
        });
      }
    }
  }

  Future<void> updateAddress() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      String? newAddress = await showDialog<String>(
        context: context,
        builder: (context) => AddressDialog(),
      );
      
      if (newAddress != null && newAddress.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'address': newAddress});
        
        setState(() {
          selectedAddress = newAddress;
        });
      }
    }
  }

  Future<void> placeOrder() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final docRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('orders')
          .add({
            'items': widget.items,
            'total': widget.total,
            'address': selectedAddress,
            'paymentMethod': paymentMethod,
            'status': 'pending',
            'orderDate': FieldValue.serverTimestamp(),
          });

      // Clear cart items
      for (var item in widget.items) {
        await FirebaseFirestore.instance
            .collection(item['collection'])
            .doc(item['productId'])
            .update({'addtocart': false});
      }

      if (mounted) {
        print('Order placed successfully with ID: ${docRef.id}');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessScreen(orderId: docRef.id),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stepper(
        type: StepperType.vertical,
        connectorColor: MaterialStateProperty.all(AppColors.accent),
        currentStep: currentStep,
        onStepContinue: () {
          if (currentStep < 2) {
            setState(() => currentStep++);
          } else {
            placeOrder();
          }
        },
        onStepCancel: () {
          if (currentStep > 0) {
            setState(() => currentStep--);
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: Text(currentStep == 2 ? 'Place Order' : 'Continue'),
                ),
                if (currentStep > 0) ...[
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: details.onStepCancel,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.accent,
                    ),
                    child: const Text('Back'),
                  ),
                ],
              ],
            ),
          );
        },
        steps: [
          Step(
            isActive: currentStep >= 0,
            title: const Text('Shipping'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Delivery Address:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                selectedAddress == null
                    ? ElevatedButton(
                        onPressed: updateAddress,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Add Address'),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(selectedAddress!),
                          TextButton(
                            onPressed: updateAddress,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.accent,
                            ),
                            child: const Text('Change Address'),
                          ),
                        ],
                      ),
              ],
            ),
          ),
          Step(
            isActive: currentStep >= 1,
            title: const Text('Payment'),
            content: Column(
              children: [
                RadioListTile(
                  fillColor: WidgetStateProperty.all(AppColors.accent),
                  title: const Text(
                    'Cash on Delivery',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  value: 'Cash on Delivery',
                  groupValue: paymentMethod,
                  onChanged:
                      (value) =>
                          setState(() => paymentMethod = value.toString()),
                ),
                RadioListTile(
                  title: const Text(
                    'Online Payment (Coming Soon)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  value: 'Online',
                  groupValue: paymentMethod,
                  onChanged: null,
                ),
              ],
            ),
          ),
          Step(
            isActive: currentStep >= 2,
            title: const Text('Review'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Summary:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...widget.items.map(
                  (item) => ListTile(
                    title: Text(
                      item['name'] ?? 'No name',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    trailing: Text(
                      '₹${item['dealAmount']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text(
                    'Total',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  trailing: Text(
                    '₹${widget.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Delivery Address:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  selectedAddress ?? 'No address found',
                  style: TextStyle(overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Payment Method:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(paymentMethod),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AddressDialog extends StatefulWidget {
  @override
  State<AddressDialog> createState() => _AddressDialogState();
}

class _AddressDialogState extends State<AddressDialog> {
  final _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Address'),
      content: TextField(
        controller: _addressController,
        decoration: const InputDecoration(
          hintText: 'Enter your full address',
        ),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _addressController.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }
}
