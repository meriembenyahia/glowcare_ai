import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/ai_service.dart';
import '../../core/theme/widgets/app_colors.dart';
import '../../core/theme/widgets/product_image.dart';
import '../ai_advisor/ai_settings_dialog.dart';
import '../cart/cart_provider.dart';
import '../shop/product.dart';
import '../shop/product_details_screen.dart';
import '../shop/product_provider.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  final List<Product>? recommendedProducts;
  final int? safetyScore;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.recommendedProducts,
    this.safetyScore,
  });
}

class IngredientCheckerScreen extends ConsumerStatefulWidget {
  const IngredientCheckerScreen({super.key});

  @override
  ConsumerState<IngredientCheckerScreen> createState() => _IngredientCheckerScreenState();
}

class _IngredientCheckerScreenState extends ConsumerState<IngredientCheckerScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _hasApiKey = false;

  static const List<String> _quickPrompts = [
    'روتين حب الشباب والبشرة الدهنية؟',
    'Can I mix Retinol with Vitamin C?',
    'شحال التوصيل لكل الولايات؟',
    'Réparer barrière cutanée abîmée?',
    'Best serum for dark spots & glow?',
    'Safe ingredients for sensitive skin?',
  ];

  @override
  void initState() {
    super.initState();
    _checkApiKey();
    _messages.add(
      ChatMessage(
        text: 'Hello! 🌸 I am your **Beauty Lab Skincare AI**.\n\n'
            'Ask me anything about customized routines, active ingredients synergy (Retinol, Vitamin C, Niacinamide, BHA), product safety, or store recommendations in Algeria.\n\n'
            '💬 *You can write in العربية / الدارجة, Français, or English!*',
        isUser: false,
        time: DateTime.now(),
      ),
    );
  }

  Future<void> _checkApiKey() async {
    final key = await AiService.instance.getApiKey();
    if (mounted) {
      setState(() {
        _hasApiKey = key != null && key.isNotEmpty;
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String query) async {
    final text = query.trim();
    if (text.isEmpty || _isTyping) return;

    _textController.clear();
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true, time: DateTime.now()));
      _isTyping = true;
    });
    _scrollToBottom();

    final allProducts = ref.read(productsProvider).value ?? [];

    // Build context history for ChatGPT
    final history = <Map<String, String>>[];
    final recent = _messages.take(_messages.length - 1).toList();
    final start = recent.length > 6 ? recent.length - 6 : 0;
    for (int i = start; i < recent.length; i++) {
      final m = recent[i];
      history.add({
        'role': m.isUser ? 'user' : 'assistant',
        'content': m.text,
      });
    }

    final responseText = await AiService.instance.askChatGpt(
      userMessage: text,
      conversationHistory: history,
      catalog: allProducts,
    );

    final matched = _findRelevantProducts(text, responseText, allProducts);

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(
          text: responseText,
          isUser: false,
          time: DateTime.now(),
          recommendedProducts: matched.isNotEmpty ? matched : null,
        ));
      });
      _scrollToBottom();
    }
  }

  List<Product> _findRelevantProducts(String userQuery, String aiResponse, List<Product> catalog) {
    if (catalog.isEmpty) return [];

    final combined = '$userQuery $aiResponse'.toLowerCase();
    final scored = <Product, int>{};

    for (final p in catalog) {
      int score = 0;
      final pName = p.name.toLowerCase();
      final pBrand = p.brand.toLowerCase();
      final pDesc = p.description.toLowerCase();

      if (combined.contains(pName)) score += 10;
      if (combined.contains(pBrand)) score += 4;

      for (final ing in p.ingredients) {
        if (combined.contains(ing.toLowerCase())) score += 3;
      }

      if (combined.contains('acne') && (pDesc.contains('acne') || pDesc.contains('blemish') || pName.contains('effaclar'))) {
        score += 5;
      }
      if (combined.contains('retinol') && (pDesc.contains('retinol') || pName.contains('retinol'))) {
        score += 5;
      }
      if (combined.contains('vitamin c') && (pDesc.contains('vitamin c') || pName.contains('vitamin c'))) {
        score += 5;
      }
      if (combined.contains('dry') && (pDesc.contains('moistur') || pName.contains('cerave'))) {
        score += 4;
      }

      if (score > 2) {
        scored[p] = score;
      }
    }

    final sorted = scored.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.map((e) => e.key).take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome, color: colors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Beauty Lab AI Advisor',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colors.text,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: _hasApiKey ? Colors.green : Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _hasApiKey ? 'ChatGPT (OpenAI) · Online' : 'Smart Skincare AI · Active',
                        style: GoogleFonts.poppins(fontSize: 10, color: colors.mutedText),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: colors.primary),
            tooltip: 'ChatGPT Settings (OpenAI Key)',
            onPressed: () async {
              await AiSettingsDialog.show(context);
              _checkApiKey();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Messages List
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                itemCount: _messages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, i) {
                  final msg = _messages[i];
                  return _buildMessageBubble(msg, colors, isDark);
                },
              ),
            ),

            // Typing Indicator
            if (_isTyping)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: colors.primary),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _hasApiKey
                          ? 'ChatGPT is analyzing your skincare profile...'
                          : 'GlowCare AI is analyzing cosmetic formulations...',
                      style: GoogleFonts.poppins(fontSize: 11, fontStyle: FontStyle.italic, color: colors.mutedText),
                    ),
                  ],
                ),
              ),

            // Quick Prompt Suggestions
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                children: [
                  for (final prompt in _quickPrompts)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: Text(prompt, style: GoogleFonts.poppins(fontSize: 11)),
                        backgroundColor: colors.cardBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: colors.primary.withValues(alpha: 0.15)),
                        ),
                        labelStyle: TextStyle(color: colors.text),
                        onPressed: () => _sendMessage(prompt),
                      ),
                    ),
                ],
              ),
            ),

            // Input Bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              decoration: BoxDecoration(
                color: colors.cardBackground,
                border: Border(top: BorderSide(color: colors.primary.withValues(alpha: 0.08))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: GoogleFonts.poppins(fontSize: 13, color: colors.text),
                      decoration: InputDecoration(
                        hintText: 'اسأل عن روتينك، الريتينول، أو استشر الذكاء الاصطناعي...',
                        hintStyle: GoogleFonts.poppins(fontSize: 12, color: colors.mutedText),
                        fillColor: colors.inputFill,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 19),
                      onPressed: () => _sendMessage(_textController.text),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, AppThemeColors colors, bool isDark) {
    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 290),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Text(
            msg.text,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
          ),
        ),
      );
    }

    // AI Response Bubble
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 330),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: colors.primary.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, color: colors.primary, size: 15),
                const SizedBox(width: 6),
                Text(
                  _hasApiKey ? 'ChatGPT Skincare Expert' : 'GlowCare Beauty Lab AI',
                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: colors.primary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              msg.text,
              style: GoogleFonts.poppins(fontSize: 12.5, height: 1.55, color: colors.text),
            ),

            // Product Recommendation Cards inside chat
            if (msg.recommendedProducts != null && msg.recommendedProducts!.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                'Recommended Store Products:',
                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: colors.primary),
              ),
              const SizedBox(height: 8),
              for (final p in msg.recommendedProducts!)
                Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.inputFill,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.primary.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ProductImage(path: p.image, size: 44),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: colors.text),
                            ),
                            Text(
                              '${p.price.toStringAsFixed(0)} DA',
                              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: colors.primary),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_shopping_cart, size: 18, color: colors.primary),
                        tooltip: 'Add to Cart',
                        onPressed: () {
                          ref.read(cartProvider.notifier).add(p);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${p.name} added to cart!'), backgroundColor: AppColors.deepGreen),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_forward_ios, size: 12, color: colors.mutedText),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: p)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
