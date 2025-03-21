import 'package:amazon_clone/core/constants/appButton.dart';
import 'package:amazon_clone/core/theme/color_palette.dart';
import 'package:amazon_clone/views/auth/auth_viewmodel.dart';
import 'package:amazon_clone/views/auth/widgets/customTextField.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _obscureText = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _signInFormKey = GlobalKey<FormState>();
  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = ref.watch(authViewModelProvider.notifier);
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: Form(
                key: _signInFormKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 100.h),
                    Hero(
                      tag: "logo-x",
                      child: Image.asset(
                        'assets/icons/logo.png',
                        height: 60.h,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                    SizedBox(height: 50.h),
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
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.all(
                            0,
                          ).copyWith(right: 14.sp, top: 2.sp),
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
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
                    Padding(
                      padding: const EdgeInsets.only(left: 11.0, right: 11.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: AppButton(
                              paddingSize: 1,
                              textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              borderRadius: 13,
                              backgroundColor: AppColors.accent,
                              width: double.infinity,
                              text: "Login",
                              onPressed: () async {
                                if (_signInFormKey.currentState!.validate()) {
                                  final success = await authViewModel.signInWithUserNameAndPassword(
                                    _emailController.text.trim(),
                                    _passwordController.text.trim(),
                                  );
                                  if (success && mounted) {
                                    context.go('/homepage');
                                  }
                                }
                              },
                            ),
                          ),
                          Expanded(
                            child: AppButton(
                              paddingSize: 1,
                              textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              borderRadius: 13,
                              backgroundColor: AppColors.accent,
                              width: double.infinity,
                              child: Image.asset(
                                'assets/icons/googlelogo.png',
                                height: 25.h,
                                filterQuality: FilterQuality.high,
                              ),
                              onPressed: () {
                                authViewModel.signInWithGoogle();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Divider(color: AppColors.gray, height: 2.h),
                    ),
                    SizedBox(height: 18.h),
                    Text(
                      "New To Amazon?",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
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
                      onPressed: () {
                       context.push('/signup');
                      },
                    ),
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
