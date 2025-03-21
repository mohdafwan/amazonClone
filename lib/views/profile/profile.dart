import 'dart:developer';

import 'package:amazon_clone/core/theme/color_palette.dart';
import 'package:amazon_clone/views/cart/checkout/orders_screen.dart';
import 'package:amazon_clone/views/home/widgets/default_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:amazon_clone/core/constants/constant.dart';
import 'package:go_router/go_router.dart';

class Profile extends StatefulWidget {
  final bool isGoogleUser;
  const Profile({super.key, required this.isGoogleUser});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  String? userPhotoUrl;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() => isLoading = true);
      try {
        final userData =
            await _firestore.collection('users').doc(user.uid).get();
        if (userData.exists) {
          setState(() {
            nameController.text = userData['name'] ?? user.displayName ?? '';
            phoneController.text = userData['phone'] ?? '';
            addressController.text = userData['address'] ?? '';
            userPhotoUrl =
                widget.isGoogleUser ? user.photoURL : userData['photoUrl'];
          });
        }
      } catch (e) {
        log('Error loading user data: $e');
        // ScaffoldMessenger.of(
        //   context,
        // ).showSnackBar(SnackBar(content: Text('Error loading user data: $e')));
      }
      setState(() => isLoading = false);
    }
  }

  Future<void> updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'name': nameController.text,
          'phone': phoneController.text,
          'address': addressController.text,
          'email': user.email,
          'isGoogleUser': widget.isGoogleUser,
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
    }
    setState(() => isLoading = false);
  }

  void _showEditBottomSheet() {
    showModalBottomSheet(
      backgroundColor: AppColors.accent,
      context: context,
      isScrollControlled: true,
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!widget.isGoogleUser)
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(labelText: 'Name'),
                        validator:
                            (value) =>
                                value?.isEmpty ?? true
                                    ? 'Please enter name'
                                    : null,
                      ),
                    if (!widget.isGoogleUser) SizedBox(height: 20),
                    TextFormField(
                      controller: phoneController,
                      decoration: InputDecoration(labelText: 'Phone'),
                      keyboardType: TextInputType.phone,
                      validator:
                          (value) =>
                              value?.isEmpty ?? true
                                  ? 'Please enter phone'
                                  : null,
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: addressController,
                      decoration: InputDecoration(labelText: 'Address'),
                      validator:
                          (value) =>
                              value?.isEmpty ?? true
                                  ? 'Please enter address'
                                  : null,
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: isLoading ? null : updateProfile,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child:
                            isLoading
                                ? Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.7,
                                    color: AppColors.accent,
                                  ),
                                )
                                : Center(
                                  child: Text(
                                    'Update Profile',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppbar(showSearch: false, showLogoutButton: true),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (widget.isGoogleUser) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        height: 60,
                        width: 60,
                        child: Image.network(
                          _auth.currentUser!.photoURL!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ] else ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        height: 60,
                        width: 60,
                        child: Image.network(
                          'https://cdn.sanity.io/images/v2aajybd/production/3e54ea642953aef40bc5e0d0759e9a298347ca58-6000x4000.jpg?w=3840&q=75&fit=clip&auto=format',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                  Container(
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                      bottom: 5,
                      top: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(12),
                      border: BorderDirectional(
                        start: BorderSide(color: Colors.black),
                        end: BorderSide(color: Colors.black),
                        top: BorderSide(color: Colors.black),
                        bottom: BorderSide(color: Colors.black),
                      ),
                    ),
                    child:
                        widget.isGoogleUser
                            ? Text(
                              "Google ID",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                            : Text("Email ID"),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Container(
              child:
                  widget.isGoogleUser || nameController.text.isNotEmpty
                      ? Text(
                        nameController.text.toUpperCase(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      : SizedBox(height: 0.h),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Container(
              child:
                  widget.isGoogleUser || phoneController.text.isNotEmpty
                      ? Text(
                        "+91 ${phoneController.text.toUpperCase()}",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      : SizedBox(height: 0.h),
            ),
          ),

          SizedBox(height: 10.h),
          Links(title: 'Edit Profile', callback: _showEditBottomSheet),
          Divider(),
          Links(
            title: 'My Orders',
            callback: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrdersScreen(),
                ),
              );
            },
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }
}

class Links extends StatelessWidget {
  final String title;
  final void Function()? callback;
  const Links({super.key, this.title = 'Edit Profile', this.callback});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onTap: callback,
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.sp),
            color: Color(0xffE3E3E3),
          ),
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              CircleAvatar(
                backgroundColor: Color(0xffEFEFEF),
                child: Icon(Icons.arrow_forward_ios, color: Color(0xff7B7B7B)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
