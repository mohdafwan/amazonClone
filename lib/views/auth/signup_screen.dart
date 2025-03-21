import 'package:amazon_clone/core/constants/appButton.dart';
import 'package:amazon_clone/core/theme/color_palette.dart';
import 'package:amazon_clone/views/auth/auth_viewmodel.dart';
import 'package:amazon_clone/views/auth/widgets/customTextField.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  bool _obscureText = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _conformpasswordController =
      TextEditingController();

  final _signUpFormKey = GlobalKey<FormState>();
  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _conformpasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = ref.watch(authViewModelProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20.sp, color: Colors.black),
          onPressed: () {
            context.go('/login');
          },
        ),
        title: Hero(
          tag: "logo-x",
          child: Image.asset(
            'assets/icons/logo.png',
            height: 20.h,
            filterQuality: FilterQuality.high,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: Form(
                key: _signUpFormKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 11.0),
                      child: Text(
                        "Create Account",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Text(
                        "It's free and always will be.",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Customtextfield(
                      hintText: "Email Address",
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 8.h),
                    Customtextfield(
                      hintText: "Password",
                      obscureText: _obscureText,
                      controller: _passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 8.h),
                    Customtextfield(
                      hintText: "Confirm Password",
                      obscureText: _obscureText,
                      controller: _conformpasswordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          splashRadius: 0,
                          focusColor: AppColors.buttonBlue,
                          checkColor: AppColors.accent,
                          activeColor: AppColors.buttonBlue,
                          value: !_obscureText,
                          onChanged: (value) {
                            setState(() {
                              _obscureText = !value!;
                            });
                          },
                        ),
                        Text(
                          "Show Password",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    AppButton(
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      borderRadius: 13,
                      backgroundColor: AppColors.buttonBlue,
                      width: double.infinity,
                      text: "Create New Account",
                      onPressed: () async {
                        if (_passwordController.text !=
                            _conformpasswordController.text) {
                          Fluttertoast.showToast(
                            msg: "Passwords do not match",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                          return;
                        }
                        authViewModel.createAccountWithUserNameAndPassword(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                          context,
                        );
                      },
                    ),
                    SizedBox(height: 10.h),
                    // AppButton(
                    //   textStyle: TextStyle(
                    //     color: Colors.black,
                    //     fontSize: 12.sp,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    //   borderRadius: 13,
                    //   backgroundColor: AppColors.textPrimary,
                    //   width: double.infinity,
                    //   child: Image.asset(
                    //     'assets/icons/googlelogo.png',
                    //     height: 25.h,
                    //     filterQuality: FilterQuality.high,
                    //   ),
                    //   onPressed: () {
                    //     authViewModel.signInWithGoogle();
                    //   },
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
