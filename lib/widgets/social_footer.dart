import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/models.dart';

class SocialFooter extends StatelessWidget {
  const SocialFooter({super.key, required this.tenant});

  final TenantConfig tenant;

  @override
  Widget build(BuildContext context) {
    final links = <_SocialLink>[
      if (tenant.whatsappNumber.trim().isNotEmpty)
        _SocialLink(
          icon: FontAwesomeIcons.whatsapp,
          color: const Color(0xFF25D366),
          label: 'WhatsApp',
          url: 'https://wa.me/${_digitsOnly(tenant.whatsappNumber)}',
        ),
      if (tenant.instagramUrl.trim().isNotEmpty)
        _SocialLink(
          icon: FontAwesomeIcons.instagram,
          color: const Color(0xFFE1306C),
          label: 'Instagram',
          url: _asUrl(tenant.instagramUrl, 'instagram.com'),
        ),
      if (tenant.facebookUrl.trim().isNotEmpty)
        _SocialLink(
          icon: FontAwesomeIcons.facebook,
          color: const Color(0xFF1877F2),
          label: 'Facebook',
          url: _asUrl(tenant.facebookUrl, 'facebook.com'),
        ),
      if (tenant.tiktokUrl.trim().isNotEmpty)
        _SocialLink(
          icon: FontAwesomeIcons.tiktok,
          color: const Color(0xFF010101),
          label: 'TikTok',
          url: _asUrl(tenant.tiktokUrl, 'tiktok.com'),
        ),
    ];

    if (links.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text('Síguenos',
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 14,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: links.map((l) => _SocialButton(link: l)).toList(),
          ),
        ],
      ),
    );
  }

  String _digitsOnly(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');

  String _asUrl(String value, String domainHint) {
    final v = value.trim();
    if (v.startsWith('http://') || v.startsWith('https://')) return v;
    if (v.startsWith('@')) return 'https://$domainHint/${v.substring(1)}';
    return 'https://$domainHint/$v';
  }
}

class _SocialLink {
  _SocialLink({
    required this.icon,
    required this.color,
    required this.label,
    required this.url,
  });

  final FaIconData icon;
  final Color color;
  final String label;
  final String url;
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.link});

  final _SocialLink link;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: () => launchUrl(Uri.parse(link.url),
          mode: LaunchMode.externalApplication),
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: link.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: FaIcon(link.icon, color: link.color, size: 20),
          ),
          const SizedBox(height: 6),
          Text(link.label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}
