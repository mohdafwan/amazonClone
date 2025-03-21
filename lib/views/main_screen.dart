import 'package:amazon_clone/core/theme/color_palette.dart';
import 'package:amazon_clone/views/category/category_screen.dart';
import 'package:amazon_clone/views/home/home_screen.dart';
import 'package:amazon_clone/views/profile/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    // const CartScreen(),
    const CategoryScreen(),
    // const UploadDealScreen(),
    // ProfileScreen(),
    Profile(
      isGoogleUser:
          FirebaseAuth.instance.currentUser?.providerData.any(
            (element) => element.providerId == 'google.com',
          ) ??
          false,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: _selectedIndex, children: _screens),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -0),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                showSelectedLabels: false,
                showUnselectedLabels: false,
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                backgroundColor: Colors.white,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                items: [
                  BottomNavigationBarItem(
                    icon: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        _selectedIndex == 0 ? AppColors.accent : Colors.black,
                        BlendMode.srcIn,
                      ),
                      child: const Image(
                        image: AssetImage('assets/icons/Home.png'),
                        height: 24,
                      ),
                    ),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        _selectedIndex == 1 ? AppColors.accent : Colors.black,
                        BlendMode.srcIn,
                      ),
                      child: const Image(
                        image: AssetImage('assets/icons/Categories.png'),
                        height: 24,
                      ),
                    ),
                    label: 'Cart',
                  ),
                  BottomNavigationBarItem(
                    icon: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        _selectedIndex == 2 ? AppColors.accent : Colors.black,
                        BlendMode.srcIn,
                      ),
                      child: const Image(
                        image: AssetImage('assets/icons/profile.png'),
                        height: 24,
                      ),
                    ),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
