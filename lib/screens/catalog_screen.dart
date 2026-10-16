import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/ai_chat_sheet.dart';
import '../widgets/product_card.dart';
import '../widgets/social_footer.dart';
import 'branding_screen.dart';
import 'cart_screen.dart';
import 'product_photos_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String _selectedCategory = 'Todos';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final tenant = app.tenant;

    final filtered = app.products.where((p) {
      final matchesCategory =
          _selectedCategory == 'Todos' || p.category == _selectedCategory;
      final matchesQuery =
          _query.isEmpty || p.name.toLowerCase().contains(_query.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();

    final hasPageBackground = app.pageBackgroundBytes != null;

    return Scaffold(
      backgroundColor:
          hasPageBackground ? Colors.transparent : const Color(0xFFF6F7F9),
      body: Stack(
        children: [
          if (hasPageBackground)
            Positioned.fill(
              child: Image.memory(app.pageBackgroundBytes!, fit: BoxFit.cover),
            ),
          _buildContent(context, app, tenant, filtered),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AiChatButton(),
          if (app.cartCount > 0) ...[
            const SizedBox(height: 12),
            FloatingActionButton.extended(
              backgroundColor: tenant.primaryColor,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CartScreen()),
              ),
              icon: const Icon(Icons.shopping_cart),
              label: Text('Ver carrito (${app.cartCount})'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppState app, TenantConfig tenant,
      List<Product> filtered) {
    return CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 190,
            backgroundColor: tenant.primaryColor,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.add_a_photo_outlined),
                tooltip: 'Fotos y productos',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const ProductPhotosScreen()),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.palette_outlined),
                tooltip: 'Personalizar marca',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BrandingScreen()),
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    ),
                  ),
                  if (app.cartCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: tenant.secondaryColor,
                          shape: BoxShape.circle,
                        ),
                        constraints:
                            const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '${app.cartCount}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [tenant.primaryColor, tenant.secondaryColor],
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (app.bannerImageBytes != null)
                      Image.memory(app.bannerImageBytes!, fit: BoxFit.cover)
                    else
                      Positioned(
                        right: -20,
                        bottom: -20,
                        child: Icon(
                          tenant.bannerTheme.icon,
                          size: 170,
                          color: Colors.white.withValues(alpha: 0.14),
                        ),
                      ),
                    // Oscurece/funde la parte baja de la portada para que el
                    // buscador "flote" por encima, como una ilusión continua.
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.05),
                              tenant.primaryColor.withValues(alpha: 0.55),
                            ],
                            stops: const [0.4, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 50, 16, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                clipBehavior: Clip.antiAlias,
                                child: app.logoImageBytes != null
                                    ? Image.memory(app.logoImageBytes!,
                                        fit: BoxFit.cover)
                                    : Text(tenant.logoEmoji,
                                        style: const TextStyle(fontSize: 30)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  tenant.shopName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 68),
                            child: Text(
                              tenant.tagline,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -14),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(14),
                  shadowColor: Colors.black26,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar productos...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final cat = categories[i];
                  final selected = cat == _selectedCategory;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                    selectedColor: tenant.primaryColor,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                      fontSize: 12,
                    ),
                    backgroundColor: Colors.white,
                  );
                },
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: filtered.isEmpty
                ? const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(child: Text('Sin resultados')),
                    ),
                  )
                : SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 190,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.62,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => ProductCard(product: filtered[i]),
                      childCount: filtered.length,
                    ),
                  ),
          ),
          SliverToBoxAdapter(child: SocialFooter(tenant: tenant)),
        ],
      );
  }
}
