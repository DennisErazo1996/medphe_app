import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _appVersion = '1.0.0';
  static const _contactEmail = 'contacto@medphe.com';
  static const _promoUrl = 'https://medphe.com/para-medicos';
  static const _privacyUrl = 'https://medphe.com/privacidad';

  Future<void> _launchEmail() async {
    final uri = Uri(scheme: 'mailto', path: _contactEmail);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _launchWhatsapp() async {
    const number = '50499999999';
    final uri = Uri.parse(
      'https://wa.me/$number?text=Hola,%20necesito%20ayuda%20con%20Medphe',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(child: _ProfileHeader()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 140),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _PromoCard(onTap: () => _launchUrl(_promoUrl)),
                const SizedBox(height: 20),
                const _SectionLabel(label: 'Soporte'),
                const SizedBox(height: 10),
                _OptionTile(
                  icon: Icons.chat_bubble_outline_rounded,
                  iconColor: const Color(0xFF25D366),
                  label: 'Escr\u00edbenos por WhatsApp',
                  onTap: _launchWhatsapp,
                ),
                const SizedBox(height: 8),
                _OptionTile(
                  icon: Icons.mail_outline_rounded,
                  iconColor: kMedphePrimary,
                  label: 'Contacto por correo',
                  subtitle: _contactEmail,
                  onTap: _launchEmail,
                ),
                const SizedBox(height: 20),
                const _SectionLabel(label: 'Legal'),
                const SizedBox(height: 10),
                _OptionTile(
                  icon: Icons.shield_outlined,
                  iconColor: kMedpheSecondary,
                  label: 'Pol\u00edtica de privacidad',
                  onTap: () => _launchUrl(_privacyUrl),
                ),
                const SizedBox(height: 8),
                _OptionTile(
                  icon: Icons.description_outlined,
                  iconColor: kMedpheSecondary,
                  label: 'T\u00e9rminos y condiciones',
                  onTap: () => _launchUrl('https://medphe.com/terminos'),
                ),
                const SizedBox(height: 32),
                const _AppVersionBadge(version: _appVersion),
                const SizedBox(height: 16),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mi perfil',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Configuraci\u00f3n y m\u00e1s',
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(24),
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [kMedpheSecondary, kMedphePrimary],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 18, 22),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'Para m\u00e9dicos',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Promociona tu\nperfil m\u00e9dico',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Conecta con pacientes y haz\ncrecer tu pr\u00e1ctica m\u00e9dica',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Saber m\u00e1s',
                              style: GoogleFonts.poppins(
                                color: kMedphePrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_rounded, size: 14, color: kMedphePrimary),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_hospital_rounded, size: 36, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 21),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        subtitle!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.black26, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _AppVersionBadge extends StatelessWidget {
  const _AppVersionBadge({required this.version});
  final String version;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/logo_horizontal_color.png',
          height: 36,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 8),
        Text(
          'v$version',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '\u00a9 2025 medphe',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}