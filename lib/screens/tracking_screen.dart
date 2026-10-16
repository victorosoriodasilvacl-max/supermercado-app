import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../utils/format.dart';
import 'catalog_screen.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key, required this.order});

  final StoreOrder order;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final tenant = app.tenant;
    final isPickup = order.method == DeliveryMethod.pickup;

    final steps = isPickup
        ? const ['Preparando', 'Listo para retiro']
        : const ['Preparando', 'En camino', 'Entregado'];

    final stageIndex = switch (order.stage) {
      OrderStage.preparando => 0,
      OrderStage.enCamino => 1,
      OrderStage.entregado => steps.length - 1,
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        title: const Text('Seguimiento de pedido'),
        backgroundColor: tenant.primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: tenant.primaryColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pedido ${order.id}',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 6),
                Text(
                  isPickup && order.pickupCode != null
                      ? 'Código de retiro: ${order.pickupCode}'
                      : (order.address ?? ''),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                if (!isPickup && order.timeSlot != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('Horario: ${order.timeSlot}',
                        style: const TextStyle(color: Colors.white70)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          ...List.generate(steps.length, (i) {
            final done = i <= stageIndex;
            final isLast = i == steps.length - 1;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: done ? tenant.primaryColor : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        done ? Icons.check : Icons.circle,
                        color: Colors.white,
                        size: done ? 16 : 8,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 44,
                        color: i < stageIndex
                            ? tenant.primaryColor
                            : Colors.grey.shade300,
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    steps[i],
                    style: TextStyle(
                      fontWeight: done ? FontWeight.bold : FontWeight.normal,
                      color: done ? Colors.black87 : Colors.grey,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 20),
          if (order.stage != OrderStage.entregado)
            Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: tenant.primaryColor,
                  ),
                ),
                const SizedBox(width: 10),
                Text('Actualizando estado en tiempo real...',
                    style: TextStyle(color: Colors.grey.shade600)),
              ],
            )
          else
            Row(
              children: [
                const Icon(Icons.celebration, color: Colors.amber),
                const SizedBox(width: 10),
                const Expanded(
                    child: Text('¡Tu pedido fue entregado con éxito!')),
              ],
            ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Resumen del pedido',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Text(
                                  '${item.quantity}x ${item.product.name}')),
                          Text(formatCLP(item.subtotal)),
                        ],
                      ),
                    )),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(formatCLP(order.total),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: tenant.primaryColor)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: tenant.primaryColor,
                side: BorderSide(color: tenant.primaryColor),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const CatalogScreen()),
                (route) => false,
              ),
              child: const Text('Volver a la tienda'),
            ),
          ),
        ],
      ),
    );
  }
}
