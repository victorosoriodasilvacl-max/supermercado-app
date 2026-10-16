import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../utils/format.dart';
import '../widgets/product_thumbnail.dart';

/// Panel de control del cliente: una sección por categoría, con sus
/// productos y un recuadro "+" para agregar uno nuevo. Sin límite de
/// productos ni de fotos.
class ProductPhotosScreen extends StatelessWidget {
  const ProductPhotosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final tenant = app.tenant;
    final sections = categories.where((c) => c != 'Todos').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        title: const Text('Panel de productos'),
        backgroundColor: tenant.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Cada sección es de tu tienda. Agrega los productos que quieras: '
            'nombre, precio, foto, descripción y si está en oferta.',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
          const SizedBox(height: 16),
          for (final category in sections)
            _CategorySection(
              category: category,
              products: app.products.where((p) => p.category == category).toList(),
            ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({required this.category, required this.products});

  final String category;
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    final color = categoryColors[category] ?? Colors.grey;
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(category,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              const Spacer(),
              Text('${products.length} producto(s)',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final product in products)
                _ProductTile(
                  product: product,
                  onTap: () => showProductFormSheet(
                    context,
                    category: category,
                    existing: product,
                  ),
                ),
              _AddTile(
                color: color,
                onTap: () => showProductFormSheet(context, category: category),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 108,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: ProductThumbnail(product: product),
                ),
                if (product.isOnSale)
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: context.read<AppState>().tenant.secondaryColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('OFERTA',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(formatCLP(product.price),
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if (product.isOnSale)
                    Text(
                      formatCLP(product.oldPrice!),
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey.shade500,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.color, required this.onTap});

  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 108,
        height: 108 + 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: 0.5),
            width: 1.4,
            style: BorderStyle.solid,
          ),
          color: color.withValues(alpha: 0.05),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_photo_alternate_rounded, color: color, size: 28),
            const SizedBox(height: 6),
            Text('Agregar\nproducto',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 11, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

/// Formulario de alta/edición de producto: foto, nombre, descripción,
/// precio y oferta. Se reutiliza tanto para "Agregar" como para editar.
void showProductFormSheet(
  BuildContext context, {
  required String category,
  Product? existing,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => _ProductForm(category: category, existing: existing),
  );
}

class _ProductForm extends StatefulWidget {
  const _ProductForm({required this.category, this.existing});

  final String category;
  final Product? existing;

  @override
  State<_ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<_ProductForm> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _oldPriceCtrl;
  late final TextEditingController _unitCtrl;
  late bool _onSale;
  Uint8List? _stagedImage;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _priceCtrl = TextEditingController(text: p != null ? '${p.price}' : '');
    _oldPriceCtrl =
        TextEditingController(text: p?.oldPrice != null ? '${p!.oldPrice}' : '');
    _unitCtrl = TextEditingController(text: p?.unit ?? 'un');
    _onSale = p?.isOnSale ?? false;
    if (p != null) {
      _stagedImage = context.read<AppState>().productImages[p.id];
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _oldPriceCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() => _stagedImage = bytes);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final tenant = app.tenant;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _isEditing
                        ? 'Editar producto'
                        : 'Nuevo producto · ${widget.category}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if (_isEditing)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Eliminar producto',
                    onPressed: () {
                      app.removeProduct(widget.existing!);
                      Navigator.of(context).pop();
                    },
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // Drop-zone de la foto.
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _pickImage,
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: tenant.primaryColor.withValues(alpha: 0.05),
                  border: Border.all(
                    color: tenant.primaryColor.withValues(alpha: 0.4),
                    width: 1.4,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: _stagedImage != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.memory(_stagedImage!, fit: BoxFit.cover),
                          Positioned(
                            right: 6,
                            top: 6,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.black54,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.close,
                                    size: 14, color: Colors.white),
                                onPressed: () =>
                                    setState(() => _stagedImage = null),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload_outlined,
                              color: tenant.primaryColor, size: 30),
                          const SizedBox(height: 6),
                          Text('Arrastra o toca para subir la foto',
                              style: TextStyle(
                                  fontSize: 12, color: tenant.primaryColor)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre del producto',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Precio (CLP)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 90,
                  child: TextField(
                    controller: _unitCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Unidad',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeThumbColor: tenant.secondaryColor,
              title: const Text('¿Está en oferta?'),
              value: _onSale,
              onChanged: (v) => setState(() => _onSale = v),
            ),
            if (_onSale) ...[
              TextField(
                controller: _oldPriceCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Precio anterior (antes de la oferta)',
                  border: const OutlineInputBorder(),
                  helperText:
                      'Se mostrará tachado, con la etiqueta OFERTA en ${_hex(tenant.secondaryColor)}',
                ),
              ),
              const SizedBox(height: 8),
            ],
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
                onPressed: () => _save(context),
                child: Text(_isEditing ? 'Guardar cambios' : 'Agregar al catálogo'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _hex(Color c) =>
      '#${c.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

  void _save(BuildContext context) {
    final app = context.read<AppState>();
    final name = _nameCtrl.text.trim();
    final price = int.tryParse(_priceCtrl.text.trim());
    if (name.isEmpty || price == null) return;

    int? oldPrice;
    if (_onSale) {
      oldPrice = int.tryParse(_oldPriceCtrl.text.trim());
      if (oldPrice == null || oldPrice <= price) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'El precio anterior debe ser mayor que el precio actual.'),
        ));
        return;
      }
    }

    final unit = _unitCtrl.text.trim().isEmpty ? 'un' : _unitCtrl.text.trim();

    if (_isEditing) {
      app.updateProduct(
        widget.existing!,
        name: name,
        price: price,
        unit: unit,
        description: _descCtrl.text.trim(),
        oldPrice: oldPrice,
        clearOldPrice: !_onSale,
      );
      if (_stagedImage != null) {
        app.setProductImage(widget.existing!.id, _stagedImage!);
      } else {
        app.removeProductImage(widget.existing!.id);
      }
    } else {
      final product = Product(
        id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        category: widget.category,
        price: price,
        unit: unit,
        oldPrice: oldPrice,
        description: _descCtrl.text.trim(),
      );
      app.addProduct(product);
      if (_stagedImage != null) {
        app.setProductImage(product.id, _stagedImage!);
      }
    }
    Navigator.of(context).pop();
  }
}
