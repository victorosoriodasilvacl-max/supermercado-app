import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../utils/format.dart';
import '../widgets/product_thumbnail.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final tenant = app.tenant;
    final items = app.cartItems;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        title: const Text('Tu carrito'),
        backgroundColor: tenant.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text('Tu carrito está vacío'),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final item = items[i];
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 56,
                        height: 56,
                        child: ProductThumbnail(
                          product: item.product,
                          borderRadius: 10,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.product.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            Text(
                              '${formatCLP(item.product.price)} / ${item.product.unit}',
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove_circle_outline,
                                color: tenant.primaryColor),
                            onPressed: () =>
                                app.decreaseFromCart(item.product),
                          ),
                          Text('${item.quantity}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: Icon(Icons.add_circle_outline,
                                color: tenant.primaryColor),
                            onPressed: () => app.addToCart(item.product),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: items.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        Text(
                          formatCLP(app.cartTotal),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: tenant.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tenant.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const CheckoutScreen()),
                        ),
                        child: const Text('Confirmar pedido'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
