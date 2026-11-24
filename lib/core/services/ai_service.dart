import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/shop/product.dart';

class AiService {
  static final AiService instance = AiService._internal();
  AiService._internal();

  static const String _keyApiKey = 'openai_api_key';
  static const String _keyModel = 'openai_model';
  static const String defaultModel = 'gpt-4o-mini';

  String? _cachedKey;
  String _model = defaultModel;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _cachedKey = prefs.getString(_keyApiKey)?.trim();
    _model = prefs.getString(_keyModel) ?? defaultModel;
  }

  Future<String?> getApiKey() async {
    if (_cachedKey != null) return _cachedKey;
    final prefs = await SharedPreferences.getInstance();
    _cachedKey = prefs.getString(_keyApiKey)?.trim();
    return _cachedKey;
  }

  Future<void> setApiKey(String key) async {
    final clean = key.trim();
    _cachedKey = clean;
    final prefs = await SharedPreferences.getInstance();
    if (clean.isEmpty) {
      await prefs.remove(_keyApiKey);
      _cachedKey = null;
    } else {
      await prefs.setString(_keyApiKey, clean);
    }
  }

  Future<String> getModel() async {
    final prefs = await SharedPreferences.getInstance();
    _model = prefs.getString(_keyModel) ?? defaultModel;
    return _model;
  }

  Future<void> setModel(String model) async {
    _model = model;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyModel, model);
  }

  bool get hasKey => _cachedKey != null && _cachedKey!.isNotEmpty;

  /// Test an OpenAI API key to verify connectivity
  Future<Map<String, dynamic>> testConnection(String testKey) async {
    final cleanKey = testKey.trim();
    if (cleanKey.isEmpty) {
      return {'success': false, 'message': 'API Key cannot be empty'};
    }

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $cleanKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'user', 'content': 'Hello, respond with OK'}
          ],
          'max_tokens': 10,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Connected successfully to ChatGPT!'};
      } else {
        final body = jsonDecode(response.body);
        final err = body['error']?['message'] ?? 'Status code: ${response.statusCode}';
        return {'success': false, 'message': 'OpenAI Error: $err'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Send message to ChatGPT with skincare system prompt & catalog context
  Future<String> askChatGpt({
    required String userMessage,
    List<Map<String, String>> conversationHistory = const [],
    List<Product> catalog = const [],
  }) async {
    final apiKey = await getApiKey();

    // If no API key configured, use our enhanced dermatological engine
    if (apiKey == null || apiKey.isEmpty) {
      return _generateSmartLocalResponse(userMessage, catalog, isFallback: false);
    }

    try {
      // Build catalog context for AI
      final catalogSummary = catalog.take(15).map((p) {
        return '- ${p.name} (${p.brand}) [${p.category}] - ${p.price.toStringAsFixed(0)} DA. Ingredients: ${p.ingredients.join(", ")}';
      }).join('\n');

      final systemPrompt = '''
You are GlowCare AI, an elite clinical skincare consultant, cosmetologist, and personal beauty advisor for the GlowCare store in Algeria.
Your goal is to provide warm, scientific, practical, and highly empathetic skincare consultations.

Language Capabilities:
- Fluently reply in whatever language the user talks: Arabic / Algerian Darija (لهجة جزائرية دارجة), French, or English.
- If the user writes in Algerian Darija (e.g., "عندي حب الشباب", "واش تنصحني", "شحال التوصيل", "حبيت كريم تفتيح", "واش ندير للبشرة الدهنية"), answer in warm, friendly, natural Algerian Arabic / French mix that resonates with them.

Dermatological Expertise:
1. Always structure routines clearly into:
   - Morning (AM): Gentle Cleanse -> Hydrating Active/Antioxidant -> Barrier Moisturizer -> Mandatory Broad-Spectrum SPF 50+.
   - Night (PM): Double Cleanse -> Treatment Active (Retinol, BHA, etc.) -> Barrier Repair Cream with Ceramides.
2. Ingredient Clash Rules:
   - NEVER combine Retinol with Vitamin C at the same time (use Vit C AM, Retinol PM).
   - NEVER combine Retinol with Salicylic Acid (BHA) or Glycolic Acid (AHA) simultaneously.
   - Niacinamide and Hyaluronic Acid are universally compatible and soothe barrier irritation.
3. GlowCare Store & Delivery Info:
   - Delivery to all 58 Wilayas of Algeria.
   - Cash on Delivery (Paiement à la livraison). Standard fee is 500 DA.
   - Mention relevant products from our store catalog below with their exact prices in Algerian Dinars (DA) when appropriate!

Available Store Inventory:
$catalogSummary

Format your response cleanly with emojis, bullet points, and easy-to-read sections.
''';

      final messages = <Map<String, String>>[
        {'role': 'system', 'content': systemPrompt},
        ...conversationHistory.take(8),
        {'role': 'user', 'content': userMessage},
      ];

      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 900,
        }),
      ).timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        final content = decoded['choices']?[0]?['message']?['content'] as String?;
        if (content != null && content.trim().isNotEmpty) {
          return content.trim();
        }
      }

      // Handle specific API errors
      if (response.statusCode == 401) {
        final fallback = _generateSmartLocalResponse(userMessage, catalog, isFallback: true);
        return '⚠️ **OpenAI API Key Invalid or Expired.**\n*(Tap the ⚙️ settings icon to update your key)*\n\n---\n$fallback';
      }

      if (response.statusCode == 429) {
        final fallback = _generateSmartLocalResponse(userMessage, catalog, isFallback: true);
        return '⚠️ **OpenAI Quota Limit Exceeded (Rate limit / No credits).**\n\n---\n$fallback';
      }

      // Other HTTP failure
      final fallback = _generateSmartLocalResponse(userMessage, catalog, isFallback: true);
      return '⚠️ **Could not connect to ChatGPT API (Status ${response.statusCode}).**\n\n---\n$fallback';
    } catch (e) {
      debugPrint('AI Service error: $e');
      final fallback = _generateSmartLocalResponse(userMessage, catalog, isFallback: true);
      return '⚠️ **Connection Error:** $e\n\n---\n$fallback';
    }
  }

  /// Deep analysis for AI Skin Advisor Quiz results using ChatGPT
  Future<String> analyzeSkinProfileWithGpt({
    required String skinType,
    required String primaryConcern,
    required String environment,
    required List<Product> catalog,
  }) async {
    final prompt = '''
Please provide a comprehensive dermatological consultation report for a patient with:
- Skin Type: $skinType
- Primary Skin Concern: $primaryConcern
- Daily Environment & Climate: $environment

Provide:
1. Scientific diagnosis of what is happening in the epidermis/barrier.
2. Complete AM and PM skincare protocol step-by-step.
3. Active ingredients to prioritize and active ingredients to strictly avoid.
4. Specific lifestyle, hydration, and sun-protection guidance tailored to Algeria's climate.
''';

    return askChatGpt(
      userMessage: prompt,
      catalog: catalog,
    );
  }

  /// High-quality local expert response when ChatGPT key is not set or network fails
  String _generateSmartLocalResponse(String query, List<Product> catalog, {required bool isFallback}) {
    final lower = query.toLowerCase();
    final headerNotice = isFallback
        ? ''
        : '💡 *(Running in GlowCare Smart Mode. Tap ⚙️ to connect your ChatGPT API Key for live AI)*\n\n';

    // 1. Ingredients Clashing / Retinol + Vitamin C / Salicylic
    if (lower.contains('retinol') && (lower.contains('vitamin c') || lower.contains('vit c'))) {
      return '$headerNotice'
          '⚠️ **Do NOT mix Retinol and Vitamin C at the same time.**\n\n'
          '**Dermatological Explanation:**\n'
          '• Vitamin C (L-Ascorbic Acid) operates at a low acidic pH (3.0 - 3.5), whereas Retinol requires a neutral pH (~5.5 - 6.0). Layering them causes severe skin barrier breakdown, redness, and renders Vitamin C inactive.\n\n'
          '**Correct Routine:**\n'
          '☀️ **Morning (AM):** Vitamin C 15% Serum + Moisturizer + Sunscreen SPF 50+ (neutralizes UV free radicals).\n'
          '🌙 **Night (PM):** Gentle Cleanser + Retinol (2-3 nights per week) + Ceramide Barrier Repair Cream.';
    }

    if (lower.contains('retinol') && (lower.contains('salicylic') || lower.contains('bha') || lower.contains('aha') || lower.contains('glycolic'))) {
      return '$headerNotice'
          '⚠️ **Caution: Retinol + Direct Chemical Exfoliants (Salicylic/Glycolic).**\n\n'
          'Using Retinol and BHA/AHA together strips the stratum corneum lipids and causes severe peeling.\n\n'
          '**Skin Cycling Recommendation:**\n'
          '• **Night 1 (Exfoliate):** Salicylic Acid (BHA 2%)\n'
          '• **Night 2 (Retinoid):** Pure Retinol serum\n'
          '• **Nights 3 & 4 (Recovery):** Barrier repair with Ceramides, Hyaluronic Acid & Panthenol.';
    }

    // 2. Acne & Oily Skin / حب الشباب
    if (lower.contains('acne') || lower.contains('oily') || lower.contains('pimple') || lower.contains('حب الشباب') || lower.contains('دهنية') || lower.contains('مسام') || lower.contains('pores')) {
      return '$headerNotice'
          '✨ **Dermatologist Protocol for Acne & Oily Skin (بشرة دهنية مع حب الشباب):**\n\n'
          '1. **Cleansing:** Effaclar Purifying Foaming Gel with Zinc to wash excess sebum without over-drying.\n'
          '2. **Treatment Active:** **Salicylic Acid (BHA 2%)** to dissolve sebum plugs inside pores.\n'
          '3. **Sebum & Pore Control:** **Niacinamide 10% + Zinc 1%** to calm inflammation and shrink enlarged pores.\n'
          '4. **Targeted Spot Cream:** Effaclar Duo+ on active blemishes to prevent post-acne marks.\n'
          '5. **Sunscreen:** Mandatory oil-free / dry-touch fluid SPF 50+ to prevent UV acne darkening.\n\n'
          '💡 *Tip: Avoid heavy oils and comedogenic creams on the T-zone.*';
    }

    // 3. Dry Skin / Barrier Repair / جفاف
    if (lower.contains('dry') || lower.contains('barrier') || lower.contains('dehydrat') || lower.contains('جفاف') || lower.contains('تقشير') || lower.contains('قشور') || lower.contains('rough')) {
      return '$headerNotice'
          '💧 **Skin Barrier Restoration Protocol for Dry Skin (علاج جفاف وتلف الحاجز الواقي):**\n\n'
          '1. **Hydration Phase:** Apply **Hyaluronic Acid 2%** strictly on damp skin to pull water into epidermal cells.\n'
          '2. **Lipid Replenishment:** Use **CeraVe Moisturizing Cream** packed with 3 essential ceramides (1, 3, 6-II).\n'
          '3. **Cleansing Habit:** Switch to a non-foaming hydrating lotion; avoid hot water when washing your face.\n'
          '4. **Night Seal:** Add 2 drops of 100% Pure Organic Argan Oil or Squalane to lock in hydration overnight.';
    }

    // 4. Dark Spots / Hyperpigmentation / Dullness / تفتيح وبقع
    if (lower.contains('dark spot') || lower.contains('pigment') || lower.contains('dull') || lower.contains('glow') || lower.contains('تفتيح') || lower.contains('بقع') || lower.contains('نضارة') || lower.contains('شاحب') || lower.contains('tache')) {
      return '$headerNotice'
          '🌟 **Clinical Brightening & Dark Spot Protocol (علاج البقع الداكنة وتوحيد لون البشرة):**\n\n'
          '1. **Morning Glow Active:** **Pure Vitamin C 15% Serum** — powerful antioxidant that blocks tyrosinase (the melanin enzyme) to fade existing hyperpigmentation.\n'
          '2. **Melanin Transfer Blocker:** **Niacinamide 10%** to prevent pigment from rising to the surface.\n'
          '3. **Cell Turnover:** Gentle Alpha Hydroxy Acid (AHA) or Retinol at night 2x/week.\n'
          '4. **Essential Defense:** Daily Broad-Spectrum Sunscreen SPF 50+! Without sunscreen, dark spots will darken again within 48 hours of UV exposure.';
    }

    // 5. Sensitive Skin & Redness / حساسية واحمرار
    if (lower.contains('sensitive') || lower.contains('redness') || lower.contains('rosacea') || lower.contains('حساس') || lower.contains('احمرار') || lower.contains('تهيج')) {
      return '$headerNotice'
          '🌿 **Calming Protocol for Sensitive & Reactive Skin (العناية بالبشرة الحساسة):**\n\n'
          '• **Eliminate:** Synthetic perfumes, drying denatured alcohol, and physical abrasive scrubs.\n'
          '• **Hero Soothing Actives:** Centella Asiatica (Cica), Panthenol (Pro-Vitamin B5), and Ceramides.\n'
          '• **Sunscreen Choice:** Prefer 100% Mineral / Physical sunscreen (Zinc Oxide / Titanium Dioxide) which does not sting reactive eyes.';
    }

    // 6. Delivery & Algerian Wilayas / توصيل
    if (lower.contains('delivery') || lower.contains('wilaya') || lower.contains('توصيل') || lower.contains('livraison') || lower.contains('سعر') || lower.contains('دينار') || lower.contains('prix')) {
      return '$headerNotice'
          '🚚 **GlowCare Algeria Delivery & Ordering Details:**\n\n'
          '• **Coverage:** Express delivery across all **58 Wilayas** of Algeria.\n'
          '• **Shipping Fee:** Flat standard rate of **500 DA** (Free delivery on orders over 3,000 DA for loyalty members).\n'
          '• **Payment:** 100% Cash on Delivery (الدفع عند الاستلام - Paiement à la livraison).\n'
          '• **Delivery Time:** 24 - 48 hours to major northern wilayas, 48 - 72 hours to southern wilayas.';
    }

    // 7. General Comprehensive Skincare Consultation
    return '$headerNotice'
        '🌸 **Hello from GlowCare Beauty Lab & Skincare AI!**\n\n'
        'I am your certified cosmetic dermatology companion. To give you the most tailored advice, tell me:\n\n'
        '1. **What is your skin type?** (Oily, Dry, Combination, Sensitive)\n'
        '2. **What is your main concern?** (Acne, Dark spots, Aging lines, Redness, Dullness)\n'
        '3. **Any specific product or ingredient you are curious about?** (Retinol, Vitamin C, Niacinamide, CeraVe, Effaclar)\n\n'
        'You can type in **العربية / الدارجة**, **Français**, or **English**!';
  }
}
