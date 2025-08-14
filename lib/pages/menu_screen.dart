import 'package:flutter/material.dart';
import 'package:perpustakaan/pages/buku/buku_list_screen.dart';
import 'package:perpustakaan/pages/home_screen.dart';
import 'package:perpustakaan/pages/kategori/list_kategori_screen.dart';
import 'package:perpustakaan/pages/peminjaman/list_peminjaman_screen.dart';
import 'package:perpustakaan/pages/profile_screen.dart';
import 'package:perpustakaan/pages/post/list_post_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late PageController _pageController;

  // Color Palette - sama dengan BukuListScreen
  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color secondaryColor = Color(0xFFFBC02D);
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF616161);
  static const Color accentColor = Color(0xFF8D6E63);

  final List<Widget> _pages = [
    HomeScreen(),
    BukuListScreen(),
    ListKategori(),
    ListPeminjamanScreen(),
    ListPostScreen(),
    ProfileScreen()
  ];

  final List<Map<String, dynamic>> _navigationItems = [
    {
      'icon': Icons.home_rounded,
      'activeIcon': Icons.home,
      'label': 'Home',
      'color': primaryColor,
    },
    {
      'icon': Icons.menu_book_rounded,
      'activeIcon': Icons.menu_book,
      'label': 'Buku',
      'color': secondaryColor,
    },
    {
      'icon': Icons.category_rounded,
      'activeIcon': Icons.category,
      'label': 'Kategori',
      'color': accentColor,
    },
    {
      'icon': Icons.bookmark_add_rounded,
      'activeIcon': Icons.bookmark_add,
      'label': 'Pinjam',
      'color': primaryColor,
    },
    {
      'icon': Icons.article_rounded,
      'activeIcon': Icons.article,
      'label': 'Post',
      'color': secondaryColor,
    },
    {
      'icon': Icons.person_rounded,
      'activeIcon': Icons.person,
      'label': 'Profile',
      'color': textSecondary,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );

      // Trigger animation untuk visual feedback
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.08,
            constraints: const BoxConstraints(
              minHeight: 60,
              maxHeight: 80,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.02,
              vertical: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _navigationItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = _currentIndex == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onTabTapped(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutCubic,
                      margin: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.005,
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.height * 0.005,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? item['color'].withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ScaleTransition(
                            scale: isSelected
                                ? _scaleAnimation
                                : const AlwaysStoppedAnimation(1.0),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: EdgeInsets.all(
                                MediaQuery.of(context).size.width > 600
                                    ? (isSelected ? 8 : 6)
                                    : (isSelected ? 6 : 4),
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? item['color']
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: item['color'].withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Icon(
                                isSelected ? item['activeIcon'] : item['icon'],
                                color:
                                    isSelected ? Colors.white : textSecondary,
                                size: isSelected ? 22 : 20,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.005,
                          ),
                          Flexible(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                color:
                                    isSelected ? item['color'] : textSecondary,
                                fontSize:
                                    MediaQuery.of(context).size.width > 600
                                        ? (isSelected ? 12 : 11)
                                        : (isSelected ? 10 : 9),
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                              child: Text(
                                item['label'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
