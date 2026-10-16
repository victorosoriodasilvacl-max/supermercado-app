import '../models/models.dart';
import '../state/app_state.dart';
import '../utils/format.dart';

/// Motor de respuestas del asistente para la demo: reglas locales sobre el
/// stock y el carrito reales de la app (sin llamar a ningún servicio
/// externo). Pensado para quedar como el "cerebro" temporal mientras se
/// conecta un modelo real (ej. Gemini Flash) desde un backend más adelante
/// — nunca con la API key en el cliente, por seguridad.
String generateAiReply(String userText, AppState app) {
  final text = _normalize(userText);
  final tenant = app.tenant;

  if (text.isEmpty) {
    return '¿En qué te puedo ayudar? Pregúntame por precios, stock, ofertas '
        'o pídeme que arme tu presupuesto.';
  }

  if (_matchesAny(text, ['hola', 'buenas', 'buenos dias', 'buenas tardes'])) {
    return '¡Hola! Soy ${tenant.aiName}, el asistente de '
        '${tenant.shopName.isEmpty ? "la tienda" : tenant.shopName}. '
        'Puedo ayudarte a revisar precios, stock, ofertas del día o armar '
        'tu presupuesto con lo que llevas en el carrito.';
  }

  if (_matchesAny(text, ['gracias'])) {
    return '¡De nada! Si necesitas algo más, aquí estoy.';
  }

  if (_matchesAny(
      text, ['presupuesto', 'cotizacion', 'cotizar', 'cuanto saldria', 'total del carrito'])) {
    return _buildQuote(app);
  }

  if (_matchesAny(text, ['oferta', 'descuento', 'promocion', 'rebaja'])) {
    final onSale = app.products.where((p) => p.isOnSale).toList();
    if (onSale.isEmpty) {
      return 'Por ahora no tenemos productos marcados en oferta, pero '
          'pregúntame por cualquier producto y te digo su precio.';
    }
    final lines = onSale.take(6).map((p) =>
        '• ${p.name}: ${formatCLP(p.price)} (antes ${formatCLP(p.oldPrice!)})');
    return 'Estas son nuestras ofertas del momento:\n${lines.join('\n')}';
  }

  final matchedProduct = _findProduct(app, text);
  if (matchedProduct != null) {
    final stockLine = matchedProduct.isOnSale
        ? '${formatCLP(matchedProduct.price)} (antes ${formatCLP(matchedProduct.oldPrice!)}, en oferta 🏷️)'
        : formatCLP(matchedProduct.price);
    return 'Sí, tenemos "${matchedProduct.name}" disponible a $stockLine '
        'por ${matchedProduct.unit}.'
        '${matchedProduct.description.isNotEmpty ? "\n${matchedProduct.description}" : ""}';
  }

  if (_matchesAny(text, ['stock', 'tienen', 'hay', 'disponible'])) {
    final cats = categoryIcons.keys.join(', ');
    return 'Tenemos stock en estas categorías: $cats. Dime el nombre de un '
        'producto puntual y te confirmo precio y disponibilidad.';
  }

  if (_matchesAny(text, ['delivery', 'despacho', 'envio', 'llega'])) {
    return 'Hacemos delivery a domicilio o puedes retirar en tienda. Eso se '
        'elige al momento de confirmar tu pedido en el checkout.';
  }

  if (_matchesAny(text, ['horario', 'abierto', 'hora'])) {
    return 'Puedes hacer tu pedido en la app a cualquier hora; el horario de '
        'despacho/retiro se confirma en el paso de checkout.';
  }

  return 'No estoy seguro de haber entendido 🙂. Puedo ayudarte con precios, '
      'stock, ofertas o armar tu presupuesto con el carrito. ¿Qué producto '
      'buscas?';
}

String _buildQuote(AppState app) {
  if (app.cartItems.isEmpty) {
    return 'Tu carrito está vacío todavía. Agrega los productos que quieras '
        'cotizar desde el catálogo y vuelve a preguntarme "arma mi '
        'presupuesto".';
  }
  final buffer = StringBuffer('Este es tu presupuesto con el stock actual:\n');
  for (final item in app.cartItems) {
    final p = item.product;
    buffer.writeln(
        '• ${item.quantity}x ${p.name}${p.isOnSale ? " (oferta)" : ""} — ${formatCLP(item.subtotal)}');
  }
  buffer.write('\nTotal estimado: ${formatCLP(app.cartTotal)}');
  return buffer.toString();
}

Product? _findProduct(AppState app, String normalizedText) {
  for (final product in app.products) {
    final productName = _normalize(product.name);
    if (normalizedText.contains(productName) ||
        productName.split(' ').any((word) =>
            word.length > 3 && normalizedText.contains(word))) {
      return product;
    }
  }
  return null;
}

bool _matchesAny(String text, List<String> keywords) =>
    keywords.any((k) => text.contains(k));

String _normalize(String input) {
  var result = input.toLowerCase().trim();
  const accents = {
    'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ñ': 'n',
  };
  accents.forEach((accented, plain) {
    result = result.replaceAll(accented, plain);
  });
  return result;
}
