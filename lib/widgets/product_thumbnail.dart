import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../state/app_state.dart';

/// Foto del producto: muestra la imagen subida por el cliente si existe,
/// o un marcador con el ícono de la categoría mientras tanto.
class ProductThumbnail extends StatelessWidget {
  const ProductThumbnail({
    super.key,
    required this.product,
    this.borderRadius = 0,
  });

  final Product product;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final bytes = context.select<AppState, Uint8List?>(
        (app) => app.productImages[product.id]);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: bytes == null
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    product.color.withValues(alpha: 0.16),
                    product.color.withValues(alpha: 0.06),
                  ],
                ),
              ),
              alignment: Alignment.center,
              child: Icon(product.icon, color: product.color, size: 36),
            )
          : Image.memory(bytes, fit: BoxFit.cover),
    );
  }
}
