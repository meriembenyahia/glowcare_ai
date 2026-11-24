import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/role/role_provider.dart';
import '../../core/theme/widgets/app_colors.dart';
import '../../core/theme/widgets/product_image.dart';
import '../orders/order_model.dart';
import '../orders/orders_provider.dart';
import '../shop/product.dart';
import '../shop/product_provider.dart';
import 'add_product_dialog.dart';

class SellerDashboardScreen extends ConsumerStatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  ConsumerState<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends ConsumerState<SellerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _orderFilter = 'All';
  String _productQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'shipped':
        return Colors.purple;
      case 'confirmed':
        return Colors.blue;
      case 'cancelled':
        return Colors.redAccent;
      case 'pending':
      default:
        return Colors.amber.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final orders = ref.watch(ordersProvider);
    final productsAsync = ref.watch(productsProvider);

    // KPI Metrics calculation
    final totalRevenue = orders.fold<double>(0.0, (sum, o) => sum + o.total);
    final pendingOrders = orders.where((o) => o.status.toLowerCase() == 'pending').length;
    final productsCount = productsAsync.value?.length ?? 0;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.storefront, color: colors.primary, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seller Dashboard',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colors.text,
                    ),
                  ),
                  Text(
                    'GlowCare Merchant Portal · متجر التاجر',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: colors.mutedText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              ref.read(roleProvider.notifier).setRole(AppRole.customer);
            },
            icon: Icon(Icons.swap_horiz, size: 16, color: colors.primary),
            label: Text(
              'Customer View',
              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: colors.primary),
            ),
          ),
          const SizedBox(width: 6),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: colors.primary,
          unselectedLabelColor: colors.mutedText,
          indicatorColor: colors.primary,
          labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.receipt_long, size: 20), text: 'Orders'),
            Tab(icon: Icon(Icons.inventory_2, size: 20), text: 'Products'),
            Tab(icon: Icon(Icons.analytics, size: 20), text: 'Analytics & Settings'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // KPI Summary Row
            _buildKpiRow(colors, isDark, totalRevenue, orders.length, pendingOrders, productsCount),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOrdersTab(colors, isDark, orders),
                  _buildProductsTab(colors, isDark, productsAsync),
                  _buildSettingsTab(colors, isDark, totalRevenue, orders.length),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiRow(
    AppThemeColors colors,
    bool isDark,
    double totalRevenue,
    int ordersCount,
    int pendingCount,
    int productsCount,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        border: Border(bottom: BorderSide(color: colors.primary.withValues(alpha: 0.1))),
      ),
      child: Row(
        children: [
          _kpiCard(colors, 'Total Sales', '${totalRevenue.toStringAsFixed(0)} DA', Icons.monetization_on_outlined, colors.primary),
          const SizedBox(width: 8),
          _kpiCard(colors, 'Orders', '$ordersCount', Icons.shopping_bag_outlined, Colors.blue),
          const SizedBox(width: 8),
          _kpiCard(colors, 'Pending', '$pendingCount', Icons.hourglass_top, Colors.amber.shade800),
          const SizedBox(width: 8),
          _kpiCard(colors, 'Catalog', '$productsCount', Icons.category_outlined, Colors.purple),
        ],
      ),
    );
  }

  Widget _kpiCard(AppThemeColors colors, String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 10, color: colors.mutedText),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: colors.text),
            ),
          ],
        ),
      ),
    );
  }

  // ================= 1. ORDERS TAB =================
  Widget _buildOrdersTab(AppThemeColors colors, bool isDark, List<Order> orders) {
    final filtered = _orderFilter == 'All'
        ? orders
        : orders.where((o) => o.status.toLowerCase() == _orderFilter.toLowerCase()).toList();

    return Column(
      children: [
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Row(
            children: [
              for (final f in ['All', 'Pending', 'Confirmed', 'Shipped', 'Delivered', 'Cancelled'])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(f, style: GoogleFonts.poppins(fontSize: 11)),
                    selected: _orderFilter == f,
                    selectedColor: colors.primary,
                    labelStyle: TextStyle(
                      color: _orderFilter == f
                          ? (isDark ? const Color(0xFF141D1A) : AppColors.white)
                          : colors.text,
                    ),
                    backgroundColor: colors.cardBackground,
                    onSelected: (val) {
                      if (val) setState(() => _orderFilter = f);
                    },
                  ),
                ),
            ],
          ),
        ),

        // Orders list
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined, size: 54, color: colors.mutedText),
                      const SizedBox(height: 10),
                      Text(
                        _orderFilter == 'All'
                            ? 'No customer orders received yet'
                            : 'No orders with status "$_orderFilter"',
                        style: GoogleFonts.poppins(fontSize: 13, color: colors.mutedText),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final order = filtered[i];
                    final statusColor = _statusColor(order.status);

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.cardBackground,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: colors.primary.withValues(alpha: 0.1)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Order ID & Status Badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Order #${order.id}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: colors.text,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${order.date.day}/${order.date.month}/${order.date.year}',
                                    style: GoogleFonts.poppins(fontSize: 11, color: colors.mutedText),
                                  ),
                                ],
                              ),
                              _statusBadge(order.status, statusColor),
                            ],
                          ),
                          const Divider(height: 18),

                          // Customer Info
                          Row(
                            children: [
                              Icon(Icons.person, size: 16, color: colors.primary),
                              const SizedBox(width: 6),
                              Text(
                                '${order.firstName} ${order.lastName}',
                                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: colors.text),
                              ),
                              const Spacer(),
                              Icon(Icons.phone, size: 14, color: colors.mutedText),
                              const SizedBox(width: 4),
                              Text(order.phone, style: GoogleFonts.poppins(fontSize: 12, color: colors.text)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined, size: 16, color: colors.mutedText),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${order.wilaya} · ${order.address}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(fontSize: 12, color: colors.mutedText),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Items preview
                          Text(
                            'Items ordered (${order.items.length}):',
                            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: colors.mutedText),
                          ),
                          const SizedBox(height: 4),
                          for (final it in order.items)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text('• ${it.product.name} (x${it.quantity})',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(fontSize: 12, color: colors.text)),
                                  ),
                                  Text('${(it.product.price * it.quantity).toStringAsFixed(0)} DA',
                                      style: GoogleFonts.poppins(fontSize: 12, color: colors.text)),
                                ],
                              ),
                            ),
                          const SizedBox(height: 8),

                          // Total and Status update action
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total: ${order.total.toStringAsFixed(0)} DA',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: colors.primary,
                                ),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (newStatus) {
                                  ref.read(ordersProvider.notifier).updateStatus(order.id, newStatus);
                                },
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                color: colors.cardBackground,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: colors.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Update Status',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: colors.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.arrow_drop_down, size: 16, color: colors.primary),
                                    ],
                                  ),
                                ),
                                itemBuilder: (context) => [
                                  for (final s in ['Pending', 'Confirmed', 'Shipped', 'Delivered', 'Cancelled'])
                                    PopupMenuItem(
                                      value: s,
                                      child: Text(s, style: TextStyle(color: colors.text, fontSize: 13)),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _statusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  // ================= 2. PRODUCTS TAB =================
  Widget _buildProductsTab(AppThemeColors colors, bool isDark, AsyncValue<List<Product>> productsAsync) {
    return Column(
      children: [
        // Search & Add product bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _productQuery = v.trim().toLowerCase()),
                  style: GoogleFonts.poppins(fontSize: 13, color: colors.text),
                  decoration: InputDecoration(
                    hintText: 'Search inventory...',
                    hintStyle: GoogleFonts.poppins(fontSize: 12, color: colors.mutedText),
                    prefixIcon: Icon(Icons.search, size: 18, color: colors.mutedText),
                    fillColor: colors.inputFill,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const AddProductDialog(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: isDark ? const Color(0xFF141D1A) : AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: Text('Add Item', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),

        // Products list
        Expanded(
          child: productsAsync.when(
            loading: () => Center(child: CircularProgressIndicator(color: colors.primary)),
            error: (e, _) => Center(child: Text('Error: $e', style: TextStyle(color: colors.text))),
            data: (products) {
              final list = _productQuery.isEmpty
                  ? products
                  : products.where((p) =>
                      p.name.toLowerCase().contains(_productQuery) ||
                      p.brand.toLowerCase().contains(_productQuery) ||
                      p.category.toLowerCase().contains(_productQuery)).toList();

              if (list.isEmpty) {
                return Center(
                  child: Text('No products found matching "$_productQuery"',
                      style: GoogleFonts.poppins(color: colors.mutedText)),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final p = list[i];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.primary.withValues(alpha: 0.08)),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: ProductImage(path: p.image, size: 60),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: colors.text,
                                ),
                              ),
                              Text(
                                '${p.brand} · ${p.category}',
                                style: GoogleFonts.poppins(fontSize: 11, color: colors.mutedText),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${p.price.toStringAsFixed(0)} DA',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: colors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit_outlined, color: colors.primary, size: 20),
                          tooltip: 'Edit Product',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => AddProductDialog(productToEdit: p),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                          tooltip: 'Delete Product',
                          onPressed: () {
                            _confirmDeleteProduct(p);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _confirmDeleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to remove "${product.name}" from your catalog?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              ref.read(productsProvider.notifier).deleteProduct(product.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ================= 3. SETTINGS & ANALYTICS TAB =================
  Widget _buildSettingsTab(AppThemeColors colors, bool isDark, double totalRevenue, int ordersCount) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Store Details & Commercial Settings',
              style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w700, color: colors.text)),
          const SizedBox(height: 12),

          _settingCard(colors, [
            _tile(colors, Icons.store, 'Store Commercial Name', 'GlowCare Cosmetics SARL'),
            _tile(colors, Icons.badge, 'Commercial License', 'E-Commerce Retail (Algeria - 58 Wilayas)'),
            _tile(colors, Icons.local_shipping, 'Default Delivery Fee', '500 DA'),
            _tile(colors, Icons.currency_exchange, 'Operating Currency', 'Algerian Dinar (DZD / DA)'),
          ]),
          const SizedBox(height: 20),

          Text('Inventory & Demo Data Actions',
              style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w700, color: colors.text)),
          const SizedBox(height: 12),

          _settingCard(colors, [
            ListTile(
              leading: Icon(Icons.refresh, color: colors.primary),
              title: Text('Reset Catalog to Demo Default', style: GoogleFonts.poppins(fontSize: 13, color: colors.text)),
              subtitle: Text('Restore original 16 products catalog', style: GoogleFonts.poppins(fontSize: 11, color: colors.mutedText)),
              trailing: ElevatedButton(
                onPressed: () async {
                  await ref.read(productsProvider.notifier).resetToDefaults();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Catalog restored to defaults')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: isDark ? const Color(0xFF141D1A) : AppColors.white,
                  minimumSize: const Size(80, 36),
                ),
                child: const Text('Reset', style: TextStyle(fontSize: 12)),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _settingCard(AppThemeColors colors, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(children: children),
    );
  }

  Widget _tile(AppThemeColors colors, IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: colors.primary, size: 22),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 12, color: colors.mutedText)),
      subtitle: Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: colors.text)),
    );
  }
}
