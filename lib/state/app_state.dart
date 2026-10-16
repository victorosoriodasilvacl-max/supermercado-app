import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../services/ai_assistant.dart';

class AppState extends ChangeNotifier {
  AppState()
      : tenant = defaultTenant(),
        products = List.of(mockProducts);

  final TenantConfig tenant;

  // --- Catálogo (el cliente puede agregar sus propios productos) ---
  final List<Product> products;

  void addProduct(Product product) {
    products.add(product);
    notifyListeners();
  }

  void updateProduct(
    Product product, {
    String? name,
    String? category,
    int? price,
    int? oldPrice,
    bool clearOldPrice = false,
    String? description,
    String? unit,
  }) {
    if (name != null) product.name = name;
    if (category != null) product.category = category;
    if (price != null) product.price = price;
    if (clearOldPrice) {
      product.oldPrice = null;
    } else if (oldPrice != null) {
      product.oldPrice = oldPrice;
    }
    if (description != null) product.description = description;
    if (unit != null) product.unit = unit;
    notifyListeners();
  }

  void removeProduct(Product product) {
    products.remove(product);
    productImages.remove(product.id);
    notifyListeners();
  }

  // --- Fotos subidas desde el equipo del cliente (por sesión, en memoria) ---
  final Map<String, Uint8List> productImages = {};
  Uint8List? logoImageBytes;
  Uint8List? bannerImageBytes;

  void setProductImage(String productId, Uint8List bytes) {
    productImages[productId] = bytes;
    notifyListeners();
  }

  void removeProductImage(String productId) {
    productImages.remove(productId);
    notifyListeners();
  }

  void setLogoImage(Uint8List bytes) {
    logoImageBytes = bytes;
    notifyListeners();
  }

  void clearLogoImage() {
    logoImageBytes = null;
    notifyListeners();
  }

  void setBannerImage(Uint8List bytes) {
    bannerImageBytes = bytes;
    notifyListeners();
  }

  void clearBannerImage() {
    bannerImageBytes = null;
    notifyListeners();
  }

  // Fondo de toda la página (detrás del catálogo).
  Uint8List? pageBackgroundBytes;

  void setPageBackground(Uint8List bytes) {
    pageBackgroundBytes = bytes;
    notifyListeners();
  }

  void clearPageBackground() {
    pageBackgroundBytes = null;
    notifyListeners();
  }

  // Fondo exclusivo de la pantalla de bienvenida / login.
  Uint8List? welcomeBackgroundBytes;

  void setWelcomeBackground(Uint8List bytes) {
    welcomeBackgroundBytes = bytes;
    notifyListeners();
  }

  void clearWelcomeBackground() {
    welcomeBackgroundBytes = null;
    notifyListeners();
  }

  final Map<String, CartItem> _cart = {};
  List<CartItem> get cartItems => _cart.values.toList();

  int get cartCount =>
      _cart.values.fold(0, (sum, item) => sum + item.quantity);
  int get cartTotal =>
      _cart.values.fold(0, (sum, item) => sum + item.subtotal);

  void addToCart(Product product) {
    if (_cart.containsKey(product.id)) {
      _cart[product.id]!.quantity++;
    } else {
      _cart[product.id] = CartItem(product: product);
    }
    notifyListeners();
  }

  void decreaseFromCart(Product product) {
    final item = _cart[product.id];
    if (item == null) return;
    if (item.quantity <= 1) {
      _cart.remove(product.id);
    } else {
      item.quantity--;
    }
    notifyListeners();
  }

  int quantityOf(Product product) => _cart[product.id]?.quantity ?? 0;

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // --- Branding (white-label) ---
  void updateBranding({
    String? shopName,
    String? logoEmoji,
    Color? primaryColor,
    Color? secondaryColor,
    String? tagline,
    BannerTheme? bannerTheme,
    String? instagramUrl,
    String? facebookUrl,
    String? tiktokUrl,
    String? whatsappNumber,
    String? aiName,
    AiIconOption? aiIcon,
  }) {
    if (shopName != null) tenant.shopName = shopName;
    if (logoEmoji != null) tenant.logoEmoji = logoEmoji;
    if (primaryColor != null) tenant.primaryColor = primaryColor;
    if (secondaryColor != null) tenant.secondaryColor = secondaryColor;
    if (tagline != null) tenant.tagline = tagline;
    if (bannerTheme != null) tenant.bannerTheme = bannerTheme;
    if (instagramUrl != null) tenant.instagramUrl = instagramUrl;
    if (facebookUrl != null) tenant.facebookUrl = facebookUrl;
    if (tiktokUrl != null) tenant.tiktokUrl = tiktokUrl;
    if (whatsappNumber != null) tenant.whatsappNumber = whatsappNumber;
    if (aiName != null) tenant.aiName = aiName;
    if (aiIcon != null) tenant.aiIcon = aiIcon;
    notifyListeners();
  }

  // --- Asistente IA (para compradores) ---
  final List<ChatMessage> aiMessages = [];
  bool aiIsTyping = false;

  void ensureAiGreeting() {
    if (aiMessages.isNotEmpty) return;
    aiMessages.add(ChatMessage(
      fromUser: false,
      text: '¡Hola! Soy ${tenant.aiName} 👋 el asistente de '
          '${tenant.shopName.isEmpty ? "la tienda" : tenant.shopName}. '
          'Puedo ayudarte con precios, stock, ofertas o armar tu '
          'presupuesto con lo que llevas en el carrito.',
    ));
    notifyListeners();
  }

  void sendAiMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    aiMessages.add(ChatMessage(text: trimmed, fromUser: true));
    aiIsTyping = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 650), () {
      final reply = generateAiReply(trimmed, this);
      aiMessages.add(ChatMessage(text: reply, fromUser: false));
      aiIsTyping = false;
      notifyListeners();
    });
  }

  // --- Orders / tracking ---
  StoreOrder? currentOrder;
  Timer? _trackingTimer;

  StoreOrder placeOrder({
    required DeliveryMethod method,
    String? address,
    String? timeSlot,
  }) {
    final order = StoreOrder(
      id: 'OC-${100000 + DateTime.now().millisecond}',
      items: _cart.values
          .map((e) => CartItem(product: e.product, quantity: e.quantity))
          .toList(),
      method: method,
      total: cartTotal,
      address: address,
      timeSlot: timeSlot,
      pickupCode: method == DeliveryMethod.pickup
          ? (1000 + DateTime.now().second * 7 % 9000).toString()
          : null,
    );
    currentOrder = order;
    clearCart();
    _startTrackingSimulation();
    notifyListeners();
    return order;
  }

  void _startTrackingSimulation() {
    _trackingTimer?.cancel();
    _trackingTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      final order = currentOrder;
      if (order == null) {
        timer.cancel();
        return;
      }
      if (order.stage == OrderStage.preparando) {
        order.stage = OrderStage.enCamino;
      } else if (order.stage == OrderStage.enCamino) {
        order.stage = OrderStage.entregado;
        timer.cancel();
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _trackingTimer?.cancel();
    super.dispose();
  }
}
