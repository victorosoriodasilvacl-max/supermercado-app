import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../state/app_state.dart';

class BrandingScreen extends StatefulWidget {
  const BrandingScreen({super.key});

  @override
  State<BrandingScreen> createState() => _BrandingScreenState();
}

const _presetColors = [
  Color(0xFF2E7D32), // verde
  Color(0xFF1565C0), // azul
  Color(0xFFC62828), // rojo
  Color(0xFF6A1B9A), // morado
  Color(0xFFEF6C00), // naranja
  Color(0xFF00838F), // turquesa
  Color(0xFF283593), // índigo
  Color(0xFF2E2E2E), // negro
];

const _secondaryColors = [
  Color(0xFFFFA000),
  Color(0xFFFFD54F),
  Color(0xFF00C853),
  Color(0xFFFF5252),
  Color(0xFF40C4FF),
  Color(0xFFE040FB),
];

const _emojiOptions = [
  '🛒', '🥦', '🍎', '🧺', '🏪', '🥑', '🍞', '🥕',
];

class _BrandingScreenState extends State<BrandingScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _taglineCtrl;
  late final TextEditingController _instagramCtrl;
  late final TextEditingController _facebookCtrl;
  late final TextEditingController _tiktokCtrl;
  late final TextEditingController _whatsappCtrl;
  late final TextEditingController _aiNameCtrl;

  @override
  void initState() {
    super.initState();
    final tenant = context.read<AppState>().tenant;
    _nameCtrl = TextEditingController(text: tenant.shopName);
    _taglineCtrl = TextEditingController(text: tenant.tagline);
    _instagramCtrl = TextEditingController(text: tenant.instagramUrl);
    _facebookCtrl = TextEditingController(text: tenant.facebookUrl);
    _tiktokCtrl = TextEditingController(text: tenant.tiktokUrl);
    _whatsappCtrl = TextEditingController(text: tenant.whatsappNumber);
    _aiNameCtrl = TextEditingController(text: tenant.aiName);
  }

  Future<void> _pickLogo() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      imageQuality: 90,
    );
    if (file == null || !mounted) return;
    context.read<AppState>().setLogoImage(await file.readAsBytes());
  }

  Future<void> _pickBanner() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;
    context.read<AppState>().setBannerImage(await file.readAsBytes());
  }

  Future<void> _pickPageBackground() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 80,
    );
    if (file == null || !mounted) return;
    context.read<AppState>().setPageBackground(await file.readAsBytes());
  }

  Future<void> _pickWelcomeBackground() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 80,
    );
    if (file == null || !mounted) return;
    context.read<AppState>().setWelcomeBackground(await file.readAsBytes());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _taglineCtrl.dispose();
    _instagramCtrl.dispose();
    _facebookCtrl.dispose();
    _tiktokCtrl.dispose();
    _whatsappCtrl.dispose();
    _aiNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final tenant = app.tenant;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        title: const Text('Personaliza tu tienda'),
        backgroundColor: tenant.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Live preview
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [tenant.primaryColor, tenant.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  clipBehavior: Clip.antiAlias,
                  child: app.logoImageBytes != null
                      ? Image.memory(app.logoImageBytes!, fit: BoxFit.cover)
                      : Text(tenant.logoEmoji,
                          style: const TextStyle(fontSize: 26)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tenant.shopName.isEmpty ? 'Nombre de tu tienda' : tenant.shopName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        tenant.tagline,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const _SectionLabel('Nombre de la tienda'),
          TextField(
            controller: _nameCtrl,
            decoration: _inputDecoration('Ej: Mercado Don José'),
            onChanged: (v) => app.updateBranding(shopName: v),
          ),
          const SizedBox(height: 18),

          const _SectionLabel('Frase / eslogan'),
          TextField(
            controller: _taglineCtrl,
            decoration: _inputDecoration('Ej: Frescura todos los días'),
            onChanged: (v) => app.updateBranding(tagline: v),
          ),
          const SizedBox(height: 18),

          const _SectionLabel('Logo'),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _pickLogo,
                icon: const Icon(Icons.upload_rounded, size: 18),
                label: const Text('Subir desde el computador'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: tenant.primaryColor,
                  side: BorderSide(color: tenant.primaryColor),
                ),
              ),
              if (app.logoImageBytes != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  tooltip: 'Quitar foto',
                  onPressed: () => app.clearLogoImage(),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text('o elige un ícono rápido:',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _emojiOptions.map((emoji) {
              final selected =
                  emoji == tenant.logoEmoji && app.logoImageBytes == null;
              return InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  app.clearLogoImage();
                  app.updateBranding(logoEmoji: emoji);
                },
                child: Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? tenant.primaryColor : Colors.grey.shade300,
                      width: selected ? 2.5 : 1,
                    ),
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 22)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),

          const _SectionLabel('Imagen de portada'),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _pickBanner,
                icon: const Icon(Icons.upload_rounded, size: 18),
                label: const Text('Subir desde el computador'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: tenant.primaryColor,
                  side: BorderSide(color: tenant.primaryColor),
                ),
              ),
              if (app.bannerImageBytes != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  tooltip: 'Quitar foto',
                  onPressed: () => app.clearBannerImage(),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text('o elige un tema de supermercado:',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: BannerTheme.values.map((theme) {
              final selected =
                  theme == tenant.bannerTheme && app.bannerImageBytes == null;
              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  app.clearBannerImage();
                  app.updateBranding(bannerTheme: theme);
                },
                child: Container(
                  width: 84,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected ? tenant.primaryColor : Colors.grey.shade300,
                      width: selected ? 2.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(theme.icon, color: tenant.primaryColor),
                      const SizedBox(height: 6),
                      Text(theme.label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),

          const _SectionLabel('Fondo de toda la página'),
          Text(
            'Una imagen que cubre todo el fondo de la tienda (detrás de las '
            'tarjetas de producto). 100% opcional.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _pickPageBackground,
                icon: const Icon(Icons.upload_rounded, size: 18),
                label: const Text('Subir fondo de página'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: tenant.primaryColor,
                  side: BorderSide(color: tenant.primaryColor),
                ),
              ),
              if (app.pageBackgroundBytes != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  tooltip: 'Quitar fondo',
                  onPressed: () => app.clearPageBackground(),
                ),
              ],
            ],
          ),
          if (app.pageBackgroundBytes != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(app.pageBackgroundBytes!,
                  height: 90, width: double.infinity, fit: BoxFit.cover),
            ),
          ],
          const SizedBox(height: 18),

          const _SectionLabel('Pantalla de bienvenida (inicio de sesión)'),
          Text(
            'La primera pantalla que ve quien administra la tienda. Puedes '
            'subir una foto, un diseño hecho con IA o lo que prefieras.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _pickWelcomeBackground,
                icon: const Icon(Icons.upload_rounded, size: 18),
                label: const Text('Subir imagen de bienvenida'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: tenant.primaryColor,
                  side: BorderSide(color: tenant.primaryColor),
                ),
              ),
              if (app.welcomeBackgroundBytes != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  tooltip: 'Quitar imagen',
                  onPressed: () => app.clearWelcomeBackground(),
                ),
              ],
            ],
          ),
          if (app.welcomeBackgroundBytes != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(app.welcomeBackgroundBytes!,
                  height: 90, width: double.infinity, fit: BoxFit.cover),
            ),
          ],
          const SizedBox(height: 18),

          const _SectionLabel('Color principal'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _presetColors
                .map((c) => _ColorDot(
                      color: c,
                      selected: c.toARGB32() == tenant.primaryColor.toARGB32(),
                      onTap: () => app.updateBranding(primaryColor: c),
                    ))
                .toList(),
          ),
          const SizedBox(height: 18),

          const _SectionLabel('Color secundario / acentos'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _secondaryColors
                .map((c) => _ColorDot(
                      color: c,
                      selected: c.toARGB32() == tenant.secondaryColor.toARGB32(),
                      onTap: () => app.updateBranding(secondaryColor: c),
                    ))
                .toList(),
          ),
          const SizedBox(height: 18),

          const _SectionLabel('Asistente de IA para tus clientes'),
          Text(
            'Responde preguntas de stock, ofertas y arma presupuestos con el '
            'carrito del comprador.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _aiNameCtrl,
            decoration: _inputDecoration('Nombre de la IA (ej: AI Market)'),
            onChanged: (v) => app.updateBranding(aiName: v),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: AiIconOption.values.map((opt) {
              final selected = opt == tenant.aiIcon;
              return InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () => app.updateBranding(aiIcon: opt),
                child: Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? tenant.primaryColor : Colors.grey.shade300,
                      width: selected ? 2.5 : 1,
                    ),
                  ),
                  child: Icon(opt.icon,
                      color: selected ? tenant.primaryColor : Colors.grey.shade600),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),

          const _SectionLabel('Redes sociales (hasta 3) y WhatsApp'),
          TextField(
            controller: _instagramCtrl,
            decoration: _inputDecoration('Instagram: @tu_usuario o link')
                .copyWith(
                    prefixIcon: const Padding(
              padding: EdgeInsets.all(12),
              child: FaIcon(FontAwesomeIcons.instagram,
                  size: 18, color: Color(0xFFE1306C)),
            )),
            onChanged: (v) => app.updateBranding(instagramUrl: v),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _facebookCtrl,
            decoration: _inputDecoration('Facebook: usuario o link').copyWith(
                prefixIcon: const Padding(
              padding: EdgeInsets.all(12),
              child: FaIcon(FontAwesomeIcons.facebook,
                  size: 18, color: Color(0xFF1877F2)),
            )),
            onChanged: (v) => app.updateBranding(facebookUrl: v),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _tiktokCtrl,
            decoration: _inputDecoration('TikTok: @tu_usuario o link').copyWith(
                prefixIcon: const Padding(
              padding: EdgeInsets.all(12),
              child: FaIcon(FontAwesomeIcons.tiktok,
                  size: 18, color: Color(0xFF010101)),
            )),
            onChanged: (v) => app.updateBranding(tiktokUrl: v),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _whatsappCtrl,
            keyboardType: TextInputType.phone,
            decoration: _inputDecoration('WhatsApp: +56 9 1234 5678').copyWith(
                prefixIcon: const Padding(
              padding: EdgeInsets.all(12),
              child: FaIcon(FontAwesomeIcons.whatsapp,
                  size: 18, color: Color(0xFF25D366)),
            )),
            onChanged: (v) => app.updateBranding(whatsappNumber: v),
          ),
          const SizedBox(height: 28),

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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Listo'),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? Colors.black87 : Colors.transparent,
            width: 2.5,
          ),
        ),
        child: selected
            ? const Icon(Icons.check, color: Colors.white, size: 18)
            : null,
      ),
    );
  }
}
