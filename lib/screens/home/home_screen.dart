import 'package:flutter/material.dart';
import 'package:katholiks/utils/app_colors.dart';
import '../../services/rosary_service.dart';
import 'pages/home_page.dart';
import 'pages/explore_page.dart';
import 'pages/community_page.dart';
import 'pages/profile_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _pulseController;
  late AnimationController _streakController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _streakAnimation;
  final RosaryService _rosaryService = RosaryService.instance;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _streakController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _streakAnimation = Tween<double>(
      begin: 0,
      end: 2 * 3.14159,
    ).animate(CurvedAnimation(
      parent: _streakController,
      curve: Curves.linear,
    ));

    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _rosaryService.initialize();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _streakController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          GamifiedHomePage(
            pulseAnimation: _pulseAnimation,
            streakAnimation: _streakAnimation,
          ),
          const ExplorePage(),
          const CommunityPage(),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2D2D2D)
          : Colors.white,
      elevation: 0,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Início',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore_rounded),
          label: 'Explorar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.groups_rounded),
          label: 'Comunidade',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Perfil',
        ),
      ],
    );
  }
}
