import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/widgets/app_colors.dart';
import '../shop/product.dart';
import '../shop/product_provider.dart';

class AddProductDialog extends ConsumerStatefulWidget {
  final Product? productToEdit;
  const AddProductDialog({super.key, this.productToEdit});

  @override
  ConsumerState<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends ConsumerState<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _priceController;
  late final TextEditingController _imageController;
  late final TextEditingController _descController;
  late final TextEditingController _ingredientsController;
  String _category = 'Skincare';

  static const _categories = ['Skincare', 'Makeup', 'Hair Care', 'Fragrance'];

  @override
  void initState() {
    super.initState();
    final p = widget.productToEdit;
    _nameController = TextEditingController(text: p?.name ?? '');
    _brandController = TextEditingController(text: p?.brand ?? 'GlowCare');
    _priceController = TextEditingController(text: p != null ? p.price.toStringAsFixed(0) : '');
    _imageController = TextEditingController(
      text: p?.image ?? 'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=800&auto=format&fit=crop',
    );
    _descController = TextEditingController(text: p?.description ?? '');
    _ingredientsController = TextEditingController(text: p?.ingredients.join(', ') ?? '');
    if (p != null && _categories.contains(p.category)) {
      _category = p.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    _descController.dispose();
    _ingredientsController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final s = AppStrings.of(context);
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final ingredients = _ingredientsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final product = Product(
      id: widget.productToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      brand: _brandController.text.trim(),
      price: price,
      rating: widget.productToEdit?.rating ?? 4.8,
      category: _category,
      image: _imageController.text.trim(),
      description: _descController.text.trim(),
      ingredients: ingredients,
    );

    if (widget.productToEdit != null) {
      ref.read(productsProvider.notifier).updateProduct(product);
    } else {
      ref.read(productsProvider.notifier).addProduct(product);
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.productToEdit != null
            ? s.t('Product updated successfully')
            : s.t('Product added to store catalog')),
        backgroundColor: AppColors.deepGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final isEdit = widget.productToEdit != null;
    final s = AppStrings.of(context);

    return Dialog(
      backgroundColor: colors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEdit ? s.t('Edit Product') : s.t('Add New Product'),
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: colors.text,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: colors.mutedText),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  _field(colors, s.t('Product Name'), _nameController, s.t('e.g. Pure Hyaluronic Serum'), (v) {
                    if (v == null || v.trim().isEmpty) return s.t('Product name is required');
                    return null;
                  }),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _field(colors, s.t('Brand'), _brandController, s.t('e.g. CeraVe'), (v) {
                          if (v == null || v.trim().isEmpty) return s.t('Brand is required');
                          return null;
                        }),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _field(colors, s.t('Price (DA)'), _priceController, s.t('e.g. 2800'), (v) {
                          if (v == null || v.trim().isEmpty) return s.t('Price required');
                          if (double.tryParse(v) == null) return s.t('Valid number');
                          return null;
                        }, isNumber: true),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Text(s.t('Category'), style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: colors.text)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    dropdownColor: colors.cardBackground,
                    style: TextStyle(color: colors.text),
                    decoration: InputDecoration(
                      fillColor: colors.inputFill,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    items: [
                      for (final cat in _categories)
                        DropdownMenuItem(value: cat, child: Text(s.t(cat), style: TextStyle(color: colors.text))),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _category = v);
                    },
                  ),
                  const SizedBox(height: 10),

                  _field(colors, s.t('Image URL'), _imageController, 'https://...', (v) {
                    if (v == null || v.trim().isEmpty) return s.t('Image URL is required');
                    return null;
                  }),
                  const SizedBox(height: 10),

                  _field(colors, s.t('Description'), _descController, s.t('Brief product details...'), null, maxLines: 2),
                  const SizedBox(height: 10),

                  _field(colors, s.t('Ingredients (comma separated)'), _ingredientsController, s.t('Niacinamide, Zinc, Aqua...'), null),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        isEdit ? s.t('Save Changes') : s.t('Add to Catalog'),
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    AppThemeColors colors,
    String label,
    TextEditingController controller,
    String hint,
    String? Function(String?)? validator, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: colors.text)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          style: GoogleFonts.poppins(color: colors.text, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: colors.mutedText, fontSize: 12),
            fillColor: colors.inputFill,
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
