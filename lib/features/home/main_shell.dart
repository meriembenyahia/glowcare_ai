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

  final List<Widget> _pages = const [
    HomeScreen(),
    ShopScreen(),
    IngredientCheckerScreen(),
    RoutineScreen(),
    OrderHistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.background,
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        backgroundColor: colors.background,
        indicatorColor: isDark ? colors.cardBackground : AppColors.cream,
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: colors.mutedText),
            selectedIcon: Icon(Icons.home, color: colors.primary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined, color: colors.mutedText),
            selectedIcon: Icon(Icons.shopping_bag, color: colors.primary),
            label: 'Shop',
          ),
          NavigationDestination(
            icon: Icon(Icons.science_outlined, color: colors.mutedText),
            selectedIcon: Icon(Icons.science, color: colors.primary),
            label: 'Beauty Lab',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined, color: colors.mutedText),
            selectedIcon: Icon(Icons.calendar_month, color: colors.primary),
            label: 'Routine',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined, color: colors.mutedText),
            selectedIcon: Icon(Icons.receipt_long, color: colors.primary),
            label: 'Orders',
          ),
        ],
      ),
    );
  }
}
