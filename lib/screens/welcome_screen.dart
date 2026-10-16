import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import 'catalog_screen.dart';

/// Pantalla de bienvenida / inicio de sesión. Hoy es una demo (acepta
/// cualquier usuario y clave); en producción esto se reemplaza por
/// autenticación real con token para evitar que cualquiera cambie precios.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _enter() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const CatalogScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final tenant = app.tenant;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (app.welcomeBackgroundBytes != null)
            Image.memory(app.welcomeBackgroundBytes!, fit: BoxFit.cover)
          else
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [tenant.primaryColor, tenant.secondaryColor],
                ),
              ),
            ),
          Container(color: Colors.black.withValues(alpha: 0.38)),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      clipBehavior: Clip.antiAlias,
                      child: app.logoImageBytes != null
                          ? Image.memory(app.logoImageBytes!, fit: BoxFit.cover)
                          : Text(tenant.logoEmoji,
                              style: const TextStyle(fontSize: 42)),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      tenant.shopName.isEmpty
                          ? 'Nombre de tu tienda'
                          : tenant.shopName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tenant.tagline,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 36),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.96),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _userCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Usuario',
                              prefixIcon: Icon(Icons.person_outline),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _passCtrl,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                              border: const OutlineInputBorder(),
                            ),
                            onSubmitted: (_) => _enter(),
                          ),
                          const SizedBox(height: 18),
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
                              onPressed: _enter,
                              child: const Text('Ingresar'),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Demo: cualquier usuario/clave funciona.\n'
                            'En producción se valida con token.',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
