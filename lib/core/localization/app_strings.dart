import 'package:flutter/material.dart';

import 'translations.dart';

/// Locale-aware access to all UI strings.
///
/// Usage:
/// ```dart
/// final s = AppStrings.of(context);
/// Text(s.t('Shop'));
/// Text(s.tf('My Cart ({count})', {'count': '${items.length}'}));
/// Text(s.money(product.price));
/// ```
class AppStrings extends AppTranslations {
  const AppStrings(super.languageCode);

  static AppStrings of(BuildContext context) {
    final locale = Localizations.maybeLocaleOf(context) ?? const Locale('ar');
    return AppStrings(locale.languageCode);
  }

  // Navigation
  String get navHome => t('Home');
  String get navShop => t('Shop');
  String get navBeautyLab => t('Beauty Lab');
  String get navRoutine => t('Routine');
  String get navOrders => t('Orders');

  // Home
  String get appTitle => 'GlowCare AI';
  String get searchHint => t('Search for products, skincare...');
  String get bannerTitle => t('Healthy Skin\nNatural Beauty');
  String get bannerSubtitle => t('Discover top skincare & makeup formulas');
  String get shopNow => t('Shop Now');
  String get aiSkinConsultation => t('AI Skin Consultation');
  String get aiSkinSubtitle => t('Take a 1-minute AI quiz to get custom skincare picks');
  String get beautyLabAi => t('Beauty Lab AI Chatbot');
  String get beautyLabSubtitle =>
      t('Chat directly with AI on formulas, safety & routines');
  String get loyaltyCardTitle => t('Loyalty Card');
  String get loyaltyCardSubtitle =>
      t('Points accumulated • Member discounts & rewards');
  String get viewCard => t('View');

  // Categories
  String get catSkincare => t('Skincare');
  String get catMakeup => t('Makeup');
  String get catHairCare => t('Hair Care');
  String get catFragrance => t('Fragrance');

  // Sections
  String get bestForYou => t('Best for You');
  String get seeAll => t('See All →');
  String get trendingProducts => t('Trending Products');

  // Cart & checkout
  String get myCart => t('My Cart ({count})');
  String get emptyCart => t('Your cart is empty');
  String get subtotal => t('Subtotal');
  String get delivery => t('Delivery');
  String get total => t('Total');
  String get proceedCheckout => t('Proceed to Checkout');
  String get deliveryInfo => t('Delivery information');
  String get firstName => t('First name');
  String get lastName => t('Last name');
  String get phoneNumber => t('Phone number');
  String get wilaya => t('Wilaya');
  String get address => t('Delivery address');
  String get confirmOrder => t('Confirm Order');
  String get cashOnDelivery => t('Payment: Cash on delivery');

  // Profile & settings
  String get myProfile => t('My Profile');
  String get shortcuts => t('Shortcuts');
  String get myOrders => t('My Orders');
  String get wishlist => t('Wishlist');
  String get darkMode => t('Dark Mode');
  String get language => t('App Language');
  String get currentLanguage => isArabic
      ? 'العربية'
      : isFrench
          ? 'Français'
          : 'English';
  String get deliveryAddress => t('Default Delivery Address');
  String get algeriaCoverage => t('Algeria (58 Wilayas supported)');
  String get signIn => t('Sign In');
  String get signOut => t('Sign Out');
  String get guestUser => t('Guest User');
  String get memberUser => t('GlowCare Member');
  String get profileSignInHint => t('Sign in to sync your routine & orders');

  // Loyalty
  String get pts => t('pts');
  String get loyaltyTitle => t('Carte de Fidélité (Loyalty Card)');
  String get progressTo => t('Progress to {tier}');
  String get privileges => t('{tier} Member Privileges');
  String get howToEarn => t('Comment accumuler des points ? (How it works)');
  String get pointsHistory => t('Points History');
  String get vipGuest => t('VIP Guest Member');
  String get myCartWithCount => t('My Cart ({count})');

  String price(double value) => money(value);

  /// Backwards-compatible helper used by older screens.
  String formatPrice(double price) => money(price);

  /// Direction-aware chevron used across cards and list tiles.
  IconData chevronIcon(BuildContext context) =>
      Directionality.of(context) == TextDirection.rtl
          ? Icons.chevron_left
          : Icons.chevron_right;
}
