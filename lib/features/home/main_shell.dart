import 'package:flutter/material.dart';
import '../../core/theme/widgets/app_colors.dart';
import '../orders/order_history_screen.dart';
import '../shop/shop_screen.dart';
import '../routine/routine_screen.dart';
import 'home_screen.dart';
import '../ingredients/ingredient_checker_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const ShopScreen(),
    const IngredientCheckerScreen(),
    const RoutineScreen(),
    const OrderHistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.background,
        indicatorColor: AppColors.cream,
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.deepGreen),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag, color: AppColors.deepGreen),
            label: 'Shop',
          ),
          NavigationDestination(
            icon: Icon(Icons.science_outlined),
            selectedIcon: Icon(Icons.science, color: AppColors.deepGreen),
            label: 'Beauty Lab',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon:
            Icon(Icons.calendar_month, color: AppColors.deepGreen),
            label: 'Routine',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long, color: AppColors.deepGreen),
            label: 'Orders',
          ),
        ],
      ),
    );
  }
}