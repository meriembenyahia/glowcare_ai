import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/role/role_provider.dart';
import '../../core/services/ai_service.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/widgets/app_colors.dart';
import '../ai_advisor/ai_settings_dialog.dart';
import '../loyalty/loyalty_card_screen.dart';
import '../loyalty/loyalty_provider.dart';
import '../orders/orders_provider.dart';
import '../shop/product_provider.dart';

class DeveloperConsoleScreen extends ConsumerStatefulWidget {
  const DeveloperConsoleScreen({super.key});

  @override
  ConsumerState<DeveloperConsoleScreen> createState() => _DeveloperConsoleScreenState();
}

class _DeveloperConsoleScreenState extends ConsumerState<DeveloperConsoleScreen> {
  bool _isTestingApi = false;
  String? _apiPingResult;

  Future<void> _testSupabase() async {
    setState(() {
      _isTestingApi = true;
      _apiPingResult = null;
    });

    final stopwatch = Stopwatch()..start();
    try {
      final products = await SupabaseService.getProducts();
      stopwatch.stop();
      if (mounted) {
        setState(() {
          _isTestingApi = false;
          _apiPingResult = products != null
              ? '✅ Connected! Latency: ${stopwatch.elapsedMilliseconds}ms (${products.length} remote items found)'
              : '⚠️ Supabase returned 0 items or offline fallback is active (${stopwatch.elapsedMilliseconds}ms)';
        });
      }
    } catch (e) {
      stopwatch.stop();
      if (mounted) {
        setState(() {
          _isTestingApi = false;
          _apiPingResult = '❌ Error connecting: $e (${stopwatch.elapsedMilliseconds}ms)';
        });
      }
    }
  }

  void _exportJsonDump() {
    final orders = ref.read(ordersProvider);
    final products = ref.read(productsProvider).value ?? [];

    final dump = {
      'system': 'GlowCare AI E-Commerce Platform',
      'exportDate': DateTime.now().toIso8601String(),
      'license': 'GLOWCARE-ENTERPRISE-PRO-2026',
      'totalProducts': products.length,
      'totalOrders': orders.length,
      'products': products.map((p) => p.toJson()).toList(),
      'orders': orders.map((o) => o.toJson()).toList(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(dump);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('JSON Database Dump'),
        content: SizedBox(
          width: double.maxFinite,
          height: 350,
          child: SingleChildScrollView(
            child: SelectableText(
              jsonString,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonString));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('JSON copied to clipboard!')),
              );
            },
            child: const Text('Copy JSON'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final orders = ref.watch(ordersProvider);
    final products = ref.watch(productsProvider).value ?? [];

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
                color: Colors.blue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.terminal, color: Colors.blue, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Developer Console',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colors.text,
                    ),
                  ),
                  Text(
                    'Technical Diagnostics & Architecture · واجهة المطور',
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. SaaS Platform License Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withValues(alpha: isDark ? 0.3 : 0.15),
                      colors.primary.withValues(alpha: isDark ? 0.2 : 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Commercial Turnkey Solution',
                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: colors.text),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('LICENSE ACTIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Ready-to-Sell E-Commerce Mobile Platform (Flutter & Dart)\nTenant: GlowCare Cosmetics SARL · License: GLOWCARE-ENTERPRISE-PRO-2026',
                      style: GoogleFonts.poppins(fontSize: 11, color: colors.mutedText, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Cloud Backend & Supabase Status
              Text(
                'Cloud Backend & REST API Health',
                style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w700, color: colors.text),
              ),
              const SizedBox(height: 10),
              _card(colors, [
                ListTile(
                  leading: const Icon(Icons.cloud_done, color: Colors.green),
                  title: Text('Supabase Cloud Backend', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: colors.text)),
                  subtitle: Text(
                    'URL: https://ppphfquwtjyacbeewjyc.supabase.co\nStatus: ${SupabaseService.isInitialized ? "Initialized & Online" : "Local Standby Mode"}',
                    style: GoogleFonts.poppins(fontSize: 11, color: colors.mutedText),
                  ),
                  trailing: ElevatedButton(
                    onPressed: _isTestingApi ? null : _testSupabase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: isDark ? const Color(0xFF141D1A) : AppColors.white,
                      minimumSize: const Size(80, 36),
                    ),
                    child: _isTestingApi
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Ping API', style: TextStyle(fontSize: 11)),
                  ),
                ),
                if (_apiPingResult != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(
                      _apiPingResult!,
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: colors.text),
                    ),
                  ),
              ]),
              const SizedBox(height: 20),

              // 3. Database Tables Diagnostic
              Text(
                'Database Tables & Record Counts',
                style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w700, color: colors.text),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _tableKpi(colors, 'products', '${products.length}', 'Active Catalog Items', Icons.inventory),
                  const SizedBox(width: 10),
                  _tableKpi(colors, 'orders', '${orders.length}', 'Client Orders Stored', Icons.receipt_long),
                  const SizedBox(width: 10),
                  _tableKpi(colors, 'wilayas', '58', 'Algeria Wilayas Matrix', Icons.map),
                ],
              ),
              const SizedBox(height: 20),

              // 4. AI Engine Diagnostics
              Text(
                'AI Subsystems Diagnostics',
                style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w700, color: colors.text),
              ),
              const SizedBox(height: 10),
              _card(colors, [
                _aiModuleTile(colors, 'AI Skin Consultation Advisor', 'Heuristic 3-factor diagnostic model (Skin type, concerns, climate factors)', true),
                const Divider(height: 1),
                _aiModuleTile(colors, 'Beauty Lab AI Formula Analyzer', 'Cosmetic chemical rule engine, clash detection & 0-100 safety score matrix', true),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.psychology, color: Colors.purple),
                  title: Text('OpenAI ChatGPT Integration', style: GoogleFonts.poppins(fontSize: 13, color: colors.text)),
                  subtitle: FutureBuilder<String?>(
                    future: AiService.instance.getApiKey(),
                    builder: (context, snapshot) {
                      final hasKey = snapshot.data != null && snapshot.data!.isNotEmpty;
                      return Text(
                        hasKey ? 'Status: Active (API key configured)' : 'Status: Smart Local Engine (No API key set)',
                        style: GoogleFonts.poppins(fontSize: 11, color: hasKey ? Colors.green : Colors.orange),
                      );
                    },
                  ),
                  trailing: OutlinedButton(
                    onPressed: () async {
                      await AiSettingsDialog.show(context);
                      setState(() {});
                    },
                    child: const Text('Configure', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.card_membership, color: Colors.amber),
                  title: Text('Carte de Fidélité (Loyalty System)', style: GoogleFonts.poppins(fontSize: 13, color: colors.text)),
                  subtitle: Consumer(
                    builder: (context, ref, _) {
                      final l = ref.watch(loyaltyProvider);
                      return Text(
                        'Current Points: ${l.totalPoints} pts • Tier: ${l.tier.emoji} ${l.tier.label}',
                        style: GoogleFonts.poppins(fontSize: 11, color: colors.mutedText),
                      );
                    },
                  ),
                  trailing: OutlinedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoyaltyCardScreen()),
                    ),
                    child: const Text('Open Card', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ]),
              const SizedBox(height: 20),

              // 5. Developer Actions
              Text(
                'Developer Data Actions',
                style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w700, color: colors.text),
              ),
              const SizedBox(height: 10),
              _card(colors, [
                ListTile(
                  leading: const Icon(Icons.data_object, color: Colors.blue),
                  title: Text('Export JSON Database Dump', style: GoogleFonts.poppins(fontSize: 13, color: colors.text)),
                  subtitle: Text('Generate full structured JSON of products and orders', style: GoogleFonts.poppins(fontSize: 11, color: colors.mutedText)),
                  trailing: OutlinedButton(
                    onPressed: _exportJsonDump,
                    child: const Text('Export', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.settings_backup_restore, color: Colors.orange),
                  title: Text('Seed Demo Products Catalog', style: GoogleFonts.poppins(fontSize: 13, color: colors.text)),
                  subtitle: Text('Populate catalog with 16 high-grade beauty products', style: GoogleFonts.poppins(fontSize: 11, color: colors.mutedText)),
                  trailing: OutlinedButton(
                    onPressed: () async {
                      await ref.read(productsProvider.notifier).resetToDefaults();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Demo products catalog populated successfully!')),
                      );
                    },
                    child: const Text('Seed', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ]),
              const SizedBox(height: 20),

              // 6. Technology Specifications
              Text(
                'Tech Stack & Architecture',
                style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w700, color: colors.text),
              ),
              const SizedBox(height: 10),
              _card(colors, [
                _specRow(colors, 'Framework', 'Flutter 3.x (Cross-Platform Android/iOS/Web)'),
                _specRow(colors, 'Language', 'Dart 3.x with Null Safety'),
                _specRow(colors, 'State Management', 'Riverpod 3.x (AsyncNotifier + Notifier)'),
                _specRow(colors, 'Local Caching', 'SharedPreferences (Offline-First Architecture)'),
                _specRow(colors, 'Cloud & BaaS', 'Supabase (PostgreSQL with Row Level Security)'),
                _specRow(colors, 'Architecture', 'Feature-First Clean Architecture'),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(AppThemeColors colors, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(children: children),
    );
  }

  Widget _tableKpi(AppThemeColors colors, String tableName, String count, String desc, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.primary.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: colors.primary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    tableName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(count, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: colors.primary)),
            Text(desc, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 9, color: colors.mutedText)),
          ],
        ),
      ),
    );
  }

  Widget _aiModuleTile(AppThemeColors colors, String title, String desc, bool isReady) {
    return ListTile(
      leading: const Icon(Icons.auto_awesome, color: Colors.purple),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: colors.text)),
      subtitle: Text(desc, style: GoogleFonts.poppins(fontSize: 11, color: colors.mutedText)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('READY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.green)),
      ),
    );
  }

  Widget _specRow(AppThemeColors colors, String key, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: colors.mutedText)),
          Expanded(
            child: Text(
              val,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(fontSize: 12, color: colors.text),
            ),
          ),
        ],
      ),
    );
  }
}
