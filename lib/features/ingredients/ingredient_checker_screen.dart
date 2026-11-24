import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/localization/app_strings.dart';
import '../../core/services/ai_service.dart';
import '../../core/theme/widgets/app_colors.dart';
import '../../core/theme/widgets/app_logo.dart';
import '../../core/theme/widgets/product_image.dart';
import '../../core/utils/text_format.dart';
import '../ai_advisor/ai_settings_dialog.dart';
import '../auth/auth_provider.dart';
import '../auth/member_lock_view.dart';
import '../cart/cart_provider.dart';
import '../shop/product.dart';
import '../shop/product_details_screen.dart';
import '../shop/product_provider.dart';

const String kGreetingMessage =
    'Hello! 🌸 I am your Beauty Lab Skincare AI.\n\n'
    'Ask me anything about customized routines, active ingredients synergy (Retinol, Vitamin C, Niacinamide, BHA), product safety, or store recommendations in Algeria.\n\n'
    '💬 You can write in العربية / الدارجة, Français, or English!';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  final List<Product>? recommendedProducts;
  final int? safetyScore;
  final String? translationKey;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.recommendedProducts,
    this.safetyScore,
    this.translationKey,
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
  AiProvider _provider = AiProvider.openai;

  List<String> _quickPrompts(AppStrings s) => [
        s.t('روتين حب الشباب والبشرة الدهنية؟'),
        s.t('Can I mix Retinol with Vitamin C?'),
        s.t('شحال التوصيل لكل الولايات؟'),
        s.t('Réparer barrière cutanée abîmée?'),
        s.t('Best serum for dark spots & glow?'),
        s.t('Safe ingredients for sensitive skin?'),
      ];

  @override
  void initState() {
    super.initState();
    _checkApiKey();
    _messages.add(
      ChatMessage(
        text: kGreetingMessage,
        isUser: false,
        time: DateTime.now(),
        translationKey: kGreetingMessage,
      ),
    );
  }

  Future<void> _checkApiKey() async {
    final config = await AiService.instance.getConfig();
    if (mounted) {
      setState(() {
        _hasApiKey = config.isConfigured;
        _provider = config.provider;
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
      localeCode: Localizations.localeOf(context).languageCode,
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

      if ((combined.contains('acne') ||
              combined.contains('حب الشباب') ||
              combined.contains('دهنية')) &&
          (pDesc.contains('acne') ||
              pDesc.contains('blemish') ||
              pName.contains('effaclar'))) {
        score += 5;
      }
      if ((combined.contains('retinol') || combined.contains('ريتينول')) &&
          (pDesc.contains('retinol') || pName.contains('retinol'))) {
        score += 5;
      }
      if ((combined.contains('vitamin c') ||
              combined.contains('فيتامين') ||
              combined.contains('vitamine c')) &&
          (pDesc.contains('vitamin c') ||
              pName.contains('vitamin c') ||
              pName.contains('glow'))) {
        score += 5;
      }
      if ((combined.contains('dry') ||
              combined.contains('جفاف') ||
              combined.contains('sèche')) &&
          (pDesc.contains('moistur') || pName.contains('cerave'))) {
        score += 4;
      }
      if ((combined.contains('dark spot') ||
              combined.contains('بقع') ||
              combined.contains('tache')) &&
          (pDesc.contains('dark spot') ||
              pDesc.contains('brighten') ||
              pName.contains('glow'))) {
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
    final s = AppStrings.of(context);
    final isGuest = ref.watch(authProvider) == AuthStatus.guest;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        title: Row(
          children: [
            const AppLogo(size: 34),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.t('Beauty Lab AI Advisor'),
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
                        _hasApiKey
                            ? '${s.t(_provider.labelKey)} · ${s.t('Online')}'
                            : s.t('Smart Skincare AI · Active'),
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
          if (!isGuest)
            IconButton(
              icon: Icon(Icons.settings_outlined, color: colors.primary),
              tooltip: s.t('AI Advisor Settings'),
              onPressed: () async {
                await AiSettingsDialog.show(context);
                _checkApiKey();
              },
            ),
        ],
      ),
      body: isGuest
          ? const MemberLockView()
          : SafeArea(
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
                  return _buildMessageBubble(msg, colors, isDark, s);
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
                          ? s.t('AI is analyzing your skincare profile...')
                          : s.t('GlowCare AI is analyzing cosmetic formulations...'),
                      style: GoogleFonts.poppins(fontSize: 11, fontStyle: FontStyle.italic, color: colors.mutedText),
                    ),
                  ],
                ),
              ),

            if (!_hasApiKey)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: InkWell(
                  onTap: () async {
                    await AiSettingsDialog.show(context);
                    _checkApiKey();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.vpn_key_outlined, size: 16, color: colors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            s.t('Connect a free AI key for deeper consultations'),
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: colors.primary,
                            ),
                          ),
                        ),
                        Icon(s.chevronIcon(context), size: 14, color: colors.primary),
                      ],
                    ),
                  ),
                ),
              ),

            // Quick Prompt Suggestions
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 8),
              child: Row(
                children: [
                  for (final prompt in _quickPrompts(s))
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
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
                        hintText: s.t('Ask about your routine, retinol, or consult the AI...'),
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

  Widget _buildMessageBubble(
    ChatMessage msg,
    AppThemeColors colors,
    bool isDark,
    AppStrings s,
  ) {
    final text = msg.translationKey != null
        ? s.t(msg.translationKey!)
        : msg.text;

    if (msg.isUser) {
      return Align(
        alignment: AlignmentDirectional.centerEnd,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 290),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: const BorderRadiusDirectional.only(
              topStart: Radius.circular(18),
              topEnd: Radius.circular(18),
              bottomStart: Radius.circular(18),
              bottomEnd: Radius.circular(4),
            ),
          ),
          child: Text(
            text,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
          ),
        ),
      );
    }

    // AI Response Bubble
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 330),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: const BorderRadiusDirectional.only(
            topStart: Radius.circular(18),
            topEnd: Radius.circular(18),
            bottomStart: Radius.circular(4),
            bottomEnd: Radius.circular(18),
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
                Flexible(
                  child: Text(
                    _hasApiKey
                        ? s.t('ChatGPT Skincare Expert')
                        : s.t('GlowCare Beauty Lab AI'),
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              stripMarkdown(text),
              style: GoogleFonts.poppins(fontSize: 12.5, height: 1.55, color: colors.text),
            ),

            // Product Recommendation Cards inside chat
            if (msg.recommendedProducts != null && msg.recommendedProducts!.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                s.t('Recommended Store Products:'),
                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: colors.primary),
              ),
              const SizedBox(height: 8),
              for (final p in msg.recommendedProducts!)
                Container(
                  margin: const EdgeInsetsDirectional.only(bottom: 6),
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
                              s.money(p.price),
                              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: colors.primary),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_shopping_cart, size: 18, color: colors.primary),
                        tooltip: s.t('Add to Cart'),
                        onPressed: () {
                          ref.read(cartProvider.notifier).add(p);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(s.tf('{name} added to cart!', {'name': p.name})),
                              backgroundColor: AppColors.deepGreen,
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(s.chevronIcon(context), size: 16, color: colors.mutedText),
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
