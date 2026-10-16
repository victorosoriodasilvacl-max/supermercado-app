import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../utils/format.dart';
import 'tracking_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

enum _Step { method, details, payment }

class _CheckoutScreenState extends State<CheckoutScreen> {
  _Step _step = _Step.method;
  DeliveryMethod? _method;

  final _addressCtrl = TextEditingController();
  String? _timeSlot;
  String? _paymentOption;

  final _timeSlots = const [
    '10:00 - 12:00',
    '12:00 - 14:00',
    '16:00 - 18:00',
    '18:00 - 20:00',
  ];

  final _paymentOptions = const [
    ('card', 'Tarjeta de crédito/débito', Icons.credit_card),
    ('mercadopago', 'MercadoPago', Icons.account_balance_wallet),
    ('cash', 'Efectivo contra entrega', Icons.payments_outlined),
  ];

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final tenant = app.tenant;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        title: Text(_titleFor(_step)),
        backgroundColor: tenant.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildStep(context, app),
      ),
    );
  }

  String _titleFor(_Step step) {
    switch (step) {
      case _Step.method:
        return '¿Cómo recibirlo?';
      case _Step.details:
        return _method == DeliveryMethod.delivery
            ? 'Dirección y horario'
            : 'Retiro en tienda';
      case _Step.payment:
        return 'Medio de pago';
    }
  }

  Widget _buildStep(BuildContext context, AppState app) {
    final tenant = app.tenant;
    switch (_step) {
      case _Step.method:
        return Column(
          children: [
            _methodCard(
              icon: Icons.delivery_dining,
              title: 'Delivery',
              subtitle: 'Te lo llevamos a tu domicilio',
              color: tenant.primaryColor,
              onTap: () => setState(() {
                _method = DeliveryMethod.delivery;
                _step = _Step.details;
              }),
            ),
            const SizedBox(height: 12),
            _methodCard(
              icon: Icons.storefront,
              title: 'Retiro en tienda',
              subtitle: 'Retira tu pedido cuando quieras',
              color: tenant.secondaryColor,
              onTap: () => setState(() {
                _method = DeliveryMethod.pickup;
                _step = _Step.payment;
              }),
            ),
          ],
        );
      case _Step.details:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dirección de entrega',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _addressCtrl,
              decoration: InputDecoration(
                hintText: 'Calle, número, depto, comuna',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Franja horaria',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _timeSlots.map((slot) {
                final selected = slot == _timeSlot;
                return ChoiceChip(
                  label: Text(slot),
                  selected: selected,
                  selectedColor: tenant.primaryColor,
                  labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black87),
                  onSelected: (_) => setState(() => _timeSlot = slot),
                );
              }).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: tenant.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: (_addressCtrl.text.trim().isEmpty || _timeSlot == null)
                    ? null
                    : () => setState(() => _step = _Step.payment),
                child: const Text('Continuar'),
              ),
            ),
          ],
        );
      case _Step.payment:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._paymentOptions.map((opt) {
              final (value, label, icon) = opt;
              final selected = value == _paymentOption;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => _paymentOption = value),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? tenant.primaryColor
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(icon, color: tenant.primaryColor),
                        const SizedBox(width: 12),
                        Expanded(child: Text(label)),
                        if (selected)
                          Icon(Icons.check_circle, color: tenant.primaryColor),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total a pagar',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    formatCLP(app.cartTotal),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: tenant.primaryColor,
                    ),
                  ),
                ],
              ),
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
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _paymentOption == null
                    ? null
                    : () {
                        final order = app.placeOrder(
                          method: _method!,
                          address: _method == DeliveryMethod.delivery
                              ? _addressCtrl.text.trim()
                              : null,
                          timeSlot: _method == DeliveryMethod.delivery
                              ? _timeSlot
                              : null,
                        );
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => TrackingScreen(order: order),
                          ),
                          (route) => route.isFirst,
                        );
                      },
                child: const Text('Confirmar y pagar'),
              ),
            ),
          ],
        );
    }
  }

  Widget _methodCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
