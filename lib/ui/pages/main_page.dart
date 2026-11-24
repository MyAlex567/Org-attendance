import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'history_page.dart';
import 'home_page.dart';
import 'my_qr_page.dart';
import 'profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // set the default page to home screen
  int _currentPage = 0; 

  final _pages = const [
    HomePage(),
    MyQrPage(),
    HistoryPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentPage],
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.white,
        indicatorColor: AppColors.lightGreen,
        selectedIndex: _currentPage,
        onDestinationSelected: (index){
          setState(() {
            _currentPage = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.qr_code_2), label: 'My QR'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}