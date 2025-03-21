import 'package:amazon_clone/core/theme/color_palette.dart';
import 'package:amazon_clone/views/auth/auth_viewmodel.dart';
import 'package:amazon_clone/views/search/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DefaultAppbar extends ConsumerWidget implements PreferredSizeWidget {
  final bool? showSearch;
  final bool? showLogoutButton;
  final bool? showTitle;
  final String? title;
  const DefaultAppbar({
    super.key,
    this.showSearch = true,
    this.showLogoutButton = false,
    this.showTitle = false,
    this.title = "TITLE",
  });

  @override
  Size get preferredSize =>
      showSearch! ? Size.fromHeight(105.h) : Size.fromHeight(55.h);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authViewModel = ref.watch(authViewModelProvider.notifier);

    return AppBar(
      iconTheme: const IconThemeData(color: Colors.black),
      elevation: 0,
      toolbarHeight: showSearch! ? 90.h : 60.h,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
            tileMode: TileMode.repeated,
            transform: GradientRotation(0.01),
            colors: [
              const Color.fromARGB(255, 252, 151, 0),
              const Color.fromARGB(255, 244, 218, 179),
            ],
          ),
        ),
      ),
      title: Padding(
        padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Header Section
            SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  showTitle!
                      ? Padding(
                        padding: const EdgeInsets.only(top: 7.0),
                        child: Text(
                          title!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      )
                      : Hero(
                        tag: 'logo-x',
                        child: Image.asset(
                          'assets/icons/logo.png',
                          height: 25.h,
                        ),
                      ),
                  Row(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Image.asset(
                            'assets/icons/Location-Icon.png',
                            height: 20.h,
                            color: Colors.black,
                          ),
                          Text(
                            'Deliver to\nNew York, NY',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10.sp,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 10.w),
                      Image.asset(
                        'assets/icons/Bell.png',
                        height: 20.h,
                        color: Colors.black,
                      ),
                      showLogoutButton!
                          ? SizedBox(width: 10.w)
                          : SizedBox(width: 0.w),
                      showLogoutButton!
                          ? GestureDetector(
                            onTap: () {
                              authViewModel.signOut(context);
                            },
                            child: Image.asset(
                              'assets/icons/Logout.png',
                              height: 20.h,
                              color: Colors.black,
                            ),
                          )
                          : const SizedBox(width: 0),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            // Search Field Section
            showSearch!
                ? SizedBox(
                  height: 45.h,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchScreen(),
                        ),
                      );
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search Amazon',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.black54,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.black12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.accent),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                : const SizedBox(height: 0),
          ],
        ),
      ),
    );
  }
}
