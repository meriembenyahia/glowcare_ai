import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/localization/app_strings.dart';
import '../../core/services/ai_service.dart';
import '../../core/theme/widgets/app_colors.dart';

class AiSettingsDialog extends StatefulWidget {
  const AiSettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const AiSettingsDialog(),
    );
  }

  @override
  State<AiSettingsDialog> createState() => _AiSettingsDialogState();
}

class _AiSettingsDialogState extends State<AiSettingsDialog> {
  final _keyController = TextEditingController();
  final _modelController = TextEditingController();
  final _baseUrlController = TextEditingController();

  bool _isLoading = true;
  bool _isTesting = false;
  bool _obscureKey = true;
  String? _testResult;
  bool _testSuccess = false;
  AiProvider _provider = AiProvider.openai;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _keyController.dispose();
    _modelController.dispose();
    _baseUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    var config = await AiService.instance.getConfig();
    // On the web, OpenAI direct calls are blocked by CORS. Point new users to
    // Gemini so the "test" button works out of the box.
    if (kIsWeb && !config.isConfigured && config.provider == AiProvider.openai) {
      config = await AiService.instance
          .loadProviderConfig(AiProvider.gemini);
    }
    _applyConfig(config);
  }

  void _applyConfig(AiConfig config) {
    if (!mounted) return;
    setState(() {
      _provider = config.provider;
      _keyController.text = config.apiKey;
      _modelController.text = config.model;
      _baseUrlController.text = config.baseUrl;
      _isLoading = false;
      _testResult = null;
    });
  }

  Future<void> _switchProvider(AiProvider? provider) async {
    if (provider == null || provider == _provider) return;
    setState(() {
      _provider = provider;
      _isLoading = true;
      _testResult = null;
    });
    final config = await AiService.instance.loadProviderConfig(provider);
    _applyConfig(config);
  }

  AiConfig _currentConfig() => AiConfig(
        provider: _provider,
        apiKey: _keyController.text.trim(),
        model: _modelController.text.trim(),
        baseUrl: _baseUrlController.text.trim(),
      );

  Future<void> _testConnection() async {
    final s = AppStrings.of(context);
    if (_keyController.text.trim().isEmpty) {
      setState(() {
        _testResult = s.t('Please enter an API key first.');
        _testSuccess = false;
      });
      return;
    }

    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    final res = await AiService.instance.testConnection(_currentConfig());

    if (!mounted) return;
    final success = res['success'] == true;
    String message;
    if (success) {
      message = '${s.t('Connected successfully!')} · ${_modelController.text.trim().isEmpty ? _provider.defaultModel : _modelController.text.trim()}';
    } else if (res['code'] == 'cors') {
      message = s.t(
          'On Flutter Web, OpenAI blocks direct browser calls. Use Gemini, OpenRouter, or a proxy URL.');
    } else if (res['status'] == 401 || res['status'] == 403) {
      message =
          '${s.t('Connection failed')}: ${s.t('API key invalid or expired.')}';
    } else if (res['status'] == 429) {
      message = '${s.t('Connection failed')}: ${s.t('Quota exceeded.')}';
    } else {
      message = '${s.t('Connection failed')}: ${res['message'] ?? ''}';
    }

    setState(() {
      _isTesting = false;
      _testSuccess = success;
      _testResult = message;
    });
  }

  Future<void> _save() async {
    final s = AppStrings.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    await AiService.instance.saveConfig(_currentConfig());
    if (!mounted) return;
    navigator.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          _keyController.text.trim().isEmpty
              ? s.t('Key removed. Smart Local Mode is active.')
              : s.t('Key saved. AI is ready.'),
        ),
        backgroundColor: AppColors.deepGreen,
      ),
    );
  }

  Future<void> _removeKey() async {
    final s = AppStrings.of(context);
    setState(() {
      _keyController.clear();
      _testResult = null;
    });
    await AiService.instance.saveConfig(_currentConfig());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.t('Key removed. Smart Local Mode is active.')),
        backgroundColor: AppColors.deepGreen,
      ),
    );
  }

  String _keyHint() {
    switch (_provider) {
      case AiProvider.openai:
        return 'sk-proj-...';
      case AiProvider.gemini:
        return 'AIza...';
      case AiProvider.openrouter:
        return 'sk-or-v1-...';
      case AiProvider.groq:
        return 'gsk_...';
      case AiProvider.custom:
        return 'your-key';
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final colors = AppThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final providerLabel = s.t(_provider.labelKey);
    final isConfigured = _keyController.text.trim().isNotEmpty;

    return Dialog(
      backgroundColor: colors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: _isLoading
            ? const SizedBox(
                height: 160,
                child: Center(child: CircularProgressIndicator()),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.psychology,
                              color: colors.primary, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.t('AI Advisor Settings'),
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: colors.text,
                                ),
                              ),
                              Text(
                                s.t('Connect your AI provider'),
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: colors.mutedText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close,
                              color: colors.mutedText, size: 20),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Local mode status
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (isConfigured ? Colors.green : Colors.orange)
                            .withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isConfigured
                                ? Icons.bolt
                                : Icons.offline_bolt_outlined,
                            size: 18,
                            color: isConfigured ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isConfigured
                                  ? '$providerLabel · ${_modelController.text.trim().isEmpty ? _provider.defaultModel : _modelController.text.trim()}'
                                  : s.t('Smart Local Mode'),
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: colors.text,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      s.t('Enter your API key for {provider}')
                          .replaceAll('{provider}', providerLabel),
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.text),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _keyController,
                      obscureText: _obscureKey,
                      textDirection: TextDirection.ltr,
                      onChanged: (_) => setState(() {}),
                      style: TextStyle(color: colors.text, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: _keyHint(),
                        fillColor: colors.inputFill,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: _obscureKey
                                  ? s.t('Show key')
                                  : s.t('Hide key'),
                              icon: Icon(
                                _obscureKey
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: colors.mutedText,
                                size: 19,
                              ),
                              onPressed: () =>
                                  setState(() => _obscureKey = !_obscureKey),
                            ),
                            IconButton(
                              tooltip: s.t('Remove key'),
                              icon: Icon(Icons.delete_outline,
                                  color: colors.mutedText, size: 19),
                              onPressed: _removeKey,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Text(
                      s.t('Provider'),
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.text),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: colors.inputFill,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<AiProvider>(
                          value: _provider,
                          isExpanded: true,
                          dropdownColor: colors.cardBackground,
                          style: GoogleFonts.poppins(
                              fontSize: 13, color: colors.text),
                          items: AiProvider.values.map((p) {
                            return DropdownMenuItem<AiProvider>(
                              value: p,
                              child: Text(s.t(p.labelKey)),
                            );
                          }).toList(),
                          onChanged: _switchProvider,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Text(
                      '${s.t('Model')} (${s.t('optional')})',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.text),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _modelController,
                      textDirection: TextDirection.ltr,
                      onChanged: (_) => setState(() {}),
                      style: TextStyle(color: colors.text, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: _provider.defaultModel,
                        fillColor: colors.inputFill,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                    if (_provider.suggestedModels.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _provider.suggestedModels.map((m) {
                          return ActionChip(
                            label: Text(m,
                                style: GoogleFonts.poppins(fontSize: 10.5)),
                            backgroundColor: colors.inputFill,
                            side: BorderSide(
                                color: colors.primary.withValues(alpha: 0.18)),
                            labelStyle: TextStyle(color: colors.text),
                            onPressed: () {
                              setState(() => _modelController.text = m);
                            },
                          );
                        }).toList(),
                      ),
                    ],
                    if (_provider == AiProvider.custom) ...[
                      const SizedBox(height: 14),
                      Text(
                        s.t('API Base URL (advanced)'),
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.text),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _baseUrlController,
                        textDirection: TextDirection.ltr,
                        style:
                            TextStyle(color: colors.text, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'https://my-proxy.com/v1',
                          fillColor: colors.inputFill,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                        ),
                      ),
                    ],
                    if (kIsWeb && _provider == AiProvider.openai) ...[
                      const SizedBox(height: 12),
                      Text(
                        s.t(
                            'On Flutter Web, OpenAI blocks direct browser calls. Use Gemini, OpenRouter, or a proxy URL.'),
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          height: 1.5,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ],
                    if (_provider == AiProvider.gemini) ...[
                      const SizedBox(height: 12),
                      Text(
                        s.t('Get a free Gemini API key from Google AI Studio.'),
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          height: 1.5,
                          color: colors.mutedText,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Text(
                      s.t(
                          'Your key is stored locally on this device only.'),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        height: 1.5,
                        color: colors.mutedText,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_testResult != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (_testSuccess ? Colors.green : Colors.red)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _testSuccess ? Colors.green : Colors.red,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              _testSuccess
                                  ? Icons.check_circle
                                  : Icons.error_outline,
                              color:
                                  _testSuccess ? Colors.green : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _testResult!,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: colors.text,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isTesting ? null : _testConnection,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: colors.primary),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: _isTesting
                                ? SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: colors.primary),
                                  )
                                : Text(
                                    s.t('Test Connection'),
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: colors.primary),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.primary,
                              foregroundColor: isDark
                                  ? const Color(0xFF141D1A)
                                  : AppColors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              s.t('Save & Connect'),
                              style: GoogleFonts.poppins(
                                  fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
