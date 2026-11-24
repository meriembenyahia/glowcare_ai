import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/app_strings.dart';
import '../../core/role/role_provider.dart';
import '../../core/theme/widgets/app_colors.dart';
import '../developer/developer_console_screen.dart';
import '../ingredients/ingredient_checker_screen.dart';
import '../orders/order_history_screen.dart';
import '../routine/routine_screen.dart';
import '../seller/seller_dashboard_screen.dart';
import '../shop/shop_screen.dart';
import 'home_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
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
    final activeRole = ref.watch(roleProvider);

    // Switch view according to active commercial role
    if (activeRole == AppRole.seller) {
      return const SellerDashboardScreen();
    }
    if (activeRole == AppRole.developer) {
      return const DeveloperConsoleScreen();
    }

    final colors = AppThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final strings = AppStrings.of(context);

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
            label: strings.navHome,
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined, color: colors.mutedText),
            selectedIcon: Icon(Icons.shopping_bag, color: colors.primary),
            label: strings.navShop,
          ),
          NavigationDestination(
            icon: Icon(Icons.science_outlined, color: colors.mutedText),
            selectedIcon: Icon(Icons.science, color: colors.primary),
            label: strings.navBeautyLab,
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined, color: colors.mutedText),
            selectedIcon: Icon(Icons.calendar_month, color: colors.primary),
            label: strings.navRoutine,
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined, color: colors.mutedText),
            selectedIcon: Icon(Icons.receipt_long, color: colors.primary),
            label: strings.navOrders,
          ),
        ],
      ),
    );
  }
}
