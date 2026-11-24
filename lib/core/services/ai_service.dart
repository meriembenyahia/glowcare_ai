import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/shop/product.dart';
import '../localization/translations.dart';

/// Supported AI providers. OpenAI-compatible providers share the same request
/// shape, Gemini uses its own REST format.
enum AiProvider { openai, gemini, openrouter, groq, custom }

extension AiProviderX on AiProvider {
  String get labelKey {
    switch (this) {
      case AiProvider.openai:
        return 'OpenAI';
      case AiProvider.gemini:
        return 'Google Gemini';
      case AiProvider.openrouter:
        return 'OpenRouter';
      case AiProvider.groq:
        return 'Groq';
      case AiProvider.custom:
        return 'Custom / Proxy';
    }
  }

  String get defaultBaseUrl {
    switch (this) {
      case AiProvider.openai:
        return 'https://api.openai.com/v1';
      case AiProvider.gemini:
        return 'https://generativelanguage.googleapis.com/v1beta';
      case AiProvider.openrouter:
        return 'https://openrouter.ai/api/v1';
      case AiProvider.groq:
        return 'https://api.groq.com/openai/v1';
      case AiProvider.custom:
        return '';
    }
  }

  String get defaultModel {
    switch (this) {
      case AiProvider.openai:
        return 'gpt-4o-mini';
      case AiProvider.gemini:
        return 'gemini-flash-latest';
      case AiProvider.openrouter:
        return 'openai/gpt-4o-mini';
      case AiProvider.groq:
        return 'llama-3.3-70b-versatile';
      case AiProvider.custom:
        return 'gpt-4o-mini';
    }
  }

  List<String> get suggestedModels {
    switch (this) {
      case AiProvider.openai:
        return const ['gpt-4o-mini', 'gpt-4o', 'gpt-4.1-mini'];
      case AiProvider.gemini:
        return const [
          'gemini-flash-latest',
          'gemini-2.5-flash',
          'gemini-2.5-pro',
          'gemini-2.0-flash',
        ];
      case AiProvider.openrouter:
        return const [
          'openai/gpt-4o-mini',
          'google/gemini-2.0-flash-001',
          'anthropic/claude-3.5-sonnet',
          'meta-llama/llama-3.3-70b-instruct:free',
        ];
      case AiProvider.groq:
        return const [
          'llama-3.3-70b-versatile',
          'llama-3.1-8b-instant',
          'mixtral-8x7b-32768',
        ];
      case AiProvider.custom:
        return const [];
    }
  }

  bool get isGemini => this == AiProvider.gemini;
}

class AiConfig {
  final AiProvider provider;
  final String apiKey;
  final String model;
  final String baseUrl;

  const AiConfig({
    this.provider = AiProvider.openai,
    this.apiKey = '',
    this.model = '',
    this.baseUrl = '',
  });

  bool get isConfigured => apiKey.trim().isNotEmpty;

  String get effectiveModel =>
      model.trim().isEmpty ? provider.defaultModel : model.trim();

  String get effectiveBaseUrl {
    final raw = baseUrl.trim().isEmpty ? provider.defaultBaseUrl : baseUrl.trim();
    return raw.replaceAll(RegExp(r'/+$'), '');
  }

  AiConfig copyWith({
    AiProvider? provider,
    String? apiKey,
    String? model,
    String? baseUrl,
  }) {
    return AiConfig(
      provider: provider ?? this.provider,
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      baseUrl: baseUrl ?? this.baseUrl,
    );
  }
}

class AiException implements Exception {
  final int? statusCode;
  final String message;
  final String? code;

  const AiException(this.message, {this.statusCode, this.code});

  @override
  String toString() => message;
}

class AiService {
  static final AiService instance = AiService._internal();
  AiService._internal();

  static const String _keyProvider = 'ai_provider';
  static const String _legacyKey = 'openai_api_key';
  static const String _legacyModel = 'openai_model';
  static const String defaultModel = 'gpt-4o-mini';

  AiConfig _config = const AiConfig();
  bool _loaded = false;

  String _keyFor(AiProvider p) => 'ai_key_${p.name}';
  String _modelFor(AiProvider p) => 'ai_model_${p.name}';
  String _baseUrlFor(AiProvider p) => 'ai_base_url_${p.name}';

  Future<void> init() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();

    final providerName = prefs.getString(_keyProvider);
    final provider = AiProvider.values.firstWhere(
      (p) => p.name == providerName,
      orElse: () => AiProvider.openai,
    );

    var key = prefs.getString(_keyFor(provider)) ?? '';
    var model = prefs.getString(_modelFor(provider)) ?? '';

    // Migrate keys saved by the previous version of the app.
    if (key.isEmpty && prefs.getString(_legacyKey) != null) {
      key = prefs.getString(_legacyKey)!.trim();
      model = model.isEmpty ? (prefs.getString(_legacyModel) ?? '') : model;
    }

    _config = AiConfig(
      provider: provider,
      apiKey: key.trim(),
      model: model.trim(),
      baseUrl: prefs.getString(_baseUrlFor(provider)) ?? '',
    );
    _loaded = true;
  }

  Future<AiConfig> loadProviderConfig(AiProvider provider) async {
    final prefs = await SharedPreferences.getInstance();
    var key = prefs.getString(_keyFor(provider)) ?? '';
    var model = prefs.getString(_modelFor(provider)) ?? '';
    if (provider == AiProvider.openai &&
        key.isEmpty &&
        prefs.getString(_legacyKey) != null) {
      key = prefs.getString(_legacyKey)!.trim();
      model = model.isEmpty ? (prefs.getString(_legacyModel) ?? '') : model;
    }
    return AiConfig(
      provider: provider,
      apiKey: key.trim(),
      model: model.trim(),
      baseUrl: prefs.getString(_baseUrlFor(provider)) ?? '',
    );
  }

  Future<AiConfig> getConfig() async {
    if (!_loaded) await init();
    return _config;
  }

  bool get hasKey => _config.isConfigured;

  Future<void> saveConfig(AiConfig config) async {
    _config = config;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProvider, config.provider.name);
    await prefs.setString(_baseUrlFor(config.provider), config.baseUrl.trim());
    await prefs.setString(_modelFor(config.provider), config.model.trim());

    final key = config.apiKey.trim();
    if (key.isEmpty) {
      await prefs.remove(_keyFor(config.provider));
    } else {
      await prefs.setString(_keyFor(config.provider), key);
    }
  }

  Future<void> clearKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFor(_config.provider));
    await prefs.remove(_legacyKey);
    _config = _config.copyWith(apiKey: '');
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> testConnection(AiConfig config) async {
    final key = config.apiKey.trim();
    if (key.isEmpty) {
      return {'success': false, 'message': 'Missing API key.'};
    }
    if (kIsWeb &&
        config.provider == AiProvider.openai &&
        config.baseUrl.trim().isEmpty) {
      return {
        'success': false,
        'message':
            'OpenAI blocks direct browser requests (CORS). Use Gemini, OpenRouter, or a proxy URL.',
        'code': 'cors',
      };
    }

    try {
      final text = await _complete(
        config,
        systemPrompt: 'You are a connectivity test. Reply with OK only.',
        userMessage: 'Reply with OK',
        history: const [],
        maxTokens: 8,
      );
      if (text.trim().isEmpty) {
        return {'success': false, 'message': 'Empty response from provider.'};
      }
      return {'success': true, 'message': text.trim()};
    } on AiException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'code': e.code,
        'status': e.statusCode,
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<String> askAi({
    required String userMessage,
    List<Map<String, String>> conversationHistory = const [],
    List<Product> catalog = const [],
    String? localeCode,
  }) async {
    final config = await getConfig();
    final lang = _resolveLang(userMessage, localeCode);
    final tr = AppTranslations(lang);

    if (!config.isConfigured) {
      return _localAnswer(
        userMessage,
        catalog,
        lang: lang,
        showModeNotice: true,
      );
    }

    if (kIsWeb &&
        config.provider == AiProvider.openai &&
        config.baseUrl.trim().isEmpty) {
      final fallback = _localAnswer(
        userMessage,
        catalog,
        lang: lang,
        showModeNotice: false,
      );
      return '⚠️ **${tr.t('OpenAI blocks direct browser requests. Use Google Gemini, OpenRouter, or a proxy URL in settings.')}**\n\n---\n$fallback';
    }

    final systemPrompt = _systemPrompt(catalog, lang);

    try {
      final result = await _complete(
        config,
        systemPrompt: systemPrompt,
        userMessage: userMessage,
        history: conversationHistory,
        maxTokens: 900,
      );
      if (result.trim().isNotEmpty) return result.trim();
      throw const AiException('The provider returned an empty response.');
    } on AiException catch (e) {
      final fallback = _localAnswer(
        userMessage,
        catalog,
        lang: lang,
        showModeNotice: false,
      );
      final String warning;
      if (e.statusCode == 401 || e.statusCode == 403) {
        warning = tr.pick(
          en: '**${config.provider.labelKey} API key is invalid or expired.**\n*(Tap ⚙️ to update it)*',
          ar: '**مفتاح ${config.provider.labelKey} غير صالح أو منتهي الصلاحية.**\n*(اضغطي ⚙️ لتحديثه)*',
          fr: '**La clé API ${config.provider.labelKey} est invalide ou expirée.**\n*(Touchez ⚙️ pour la mettre à jour)*',
        );
      } else if (e.statusCode == 429) {
        warning = tr.pick(
          en: '**Quota limit exceeded (rate limit or no credits).**',
          ar: '**تم تجاوز حد الاستخدام (حد المعدل أو لا توجد أرصدة).**',
          fr: '**Quota dépassé (limite de débit ou aucun crédit).**',
        );
      } else if (e.code == 'cors') {
        warning = tr.pick(
          en: '**The browser blocked this request (CORS).** Use Gemini or a proxy.',
          ar: '**المتصفح منع هذا الطلب (CORS).** استخدمي Gemini أو وسيطًا.',
          fr: '**Le navigateur a bloqué la requête (CORS).** Utilisez Gemini ou un proxy.',
        );
      } else {
        warning = tr.pick(
          en: '**Could not reach the AI provider.** ${e.message}',
          ar: '**تعذر الوصول إلى مزود الذكاء الاصطناعي.** ${e.message}',
          fr: '**Impossible de joindre le fournisseur IA.** ${e.message}',
        );
      }
      return '⚠️ $warning\n\n---\n$fallback';
    } catch (e) {
      final fallback = _localAnswer(
        userMessage,
        catalog,
        lang: lang,
        showModeNotice: false,
      );
      return '⚠️ **${tr.t('Connection Error: {error}')}**\n\n---\n$fallback'
          .replaceAll('{error}', e.toString());
    }
  }

  /// Backwards-compatible alias used by older screens.
  Future<String> askChatGpt({
    required String userMessage,
    List<Map<String, String>> conversationHistory = const [],
    List<Product> catalog = const [],
    String? localeCode,
  }) {
    return askAi(
      userMessage: userMessage,
      conversationHistory: conversationHistory,
      catalog: catalog,
      localeCode: localeCode,
    );
  }

  Future<String> analyzeSkinProfileWithGpt({
    required String skinType,
    required String primaryConcern,
    required String environment,
    required List<Product> catalog,
    String? localeCode,
  }) async {
    final lang = localeCode ?? 'en';
    final replyLanguage = lang == 'ar'
        ? 'Arabic (Modern Standard Arabic, warm and practical)'
        : lang == 'fr'
            ? 'French'
            : 'English';
    final prompt = '''
Please provide a comprehensive dermatological consultation report for a patient with:
- Skin Type: $skinType
- Primary Skin Concern: $primaryConcern
- Daily Environment & Climate: $environment

Write the entire report in $replyLanguage.
Provide:
1. Scientific diagnosis of what is happening in the epidermis/barrier.
2. Complete AM and PM skincare protocol step-by-step.
3. Active ingredients to prioritize and active ingredients to strictly avoid.
4. Specific lifestyle, hydration, and sun-protection guidance tailored to Algeria's climate.
Keep the formatting clean with short sections.
''';

    return askAi(
      userMessage: prompt,
      catalog: catalog,
      localeCode: lang,
    );
  }

  // ---------------------------------------------------------------------------
  // Provider calls
  // ---------------------------------------------------------------------------

  Future<String> _complete(
    AiConfig config, {
    required String systemPrompt,
    required String userMessage,
    required List<Map<String, String>> history,
    required int maxTokens,
  }) {
    if (config.provider.isGemini) {
      return _geminiComplete(
        config,
        systemPrompt: systemPrompt,
        userMessage: userMessage,
        history: history,
        maxTokens: maxTokens,
      );
    }
    return _openAiCompatibleComplete(
      config,
      systemPrompt: systemPrompt,
      userMessage: userMessage,
      history: history,
      maxTokens: maxTokens,
    );
  }

  Future<String> _openAiCompatibleComplete(
    AiConfig config, {
    required String systemPrompt,
    required String userMessage,
    required List<Map<String, String>> history,
    required int maxTokens,
  }) async {
    final url = Uri.parse('${config.effectiveBaseUrl}/chat/completions');
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
      ...history.take(8),
      {'role': 'user', 'content': userMessage},
    ];

    final headers = <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
      'Authorization': 'Bearer ${config.apiKey.trim()}',
    };
    if (config.provider == AiProvider.openrouter) {
      headers['HTTP-Referer'] = 'https://glowcare.app';
      headers['X-Title'] = 'GlowCare AI';
    }

    final response = await http
        .post(
          url,
          headers: headers,
          body: jsonEncode({
            'model': config.effectiveModel,
            'messages': messages,
            'temperature': 0.7,
            'max_tokens': maxTokens,
          }),
        )
        .timeout(const Duration(seconds: 35));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final choices = decoded['choices'];
      if (choices is List && choices.isNotEmpty) {
        final choice = choices.first;
        final content = choice?['message']?['content'] ?? choice?['text'];
        if (content is String && content.trim().isNotEmpty) {
          return content.trim();
        }
      }
      throw const AiException('The provider returned an unreadable response.');
    }

    throw AiException(
      _extractError(response),
      statusCode: response.statusCode,
      code: response.statusCode == 401 || response.statusCode == 403
          ? 'auth'
          : response.statusCode == 429
              ? 'rate'
              : null,
    );
  }

  Future<String> _geminiComplete(
    AiConfig config, {
    required String systemPrompt,
    required String userMessage,
    required List<Map<String, String>> history,
    required int maxTokens,
  }) async {
    final model = config.effectiveModel;
    final url = Uri.parse(
      '${config.effectiveBaseUrl}/models/$model:generateContent?key=${Uri.encodeQueryComponent(config.apiKey.trim())}',
    );

    final contents = <Map<String, dynamic>>[];
    for (final m in history.take(8)) {
      contents.add({
        'role': m['role'] == 'assistant' ? 'model' : 'user',
        'parts': [
          {'text': m['content'] ?? ''}
        ],
      });
    }
    contents.add({
      'role': 'user',
      'parts': [
        {'text': userMessage}
      ],
    });

    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json; charset=utf-8'},
          body: jsonEncode({
            'systemInstruction': {
              'parts': [
                {'text': systemPrompt}
              ]
            },
            'contents': contents,
            'generationConfig': {
              'temperature': 0.7,
              'maxOutputTokens': maxTokens,
            },
          }),
        )
        .timeout(const Duration(seconds: 35));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final candidates = decoded['candidates'];
      if (candidates is List && candidates.isNotEmpty) {
        final parts = candidates.first?['content']?['parts'];
        if (parts is List) {
          final text = parts
              .map((p) => p is Map ? (p['text'] ?? '') : '')
              .where((t) => t.toString().trim().isNotEmpty)
              .join('\n')
              .trim();
          if (text.isNotEmpty) return text;
        }
        final finish = candidates.first?['finishReason'];
        if (finish == 'SAFETY') {
          throw const AiException(
            'The AI provider blocked this answer for safety reasons.',
            code: 'safety',
          );
        }
      }
      throw const AiException('Gemini returned an unreadable response.');
    }

    throw AiException(
      _extractError(response),
      statusCode: response.statusCode,
      code: response.statusCode == 401 || response.statusCode == 403
          ? 'auth'
          : response.statusCode == 429
              ? 'rate'
              : null,
    );
  }

  String _extractError(http.Response response) {
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final err = decoded['error'];
      if (err is Map && err['message'] != null) {
        return err['message'].toString();
      }
      if (err is String) return err;
    } catch (_) {}
    return 'HTTP ${response.statusCode}';
  }

  String _systemPrompt(List<Product> catalog, String lang) {
    final catalogSummary = catalog.take(15).map((p) {
      return '- ${p.name} (${p.brand}) [${p.category}] - ${p.price.toStringAsFixed(0)} DA. Ingredients: ${p.ingredients.join(", ")}';
    }).join('\n');

    final replyRule = switch (lang) {
      'ar' =>
        'Always answer in Arabic. If the user writes in Algerian Darija, answer in warm, natural Algerian Arabic/Darija.',
      'fr' => 'Always answer in French.',
      _ => 'Always answer in English.',
    };

    return '''
You are GlowCare AI, an elite clinical skincare consultant, cosmetologist, and personal beauty advisor for the GlowCare store in Algeria.
Your goal is to provide warm, scientific, practical, and highly empathetic skincare consultations.
$replyRule

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
   - Cash on Delivery. Standard fee is 500 DA.
   - Mention relevant products from our store catalog below with their exact prices in Algerian Dinars (DA) when appropriate!

Available Store Inventory:
$catalogSummary

Format your response cleanly with emojis, bullet points, and easy-to-read sections. Use short paragraphs.
''';
  }

  // ---------------------------------------------------------------------------
  // Offline smart engine (no API key required)
  // ---------------------------------------------------------------------------

  String _resolveLang(String query, String? preferred) {
    if (RegExp(r'[\u0600-\u06FF]').hasMatch(query)) return 'ar';

    final lower = query.toLowerCase();
    const frenchHints = [
      'bonjour',
      'merci',
      'peau',
      'crème',
      'creme',
      'sérum',
      'serum',
      'tache',
      'acné',
      'acne',
      'livraison',
      'conseil',
      'puis-je',
      'comment',
      'quel',
      'quelle',
      'routine',
    ];
    if (frenchHints.any(lower.contains)) return 'fr';

    if (preferred == 'ar' || preferred == 'fr' || preferred == 'en') {
      return preferred!;
    }
    return 'en';
  }

  String _localAnswer(
    String query,
    List<Product> catalog, {
    required String lang,
    required bool showModeNotice,
  }) {
    final tr = AppTranslations(lang);
    final lower = query.toLowerCase();
    final notice = showModeNotice
        ? tr.pick(
            en: '💡 *(Running in GlowCare Smart Local Mode. Tap ⚙️ to connect your AI key for live answers.)*\n\n',
            ar: '💡 *(يعمل بالوضع الذكي المحلي. اضغطي ⚙️ لربط مفتاح الذكاء الاصطناعي للحصول على إجابات مباشرة.)*\n\n',
            fr: '💡 *(Mode local intelligent GlowCare. Touchez ⚙️ pour connecter une clé IA.)*\n\n',
          )
        : '';

    String body;

    // 1. Retinol + Vitamin C
    if (lower.contains('retinol') &&
        (lower.contains('vitamin c') ||
            lower.contains('vit c') ||
            lower.contains('فيتامين c') ||
            lower.contains('فيتامين سي'))) {
      body = tr.pick(
        en: '⚠️ **Do NOT mix Retinol and Vitamin C at the same time.**\n\n'
            '**Why:** Vitamin C (L-Ascorbic Acid) works at low pH (3.0–3.5), while Retinol needs a nearly neutral pH (~5.5–6.0). Layering them can break down the skin barrier, cause redness, and deactivate the Vitamin C.\n\n'
            '**Correct routine:**\n'
            '☀️ **AM:** Vitamin C 15% serum + moisturizer + SPF 50+.\n'
            '🌙 **PM:** Gentle cleanser + Retinol (2–3 nights/week) + ceramide repair cream.',
        ar: '⚠️ **لا تخلطي الريتينول مع فيتامين C في نفس الوقت.**\n\n'
            '**السبب:** فيتامين C (حمض الأسكوربيك) يعمل عند حموضة منخفضة (pH 3.0–3.5)، بينما الريتينول يحتاج pH شبه متعادل (~5.5–6.0). طبقهما معًا قد يضرّ بحاجز البشرة ويسبب الاحمرار ويُبطل مفعول فيتامين C.\n\n'
            '**الروتين الصحيح:**\n'
            '☀️ **صباحًا:** سيروم فيتامين C 15% + مرطب + واقي شمس SPF 50+.\n'
            '🌙 **مساءً:** غسول لطيف + ريتينول (2–3 ليالٍ أسبوعيًا) + كريم سيراميد لإصلاح الحاجز.',
        fr: '⚠️ **Ne mélangez pas rétinol et vitamine C au même moment.**\n\n'
            '**Pourquoi :** la vitamine C (acide L-ascorbique) agit à pH bas (3,0–3,5), alors que le rétinol nécessite un pH quasi neutre (~5,5–6,0). Les superposer peut abîmer la barrière cutanée, provoquer des rougeurs et désactiver la vitamine C.\n\n'
            '**Routine correcte :**\n'
            '☀️ **Matin :** sérum vitamine C 15 % + hydratant + SPF 50+.\n'
            '🌙 **Soir :** nettoyant doux + rétinol (2–3 soirs/semaine) + crème céramides.',
      );
      return notice +
          body +
          _suggestLine(lang, catalog, ['vitamin c', 'glow', 'niacinamide']);
    }

    // 2. Retinol + BHA/AHA
    if (lower.contains('retinol') &&
        (lower.contains('salicylic') ||
            lower.contains('bha') ||
            lower.contains('aha') ||
            lower.contains('glycolic') ||
            lower.contains('ساليسيليك'))) {
      body = tr.pick(
        en: '⚠️ **Caution: Retinol + strong exfoliating acids (BHA/AHA).**\n\n'
            'Using them together strips the stratum corneum lipids and can cause severe peeling.\n\n'
            '**Skin cycling recommendation:**\n'
            '• **Night 1:** Salicylic acid (BHA 2%)\n'
            '• **Night 2:** Retinol serum\n'
            '• **Nights 3 & 4:** Recovery with ceramides, hyaluronic acid and panthenol.',
        ar: '⚠️ **تحذير: الريتينول مع أحماض التقشير القوية (BHA/AHA).**\n\n'
            'استخدامهما معًا يزيل دهون الطبقة القرنية وقد يسبب تقشرًا شديدًا.\n\n'
            '**توصية تدوير العناية:**\n'
            '• **الليلة 1:** حمض الساليسيليك (BHA 2%).\n'
            '• **الليلة 2:** سيروم ريتينول.\n'
            '• **الليلتان 3 و4:** استشفاء بالسيراميدات والهيالورونيك والبانثينول.',
        fr: '⚠️ **Attention : rétinol + acides exfoliants forts (BHA/AHA).**\n\n'
            'Les utiliser ensemble retire les lipides de la couche cornée et peut causer un desquamation sévère.\n\n'
            '**Cyclage recommandé :**\n'
            '• **Nuit 1 :** acide salicylique (BHA 2 %).\n'
            '• **Nuit 2 :** sérum rétinol.\n'
            '• **Nuits 3 & 4 :** récupération avec céramides, acide hyaluronique et panthénol.',
      );
      return notice +
          body +
          _suggestLine(lang, catalog, ['salicylic', 'bha', 'cerave']);
    }

    // 3. Acne & oily skin
    if (lower.contains('acne') ||
        lower.contains('oily') ||
        lower.contains('pimple') ||
        lower.contains('حب الشباب') ||
        lower.contains('دهنية') ||
        lower.contains('مسام') ||
        lower.contains('pores')) {
      body = tr.pick(
        en: '✨ **Dermatologist protocol for acne & oily skin:**\n\n'
            '1. **Cleansing:** gentle foaming purifying cleanser with zinc; do not over-wash.\n'
            '2. **Treatment:** **Salicylic acid (BHA 2%)** to dissolve sebum plugs inside pores.\n'
            '3. **Sebum control:** **Niacinamide 10% + Zinc 1%** to calm inflammation and refine pores.\n'
            '4. **Targeted care:** a dual-action acne cream on active blemishes to prevent marks.\n'
            '5. **Sunscreen:** oil-free SPF 50+ every morning to prevent post-acne darkening.\n\n'
            '💡 *Avoid heavy oils and comedogenic creams on the T-zone.*',
        ar: '✨ **بروتوكول طبي لحب الشباب والبشرة الدهنية:**\n\n'
            '1. **التنظيف:** غسول رغوي لطيف بالزنك، دون الإفراط في الغسل.\n'
            '2. **العلاج:** **حمض الساليسيليك (BHA 2%)** لإذابة الدهون المتراكمة داخل المسام.\n'
            '3. **التحكم بالدهون:** **نياسيناميد 10% + زنك 1%** لتهدئة الالتهاب وتضييق المسام.\n'
            '4. **عناية موضعية:** كريم حب شباب ثنائي المفعول على البثور لمنع الآثار.\n'
            '5. **واقي الشمس:** SPF 50+ خالٍ من الزيوت كل صباح لمنع تصبغ آثار الحبوب.\n\n'
            '💡 *تجنبي الزيوت الثقيلة والكريمات المسددة للمسام في منطقة T.*',
        fr: '✨ **Protocole dermatologique acné & peau grasse :**\n\n'
            '1. **Nettoyage :** nettoyant moussant doux au zinc, sans sur-nettoyer.\n'
            '2. **Traitement :** **acide salicylique (BHA 2 %)** pour dissoudre le sébum dans les pores.\n'
            '3. **Contrôle du sébum :** **niacinamide 10 % + zinc 1 %** pour calmer l’inflammation.\n'
            '4. **Soin ciblé :** crème anti-acné double action sur les boutons.\n'
            '5. **Écran solaire :** SPF 50+ sans huile chaque matin.\n\n'
            '💡 *Évitez les huiles lourdes et crèmes comédogènes sur la zone T.*',
      );
      return notice +
          body +
          _suggestLine(
              lang, catalog, ['effaclar', 'salicylic', 'niacinamide', 'zinc']);
    }

    // 4. Dry skin / barrier
    if (lower.contains('dry') ||
        lower.contains('barrier') ||
        lower.contains('dehydrat') ||
        lower.contains('جفاف') ||
        lower.contains('تقشير') ||
        lower.contains('قشور') ||
        lower.contains('rough')) {
      body = tr.pick(
        en: '💧 **Barrier restoration protocol for dry skin:**\n\n'
            '1. **Hydration:** apply **hyaluronic acid 2%** on damp skin to pull water into the epidermis.\n'
            '2. **Lipids:** use a moisturizing cream with **ceramides 1, 3, 6-II**.\n'
            '3. **Cleansing:** switch to a non-foaming hydrating lotion; avoid hot water.\n'
            '4. **Night seal:** add 2 drops of pure argan oil or squalane to lock in moisture.\n\n'
            '💡 *Apply moisturizer within 60 seconds of cleansing.*',
        ar: '💧 **بروتوكول إصلاح حاجز البشرة الجافة:**\n\n'
            '1. **الترطيب:** ضعي **حمض الهيالورونيك 2%** على بشرة رطبة لسحب الماء إلى البشرة.\n'
            '2. **الدهون:** استخدمي كريمًا مرطبًا يحتوي **سيراميدات 1، 3، 6-II**.\n'
            '3. **التنظيف:** انتقلي إلى لوشن مرطب غير رغوي، وتجنبي الماء الساخن.\n'
            '4. **الختم الليلي:** أضيفي قطرتين من زيت الأرغان النقي أو السكوالان لحبس الرطوبة.\n\n'
            '💡 *ضعي المرطب خلال 60 ثانية بعد التنظيف.*',
        fr: '💧 **Protocole de restauration de la barrière pour peau sèche :**\n\n'
            '1. **Hydratation :** appliquez **l’acide hyaluronique 2 %** sur peau humide.\n'
            '2. **Lipides :** crème avec **céramides 1, 3, 6-II**.\n'
            '3. **Nettoyage :** lotion hydratante sans mousse, évitez l’eau chaude.\n'
            '4. **Scellage nocturne :** 2 gouttes d’huile d’argan pure ou de squalane.\n\n'
            '💡 *Appliquez l’hydratant dans les 60 secondes après le nettoyage.*',
      );
      return notice +
          body +
          _suggestLine(
              lang, catalog, ['cerave', 'hyaluronic', 'moisturizing', 'cream']);
    }

    // 5. Dark spots / glow
    if (lower.contains('dark spot') ||
        lower.contains('pigment') ||
        lower.contains('dull') ||
        lower.contains('glow') ||
        lower.contains('تفتيح') ||
        lower.contains('بقع') ||
        lower.contains('نضارة') ||
        lower.contains('شاحب') ||
        lower.contains('tache')) {
      body = tr.pick(
        en: '🌟 **Brightening & dark spot protocol:**\n\n'
            '1. **Morning:** **pure vitamin C 15%** to block tyrosinase and fade existing pigment.\n'
            '2. **Melanin transfer:** **niacinamide 10%** to stop pigment from rising to the surface.\n'
            '3. **Cell turnover:** gentle AHA or retinol at night, 2×/week.\n'
            '4. **Defense:** broad-spectrum SPF 50+ daily — without it, spots darken again within 48 hours of UV exposure.\n\n'
            '💡 *Consistency for 8–12 weeks is key.*',
        ar: '🌟 **بروتوكول التفتيح والبقع الداكنة:**\n\n'
            '1. **صباحًا:** **فيتامين C النقي 15%** لعرقلة التيروزيناز وتفتيح التصبغ الموجود.\n'
            '2. **نقل الميلانين:** **نياسيناميد 10%** لمنع وصول الصبغة إلى السطح.\n'
            '3. **تجدد الخلايا:** AHA لطيف أو ريتينول ليلًا، مرتين أسبوعيًا.\n'
            '4. **الحماية:** واقي شمس واسع الطيف SPF 50+ يوميًا — بدونه تعود البقع للغُمق خلال 48 ساعة من التعرض للشمس.\n\n'
            '💡 *الانتظام لمدة 8–12 أسبوعًا هو المفتاح.*',
        fr: '🌟 **Protocole éclat & taches brunes :**\n\n'
            '1. **Matin :** **vitamine C pure 15 %** pour bloquer la tyrosinase.\n'
            '2. **Transfert de mélanine :** **niacinamide 10 %** pour empêcher la pigmentation de remonter.\n'
            '3. **Renouvellement :** AHA doux ou rétinol le soir, 2×/semaine.\n'
            '4. **Défense :** SPF 50+ large spectre chaque jour — sans lui, les taches foncent à nouveau.\n\n'
            '💡 *La régularité pendant 8 à 12 semaines est essentielle.*',
      );
      return notice +
          body +
          _suggestLine(lang, catalog,
              ['vitamin c', 'glow', 'niacinamide', 'ordinary']);
    }

    // 6. Sensitive skin
    if (lower.contains('sensitive') ||
        lower.contains('redness') ||
        lower.contains('rosacea') ||
        lower.contains('حساس') ||
        lower.contains('احمرار') ||
        lower.contains('تهيج')) {
      body = tr.pick(
        en: '🌿 **Calming protocol for sensitive & reactive skin:**\n\n'
            '• **Eliminate:** synthetic perfumes, drying denatured alcohol and abrasive scrubs.\n'
            '• **Hero actives:** centella asiatica (cica), panthenol (pro-vitamin B5) and ceramides.\n'
            '• **Sunscreen:** prefer a 100% mineral formula (zinc oxide / titanium dioxide).\n\n'
            '💡 *Patch-test new products on the jawline for 48 hours.*',
        ar: '🌿 **بروتوكول تهدئة البشرة الحساسة والمتفاعلة:**\n\n'
            '• **تخلصي من:** العطور الصناعية، الكحول المجفف، والمقشرات الخشنة.\n'
            '• **مكونات أساسية:** سنتيلا آسياتيكا، بانثينول (بروفيتامين B5)، وسيراميدات.\n'
            '• **واقي الشمس:** يفضل تركيبة معدنية 100% (أكسيد الزنك / ثاني أكسيد التيتانيوم).\n\n'
            '💡 *جربي أي منتج جديد على خط الفك لمدة 48 ساعة.*',
        fr: '🌿 **Protocole apaisant pour peau sensible :**\n\n'
            '• **Éliminez :** parfums synthétiques, alcool dénaturé et gommages abrasifs.\n'
            '• **Actifs clés :** centella asiatica, panthénol (pro-vitamine B5) et céramides.\n'
            '• **Écran solaire :** préférez une formule 100 % minérale.\n\n'
            '💡 *Testez les nouveaux produits sur la mâchoire pendant 48 h.*',
      );
      return notice +
          body +
          _suggestLine(lang, catalog, ['cerave', 'hyaluronic', 'cleanser']);
    }

    // 7. Delivery & prices
    if (lower.contains('delivery') ||
        lower.contains('wilaya') ||
        lower.contains('توصيل') ||
        lower.contains('livraison') ||
        lower.contains('سعر') ||
        lower.contains('دينار') ||
        lower.contains('prix')) {
      body = tr.pick(
        en: '🚚 **GlowCare Algeria delivery & ordering:**\n\n'
            '• **Coverage:** express delivery across all **58 Wilayas**.\n'
            '• **Shipping fee:** flat **500 DA** (free over 3,000 DA for loyalty members).\n'
            '• **Payment:** 100% cash on delivery.\n'
            '• **Delivery time:** 24–48 h to major northern wilayas, 48–72 h to the south.',
        ar: '🚚 **التوصيل والطلب في GlowCare الجزائر:**\n\n'
            '• **التغطية:** توصيل سريع إلى **58 ولاية** كاملة.\n'
            '• **سعر التوصيل:** **500 دج** ثابت (مجاني للطلبات فوق 3000 دج لأعضاء الولاء).\n'
            '• **الدفع:** 100% عند الاستلام.\n'
            '• **مدة التوصيل:** 24–48 ساعة للولايات الشمالية الكبرى، و48–72 ساعة للجنوب.',
        fr: '🚚 **Livraison & commande GlowCare Algérie :**\n\n'
            '• **Couverture :** livraison express dans les **58 wilayas**.\n'
            '• **Frais :** **500 DA** (offerts dès 3 000 DA pour les membres fidélité).\n'
            '• **Paiement :** 100 % à la livraison.\n'
            '• **Délai :** 24–48 h au nord, 48–72 h au sud.',
      );
      return notice + body;
    }

    // 8. General
    body = tr.pick(
      en: '🌸 **Hello from GlowCare Beauty Lab & Skincare AI!**\n\n'
          'I am your cosmetic dermatology companion. To give you the most tailored advice, tell me:\n\n'
          '1. **What is your skin type?** (Oily, Dry, Combination, Sensitive)\n'
          '2. **What is your main concern?** (Acne, Dark spots, Aging lines, Redness, Dullness)\n'
          '3. **Any product or ingredient you are curious about?** (Retinol, Vitamin C, Niacinamide, CeraVe, Effaclar)\n\n'
          'You can type in **العربية / الدارجة**, **Français**, or **English**!',
      ar: '🌸 **مرحبًا من مختبر جمال GlowCare والذكاء الاصطناعي للعناية بالبشرة!**\n\n'
          'أنا رفيقك في العناية الجلدية التجميلية. لأقدم لك أنسب نصيحة، أخبريني:\n\n'
          '1. **ما نوع بشرتك؟** (دهنية، جافة، مختلطة، حساسة)\n'
          '2. **ما مشكلتك الأساسية؟** (حب الشباب، بقع داكنة، خطوط شيخوخة، احمرار، بهتان)\n'
          '3. **هل هناك منتج أو مكوّن تريدين معرفة المزيد عنه؟** (ريتينول، فيتامين C، نياسيناميد، CeraVe، Effaclar)\n\n'
          'يمكنك الكتابة بـ **العربية / الدارجة**، **Français** أو **English**!',
      fr: '🌸 **Bonjour du Labo Beauté GlowCare !**\n\n'
          'Je suis votre conseiller en dermo-cosmétique. Pour un conseil sur-mesure, dites-moi :\n\n'
          '1. **Quel est votre type de peau ?** (Grasse, sèche, mixte, sensible)\n'
          '2. **Votre préoccupation principale ?** (Acné, taches, rides, rougeurs, teint terne)\n'
          '3. **Un produit ou actif en particulier ?** (Rétinol, vitamine C, niacinamide, CeraVe, Effaclar)\n\n'
          'Vous pouvez écrire en **العربية / الدارجة**, **Français** ou **English** !',
    );
    return notice +
        body +
        _suggestLine(lang, catalog, ['glow', 'vitamin c', 'cerave', 'effaclar']);
  }

  String _suggestLine(String lang, List<Product> catalog, List<String> keywords) {
    if (catalog.isEmpty) return '';
    final scored = <MapEntry<Product, int>>[];
    for (final p in catalog) {
      final text =
          '${p.name} ${p.brand} ${p.description} ${p.ingredients.join(' ')}'
              .toLowerCase();
      var score = 0;
      for (final kw in keywords) {
        if (text.contains(kw.toLowerCase())) score += 1;
      }
      if (score > 0) scored.add(MapEntry(p, score));
    }
    scored.sort((a, b) => b.value.compareTo(a.value));
    final picks = scored.take(2).map((e) => e.key).toList();
    if (picks.isEmpty) return '';

    final header = switch (lang) {
      'ar' => '🛍️ **منتجات من متجرنا قد تساعدك:**',
      'fr' => '🛍️ **Produits de notre boutique :**',
      _ => '🛍️ **Store picks for you:**',
    };
    final lines = picks
        .map((p) =>
            '• **${p.name}** — ${p.price.toStringAsFixed(0)} ${lang == 'ar' ? 'دج' : 'DA'}')
        .join('\n');
    return '\n\n$header\n$lines';
  }
}
