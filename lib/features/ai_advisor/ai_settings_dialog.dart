import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  bool _isLoading = true;
  bool _isTesting = false;
  String? _testResult;
  bool _testSuccess = false;
  String _selectedModel = 'gpt-4o-mini';

  final List<String> _models = [
    'gpt-4o-mini',
    'gpt-3.5-turbo',
    'gpt-4o',
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final key = await AiService.instance.getApiKey();
    final model = await AiService.instance.getModel();
    if (mounted) {
      setState(() {
        _keyController.text = key ?? '';
        _selectedModel = model;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    final key = _keyController.text.trim();
    if (key.isEmpty) {
      setState(() {
        _testResult = 'Please enter an OpenAI API key first.';
        _testSuccess = false;
      });
      return;
    }

    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    final res = await AiService.instance.testConnection(key);

    if (mounted) {
      setState(() {
        _isTesting = false;
        _testSuccess = res['success'] == true;
        _testResult = res['message'] as String;
      });
    }
  }

  Future<void> _save() async {
    await AiService.instance.setApiKey(_keyController.text.trim());
    await AiService.instance.setModel(_selectedModel);
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _keyController.text.trim().isEmpty
                ? 'OpenAI API key cleared. Using local smart engine.'
                : 'ChatGPT settings saved successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: colors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: SingleChildScrollView(
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
                    child: Icon(Icons.psychology, color: colors.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ChatGPT (OpenAI) Setup',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: colors.text,
                          ),
                        ),
                        Text(
                          'ربط الذكاء الاصطناعي مع ChatGPT',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: colors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: colors.mutedText, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Enter your OpenAI API Key to connect your AI Skincare Advisor directly to ChatGPT for unrestricted live consultations:',
                style: GoogleFonts.poppins(fontSize: 12, color: colors.text, height: 1.5),
              ),
              const SizedBox(height: 16),

              // API Key field
              Text(
                'OpenAI API Key (sk-...)',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: colors.text),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _keyController,
                obscureText: true,
                style: TextStyle(color: colors.text, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'sk-proj-...',
                  fillColor: colors.inputFill,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear, color: colors.mutedText, size: 18),
                    onPressed: () => _keyController.clear(),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Model selector
              Text(
                'ChatGPT Model',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: colors.text),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: colors.inputFill,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedModel,
                    isExpanded: true,
                    dropdownColor: colors.cardBackground,
                    style: GoogleFonts.poppins(fontSize: 13, color: colors.text),
                    items: _models.map((m) {
                      return DropdownMenuItem(
                        value: m,
                        child: Text(m),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedModel = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Test Result Banner
              if (_testResult != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _testSuccess
                        ? Colors.green.withValues(alpha: 0.15)
                        : Colors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _testSuccess ? Colors.green : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _testSuccess ? Icons.check_circle : Icons.error_outline,
                        color: _testSuccess ? Colors.green : Colors.red,
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

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isTesting ? null : _testConnection,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isTesting
                          ? SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: colors.primary),
                            )
                          : Text(
                              'Test API Key',
                              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: colors.primary),
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: isDark ? const Color(0xFF141D1A) : AppColors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Save & Connect',
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
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
