import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:final_project/screens/bookmark_screen.dart';
import 'package:final_project/screens/home_screen.dart';
import 'package:final_project/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Widget> screens = [HomeScreen(), SearchScreen(), BookmarkScreen(),];

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[selectedIndex],

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey[600],
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_outline),
              activeIcon: Icon(Icons.bookmark),
              label: 'Bookmark',
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.person_outline),
            //   activeIcon: Icon(Icons.person),
            //   label: 'Profile',
            // ),
          ],
        ),
      ),

      // bottomNavigationBar: CurvedNavigationBar(
      //   index: selectedIndex,
      //   height: 60,
      //   backgroundColor: const Color.fromARGB(255, 225, 225, 225),
      //   buttonBackgroundColor: Colors.white,
      //   color: Colors.white,
      //   items: <Widget>[
      //     Icon(Icons.home, size: 30, color: Colors.black),
      //     Icon(Icons.search, size: 30, color: Colors.black),
      //     Icon(Icons.bookmark, size: 30, color: Colors.black),
      //     Icon(Icons.person, size: 30, color: Colors.black),
      //   ],
      //   onTap: (index) {
      //     setState(() {
      //       selectedIndex = index;
      //     });
      //   },
      // ),
    );
  }
}
