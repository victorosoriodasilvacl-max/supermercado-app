import 'package:flutter/material.dart';

/// Opciones de portada tipo "supermercado" que el cliente puede elegir
/// mientras no tenga su propia foto de cabecera cargada.
enum BannerTheme {
  carrito(Icons.shopping_cart_rounded, 'Carrito'),
  frutasYVerduras(Icons.eco_rounded, 'Frutas y verduras'),
  carniceria(Icons.set_meal_rounded, 'Carnicería'),
  panaderia(Icons.bakery_dining_rounded, 'Panadería'),
  lacteos(Icons.icecream_rounded, 'Lácteos'),
  ofertas(Icons.local_offer_rounded, 'Ofertas');

  const BannerTheme(this.icon, this.label);
  final IconData icon;
  final String label;
}

/// Íconos disponibles para el asistente de IA de cara al comprador.
enum AiIconOption {
  robot(Icons.smart_toy_rounded, 'Robot'),
  android(Icons.android_rounded, 'Android'),
  chip(Icons.memory_rounded, 'Chip'),
  sparkle(Icons.auto_awesome_rounded, 'Destello'),
  support(Icons.support_agent_rounded, 'Soporte'),
  chat(Icons.forum_rounded, 'Chat');

  const AiIconOption(this.icon, this.label);
  final IconData icon;
  final String label;
}

/// Configuración "de marca blanca": lo que cada cliente puede personalizar.
class TenantConfig {
  TenantConfig({
    required this.shopName,
    required this.logoEmoji,
    required this.primaryColor,
    required this.secondaryColor,
    required this.tagline,
    this.bannerTheme = BannerTheme.carrito,
    this.instagramUrl = '',
    this.facebookUrl = '',
    this.tiktokUrl = '',
    this.whatsappNumber = '',
    this.aiName = 'AI Market',
    this.aiIcon = AiIconOption.robot,
  });

  String shopName;
  String logoEmoji;
  Color primaryColor;
  Color secondaryColor;
  String tagline;
  BannerTheme bannerTheme;
  String instagramUrl;
  String facebookUrl;
  String tiktokUrl;
  String whatsappNumber;
  String aiName;
  AiIconOption aiIcon;

  TenantConfig copy() => TenantConfig(
        shopName: shopName,
        logoEmoji: logoEmoji,
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
        tagline: tagline,
        bannerTheme: bannerTheme,
        instagramUrl: instagramUrl,
        facebookUrl: facebookUrl,
        tiktokUrl: tiktokUrl,
        whatsappNumber: whatsappNumber,
        aiName: aiName,
        aiIcon: aiIcon,
      );
}

/// Íconos/colores por categoría, usados como "foto" del producto hasta que
/// el cliente cargue sus propias imágenes reales desde el backend.
const Map<String, IconData> categoryIcons = {
  'Frutas y Verduras': Icons.eco_rounded,
  'Carnes': Icons.set_meal_rounded,
  'Lácteos': Icons.icecream_rounded,
  'Despensa': Icons.kitchen_rounded,
  'Bebidas': Icons.local_bar_rounded,
  'Limpieza': Icons.cleaning_services_rounded,
};

const Map<String, Color> categoryColors = {
  'Frutas y Verduras': Color(0xFF43A047),
  'Carnes': Color(0xFFD84315),
  'Lácteos': Color(0xFF1E88E5),
  'Despensa': Color(0xFF8D6E63),
  'Bebidas': Color(0xFFFB8C00),
  'Limpieza': Color(0xFF00897B),
};

/// Un producto del catálogo. El cliente ingresa y edita todos sus datos
/// (nombre, precio, oferta, descripción y foto) desde el panel de control.
class Product {
  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.unit,
    this.oldPrice,
    this.description = '',
  });

  final String id;
  String name;
  String category;
  int price;
  int? oldPrice;
  String unit;
  String description;

  bool get isOnSale => oldPrice != null && oldPrice! > price;

  IconData get icon => categoryIcons[category] ?? Icons.shopping_basket_rounded;
  Color get color => categoryColors[category] ?? const Color(0xFF616161);
}

class CartItem {
  CartItem({required this.product, this.quantity = 1});

  final Product product;
  int quantity;

  int get subtotal => product.price * quantity;
}

enum DeliveryMethod { delivery, pickup }

enum OrderStage { preparando, enCamino, entregado }

class StoreOrder {
  StoreOrder({
    required this.id,
    required this.items,
    required this.method,
    required this.total,
    this.address,
    this.timeSlot,
    this.pickupCode,
    this.stage = OrderStage.preparando,
  });

  final String id;
  final List<CartItem> items;
  final DeliveryMethod method;
  final int total;
  final String? address;
  final String? timeSlot;
  final String? pickupCode;
  OrderStage stage;
}

class ChatMessage {
  ChatMessage({required this.text, required this.fromUser});

  final String text;
  final bool fromUser;
}
