import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/widgets/app_colors.dart';
import '../../core/theme/widgets/app_bar_title.dart';
import '../cart/cart_provider.dart';
import '../loyalty/loyalty_provider.dart';
import 'order_confirmation_screen.dart';
import 'order_model.dart';
import 'orders_provider.dart';
import 'payment_method.dart';
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
  final _cardHolder = TextEditingController();
  final _cardNumber = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();
  final _paymentRef = TextEditingController();
  String? _wilaya;
  PaymentMethod _paymentMethod = PaymentMethod.cod;

  static const double _delivery = 500;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _address.dispose();
    _cardHolder.dispose();
    _cardNumber.dispose();
    _expiry.dispose();
    _cvv.dispose();
    _paymentRef.dispose();
    super.dispose();
  }

  String? _validatePhone(String? v, AppStrings s) {
    if (v == null || v.trim().isEmpty) return s.t('Phone number is required');
    final ok = RegExp(r'^0[567]\d{8}$').hasMatch(v.trim());
    return ok ? null : s.t('Enter a valid number (e.g. 0555123456)');
  }

  void _confirm() {
    if (!_formKey.currentState!.validate()) return;

    final items = ref.read(cartProvider);
    final subtotal = ref.read(cartProvider.notifier).subtotal;
    final digits = _cardNumber.text.replaceAll(RegExp(r'\D'), '');

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
      paymentMethod: _paymentMethod.name,
      paymentStatus: _paymentMethod.needsVerification ? 'pending' : 'cod',
      paymentReference: _paymentMethod.isCard
          ? (digits.length >= 4 ? '•••• ${digits.substring(digits.length - 4)}' : '')
          : _paymentMethod == PaymentMethod.baridimob
              ? _paymentRef.text.trim()
              : '',
    );

    ref.read(ordersProvider.notifier).add(order);
    ref.read(loyaltyProvider.notifier).addPoints(subtotal, orderId: order.id);
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
    final s = AppStrings.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        iconTheme: IconThemeData(color: colors.text),
        title: AppBarTitle(
          text: s.t('Checkout'),
          style: GoogleFonts.poppins(fontSize: 16, color: colors.text),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.t('Delivery information'),
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
                        hintText: s.t('First name'),
                        fillColor: colors.inputFill,
                        filled: true,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? s.t('First name is required')
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _lastName,
                      style: TextStyle(color: colors.text),
                      decoration: InputDecoration(
                        hintText: s.t('Last name'),
                        fillColor: colors.inputFill,
                        filled: true,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? s.t('Last name is required')
                          : null,
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
                  hintText: s.t('Phone number'),
                  fillColor: colors.inputFill,
                  filled: true,
                ),
                validator: (v) => _validatePhone(v, s),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _wilaya,
                isExpanded: true,
                dropdownColor: colors.cardBackground,
                style: TextStyle(color: colors.text),
                decoration: InputDecoration(
                  hintText: s.t('Wilaya'),
                  fillColor: colors.inputFill,
                  filled: true,
                ),
                items: [
                  for (final w in wilayas)
                    DropdownMenuItem(value: w, child: Text(w, style: TextStyle(color: colors.text))),
                ],
                onChanged: (v) => setState(() => _wilaya = v),
                validator: (v) => v == null ? s.t('Please select a wilaya') : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _address,
                maxLines: 2,
                style: TextStyle(color: colors.text),
                decoration: InputDecoration(
                  hintText: s.t('Delivery address'),
                  fillColor: colors.inputFill,
                  filled: true,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return s.t('Address is required');
                  }
                  if (v.trim().length < 8) return s.t('Address is too short');
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // ملخص الطلب
              Text(s.t('Order summary'),
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
                          s.money(e.product.price * e.quantity),
                          style: GoogleFonts.poppins(fontSize: 12, color: colors.text)),
                    ],
                  ),
                ),
              const Divider(),
              _row(context, 'Subtotal', subtotal),
              _row(context, 'Delivery', _delivery),
              _row(context, 'Total', subtotal + _delivery, bold: true),
              const SizedBox(height: 20),

              // طريقة الدفع
              Text(s.t('Payment method'),
                  style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.w600, color: colors.text)),
              const SizedBox(height: 8),
              for (final method in PaymentMethod.values) ...[
                _paymentTile(context, method, colors, s),
                const SizedBox(height: 8),
              ],
              if (_paymentMethod.isCard) _cardFields(context, colors, s),
              if (_paymentMethod == PaymentMethod.baridimob)
                _baridimobFields(context, colors, s),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: items.isEmpty ? null : _confirm,
                child: Text(s.t('Confirm Order')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paymentTile(
    BuildContext context,
    PaymentMethod method,
    AppThemeColors colors,
    AppStrings s,
  ) {
    final selected = _paymentMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? colors.primary.withValues(alpha: 0.08)
              : colors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? colors.primary
                : colors.mutedText.withValues(alpha: 0.2),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(method.icon,
                size: 20,
                color: selected ? colors.primary : colors.mutedText),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.t(method.labelKey),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                    ),
                  ),
                  Text(
                    s.t(method.descriptionKey),
                    style: GoogleFonts.poppins(
                        fontSize: 10.5, color: colors.mutedText),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 18,
              color: selected ? colors.primary : colors.mutedText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardFields(
    BuildContext context,
    AppThemeColors colors,
    AppStrings s,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.inputFill,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          TextFormField(
            controller: _cardHolder,
            style: TextStyle(color: colors.text),
            textCapitalization: TextCapitalization.words,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              hintText: s.t('Cardholder name'),
              fillColor: colors.cardBackground,
              filled: true,
            ),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? s.t('Enter cardholder name')
                : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _cardNumber,
            keyboardType: TextInputType.number,
            textDirection: TextDirection.ltr,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
            ],
            style: TextStyle(color: colors.text, letterSpacing: 2),
            decoration: InputDecoration(
              hintText: s.t('Card number'),
              fillColor: colors.cardBackground,
              filled: true,
              prefixIcon: Icon(Icons.credit_card, color: colors.mutedText, size: 20),
            ),
            validator: (v) {
              final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
              return digits.length == 16
                  ? null
                  : s.t('Enter a valid 16-digit card number');
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expiry,
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                    LengthLimitingTextInputFormatter(5),
                  ],
                  style: TextStyle(color: colors.text),
                  decoration: InputDecoration(
                    hintText: s.t('Expiry date (MM/YY)'),
                    fillColor: colors.cardBackground,
                    filled: true,
                  ),
                  validator: (v) {
                    final value = (v ?? '').trim();
                    if (!RegExp(r'^(0[1-9]|1[0-2])/\d{2}$').hasMatch(value)) {
                      return s.t('Enter a valid expiry date (MM/YY)');
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _cvv,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  textDirection: TextDirection.ltr,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  style: TextStyle(color: colors.text),
                  decoration: InputDecoration(
                    hintText: s.t('CVV'),
                    fillColor: colors.cardBackground,
                    filled: true,
                  ),
                  validator: (v) => (v ?? '').length == 3
                      ? null
                      : s.t('Enter the 3-digit CVV'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _paymentNote(
            colors,
            s.t('Demo confirmation only: no real charge is made and card data is not stored.'),
          ),
        ],
      ),
    );
  }

  Widget _baridimobFields(
    BuildContext context,
    AppThemeColors colors,
    AppStrings s,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.inputFill,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _paymentRef,
            style: TextStyle(color: colors.text),
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              hintText: s.t('Transaction reference'),
              helperText: s.t('From your Baridimob receipt'),
              fillColor: colors.cardBackground,
              filled: true,
            ),
            validator: (v) => (v == null || v.trim().length < 5)
                ? s.t('Enter the transaction reference from your Baridimob receipt')
                : null,
          ),
          const SizedBox(height: 10),
          _paymentNote(
            colors,
            s.t('Your transfer will be verified by our team before the order is shipped.'),
          ),
        ],
      ),
    );
  }

  Widget _paymentNote(AppThemeColors colors, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.lock_outline, size: 13, color: colors.mutedText),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 10,
              height: 1.4,
              color: colors.mutedText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _row(BuildContext context, String label, double value, {bool bold = false}) {
    final colors = AppThemeColors.of(context);
    final s = AppStrings.of(context);
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
          Text(s.t(label), style: style),
          Text(s.money(value), style: style),
        ],
      ),
    );
  }
}
