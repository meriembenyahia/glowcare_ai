import 'package:flutter/material.dart';

class AppStrings {
  final String languageCode;

  const AppStrings(this.languageCode);

  static AppStrings of(BuildContext context) {
    final locale = Localizations.maybeLocaleOf(context) ?? const Locale('ar');
    return AppStrings(locale.languageCode);
  }

  bool get isArabic => languageCode == 'ar';
  bool get isFrench => languageCode == 'fr';
  bool get isEnglish => languageCode == 'en';

  // Navigation
  String get navHome => isArabic ? 'الرئيسية' : isFrench ? 'Accueil' : 'Home';
  String get navShop => isArabic ? 'المتجر' : isFrench ? 'Boutique' : 'Shop';
  String get navBeautyLab => isArabic ? 'مختبر الجمال' : isFrench ? 'Labo Beauté' : 'Beauty Lab';
  String get navRoutine => isArabic ? 'الروتين' : isFrench ? 'Routine' : 'Routine';
  String get navOrders => isArabic ? 'طلباتي' : isFrench ? 'Commandes' : 'Orders';

  // Home Screen
  String get appTitle => 'GlowCare AI';
  String get searchHint => isArabic ? 'ابحث عن منتجات العناية بالبشرة والمكياج...' : isFrench ? 'Rechercher des produits, soins...' : 'Search for products, skincare...';
  String get bannerTitle => isArabic ? 'بشرة صحية\nجمال طبيعي' : isFrench ? 'Peau Saine\nBeauté Naturelle' : 'Healthy Skin\nNatural Beauty';
  String get bannerSubtitle => isArabic ? 'اكتشفي أفضل تركيبات العناية التجميلية' : isFrench ? 'Découvrez nos meilleures formules' : 'Discover top skincare & makeup formulas';
  String get shopNow => isArabic ? 'تسوقي الآن' : isFrench ? 'Acheter' : 'Shop Now';
  String get aiSkinConsultation => isArabic ? 'استشارة البشرة بالذكاء الاصطناعي' : isFrench ? 'Consultation Peau IA' : 'AI Skin Consultation';
  String get aiSkinSubtitle => isArabic ? 'اختبار دقيقة واحدة للحصول على روتين مخصص لك' : isFrench ? 'Quiz d\'une minute pour un soin sur-mesure' : 'Take a 1-minute AI quiz to get custom skincare picks';
  String get beautyLabAi => isArabic ? 'مساعد مختبر الجمال الذكي' : isFrench ? 'Assistant Labo Beauté IA' : 'Beauty Lab AI Chatbot';
  String get beautyLabSubtitle => isArabic ? 'استشيري الذكاء الاصطناعي حول المكونات وسلامة التركيبات' : isFrench ? 'Discutez directement sur les formules et la sécurité' : 'Chat directly with AI on formulas, safety & routines';
  String get loyaltyCardTitle => isArabic ? 'بطاقة الولاء والمكافآت' : isFrench ? 'Carte de Fidélité' : 'Loyalty Card';
  String get loyaltyCardSubtitle => isArabic ? 'نقاط، خصومات فورية وهدايا حصرية' : isFrench ? 'Points, remises et privilèges exclusifs' : 'Points accumulated • Member discounts & rewards';
  String get viewCard => isArabic ? 'عرض' : isFrench ? 'Voir' : 'View';

  // Categories
  String get catSkincare => isArabic ? 'عناية بالبشرة' : isFrench ? 'Soins visage' : 'Skincare';
  String get catMakeup => isArabic ? 'مكياج' : isFrench ? 'Maquillage' : 'Makeup';
  String get catHairCare => isArabic ? 'عناية بالشعر' : isFrench ? 'Cheveux' : 'Hair Care';
  String get catFragrance => isArabic ? 'عطور' : isFrench ? 'Parfums' : 'Fragrance';

  // Sections
  String get bestForYou => isArabic ? 'الأفضل لكِ' : isFrench ? 'Pour vous' : 'Best for You';
  String get seeAll => isArabic ? 'عرض الكل ←' : isFrench ? 'Voir tout →' : 'See All →';
  String get trendingProducts => isArabic ? 'المنتجات الأكثر طلباً' : isFrench ? 'Produits Tendances' : 'Trending Products';

  // Cart & Checkout
  String get myCart => isArabic ? 'سلة المشتريات' : isFrench ? 'Mon Panier' : 'My Cart';
  String get emptyCart => isArabic ? 'سلتك فارغة حالياً' : isFrench ? 'Votre panier est vide' : 'Your cart is empty';
  String get subtotal => isArabic ? 'المجموع الفرعي' : isFrench ? 'Sous-total' : 'Subtotal';
  String get delivery => isArabic ? 'التوصيل (58 ولاية)' : isFrench ? 'Livraison' : 'Delivery';
  String get total => isArabic ? 'المجموع الإجمالي' : isFrench ? 'Total' : 'Total';
  String get proceedCheckout => isArabic ? 'متابعة الطلب والدفع' : isFrench ? 'Passer la commande' : 'Proceed to Checkout';
  String get deliveryInfo => isArabic ? 'معلومات التوصيل' : isFrench ? 'Informations de livraison' : 'Delivery information';
  String get firstName => isArabic ? 'الاسم الأول' : isFrench ? 'Prénom' : 'First name';
  String get lastName => isArabic ? 'اللقب (اسم العائلة)' : isFrench ? 'Nom' : 'Last name';
  String get phoneNumber => isArabic ? 'رقم الهاتف (مثال: 0555123456)' : isFrench ? 'Numéro de téléphone' : 'Phone number';
  String get wilaya => isArabic ? 'الولاية' : isFrench ? 'Wilaya' : 'Wilaya';
  String get address => isArabic ? 'العنوان بالتفصيل' : isFrench ? 'Adresse de livraison' : 'Delivery address';
  String get confirmOrder => isArabic ? 'تأكيد الطلب الآن' : isFrench ? 'Confirmer la commande' : 'Confirm Order';
  String get cashOnDelivery => isArabic ? 'الدفع عند الاستلام (Paiement à la livraison)' : isFrench ? 'Paiement à la livraison' : 'Payment: Cash on delivery';

  // Profile & Settings
  String get myProfile => isArabic ? 'الملف الشخصي' : isFrench ? 'Mon Profil' : 'My Profile';
  String get shortcuts => isArabic ? 'روابط سريعة' : isFrench ? 'Raccourcis' : 'Shortcuts';
  String get myOrders => isArabic ? 'طلباتي السابقة' : isFrench ? 'Mes Commandes' : 'My Orders';
  String get wishlist => isArabic ? 'المفضلة ❤️' : isFrench ? 'Favoris ❤️' : 'Wishlist';
  String get darkMode => isArabic ? 'الوضع الليلي (Dark Mode)' : isFrench ? 'Mode Sombre' : 'Dark Mode';
  String get language => isArabic ? 'لغة التطبيق (Language)' : isFrench ? 'Langue' : 'App Language';
  String get currentLanguage => isArabic ? 'العربية' : isFrench ? 'Français' : 'English';
  String get deliveryAddress => isArabic ? 'عنوان التوصيل الافتراضي' : isFrench ? 'Adresse de livraison' : 'Default Delivery Address';
  String get algeriaCoverage => isArabic ? 'الجزائر (تغطية 58 ولاية كاملة)' : isFrench ? 'Algérie (58 Wilayas)' : 'Algeria (58 Wilayas supported)';
  String get signIn => isArabic ? 'تسجيل الدخول' : isFrench ? 'Se connecter' : 'Sign In';
  String get signOut => isArabic ? 'تسجيل الخروج' : isFrench ? 'Se déconnecter' : 'Sign Out';
  String get guestUser => isArabic ? 'زائر (غير مسجل)' : isFrench ? 'Utilisateur Invité' : 'Guest User';
  String get memberUser => isArabic ? 'عضو GlowCare' : isFrench ? 'Membre GlowCare' : 'GlowCare Member';

  // Loyalty Card
  String get pts => isArabic ? 'نقطة' : isFrench ? 'pts' : 'pts';
  String get loyaltyTitle => isArabic ? 'بطاقة الولاء GlowCare' : isFrench ? 'Carte de Fidélité GlowCare' : 'GlowCare Loyalty Card';
  String get progressTo => isArabic ? 'التقدم نحو مستوى' : isFrench ? 'Progression vers' : 'Progress to';
  String get privileges => isArabic ? 'المزايا الحصرية للمستوى' : isFrench ? 'Privilèges du Membre' : 'Member Privileges';
  String get howToEarn => isArabic ? 'كيف تجمع النقاط؟' : isFrench ? 'Comment gagner des points ?' : 'How to earn points?';
  String get pointsHistory => isArabic ? 'سجل العمليات والنقاط' : isFrench ? 'Historique des points' : 'Points History';

  // Currency
  String formatPrice(double price) => '${price.toStringAsFixed(0)} ${isArabic ? "دج" : "DA"}';
}
