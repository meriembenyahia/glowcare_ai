import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/widgets/app_colors.dart';
import '../cart/cart_provider.dart';
import 'order_confirmation_screen.dart';
import 'order_model.dart';
import 'orders_provider.dart';
import 'wilayas.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  String? _wilaya;

  static const double _delivery = 500;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  String? _required(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? '$label is required' : null;

  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Phone number is required';
    final ok = RegExp(r'^0[567]\d{8}$').hasMatch(v.trim());
    return ok ? null : 'Enter a valid number (e.g. 0555123456)';
  }

  void _confirm() {
    if (!_formKey.currentState!.validate()) return;

    final items = ref.read(cartProvider);
    final subtotal = ref.read(cartProvider.notifier).subtotal;

    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString().substring(6),
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      phone: _phone.text.trim(),
      wilaya: _wilaya!,
      address: _address.text.trim(),
      items: items,
      subtotal: subtotal,
      delivery: _delivery,
      date: DateTime.now(),
    );

    ref.read(ordersProvider.notifier).add(order);
    ref.read(cartProvider.notifier).clear();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => OrderConfirmationScreen(order: order),
      ),
          (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(cartProvider);
    final subtotal = ref.read(cartProvider.notifier).subtotal;
    final colors = AppThemeColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        iconTheme: IconThemeData(color: colors.text),
        title: Text('Checkout',
            style: GoogleFonts.poppins(
                fontSize: 16, color: colors.text)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Delivery information',
                  style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.w600, color: colors.text)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstName,
                      style: TextStyle(color: colors.text),
                      decoration: InputDecoration(
                        hintText: 'First name',
                        fillColor: colors.inputFill,
                        filled: true,
                      ),
                      validator: (v) => _required(v, 'First name'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _lastName,
                      style: TextStyle(color: colors.text),
                      decoration: InputDecoration(
                        hintText: 'Last name',
                        fillColor: colors.inputFill,
                        filled: true,
                      ),
                      validator: (v) => _required(v, 'Last name'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: colors.text),
                decoration: InputDecoration(
                  hintText: 'Phone number',
                  fillColor: colors.inputFill,
                  filled: true,
                ),
                validator: _validatePhone,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _wilaya,
                isExpanded: true,
                dropdownColor: colors.cardBackground,
                style: TextStyle(color: colors.text),
                decoration: InputDecoration(
                  hintText: 'Wilaya',
                  fillColor: colors.inputFill,
                  filled: true,
                ),
                items: [
                  for (final w in wilayas)
                    DropdownMenuItem(value: w, child: Text(w, style: TextStyle(color: colors.text))),
                ],
                onChanged: (v) => setState(() => _wilaya = v),
                validator: (v) => v == null ? 'Please select a wilaya' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _address,
                maxLines: 2,
                style: TextStyle(color: colors.text),
                decoration: InputDecoration(
                  hintText: 'Delivery address',
                  fillColor: colors.inputFill,
                  filled: true,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Address is required';
                  }
                  if (v.trim().length < 8) return 'Address is too short';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // ملخص الطلب
              Text('Order summary',
                  style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.w600, color: colors.text)),
              const SizedBox(height: 8),
              for (final e in items)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text('${e.product.name} x${e.quantity}',
                            style: GoogleFonts.poppins(fontSize: 12, color: colors.text)),
                      ),
                      Text(
                          '${(e.product.price * e.quantity).toStringAsFixed(0)} DA',
                          style: GoogleFonts.poppins(fontSize: 12, color: colors.text)),
                    ],
                  ),
                ),
              const Divider(),
              _row(context, 'Subtotal', subtotal),
              _row(context, 'Delivery', _delivery),
              _row(context, 'Total', subtotal + _delivery, bold: true),
              const SizedBox(height: 8),
              Text('Payment: Cash on delivery',
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: colors.mutedText)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: items.isEmpty ? null : _confirm,
                child: const Text('Confirm Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, double value, {bool bold = false}) {
    final colors = AppThemeColors.of(context);
    final style = GoogleFonts.poppins(
      fontSize: bold ? 14 : 12,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      color: bold ? colors.primary : colors.text,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text('${value.toStringAsFixed(0)} DA', style: style),
        ],
      ),
    );
  }
}
