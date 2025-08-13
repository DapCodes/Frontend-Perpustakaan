import 'package:flutter/material.dart';
import 'package:perpustakaan/pages/buku/buku_list_screen.dart';
import 'package:perpustakaan/pages/home_screen.dart';
import 'package:perpustakaan/pages/kategori/list_kategori_screen.dart';
import 'package:perpustakaan/pages/profile_screen.dart';
import 'package:perpustakaan/pages/post/list_post_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    BukuListScreen(),
    ListKategori(),
    ListPostScreen(),
    ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('Dashboard')),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color.fromARGB(255, 44, 42, 42),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Buku'),
          BottomNavigationBarItem(
              icon: Icon(Icons.category), label: 'Kategori'),
          BottomNavigationBarItem(
              icon: Icon(Icons.post_add_outlined), label: 'Post'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
