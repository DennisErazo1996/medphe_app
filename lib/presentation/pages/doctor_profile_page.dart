import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/doctor.dart';
import '../providers/providers.dart';
import '../../config/theme/app_theme.dart';
import '../widgets/widgets.dart';

class DoctorProfilePage extends ConsumerWidget {
  const DoctorProfilePage({super.key, required this.doctorId});

  final String doctorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorAsync = ref.watch(doctorByIdProvider(doctorId));

    return Scaffold(
      backgroundColor: kMedpheSurface,
      body: doctorAsync.when(
        data: (doctor) => _DoctorProfileContent(doctor: doctor),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Ocurrió un error: $error'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(doctorByIdProvider(doctorId)),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoctorProfileContent extends ConsumerWidget {
  const _DoctorProfileContent({required this.doctor});

  final Doctor doctor;

  Future<void> _abrirUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Fallback: intentar sin verificar
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
      }
    }
  }

  Future<void> _abrirWhatsapp() {
    // Formato internacional sin '+' ni espacios: wa.me/+50312345678 o wa.me/50312345678
    final numero = doctor.whatsappNumero.replaceAll(RegExp(r'[^\d+]'), '');
    return _abrirUrl('https://wa.me/$numero');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorito = ref.watch(favoriteDoctorIdsProvider).contains(doctor.id);

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              stretch: true,
              expandedHeight: 320,
              toolbarHeight: 64,
              leadingWidth: 68,
              backgroundColor: kMedphePrimary,
              foregroundColor: Colors.white,
              leading: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: CircleIconButton(
                    icon: Icons.arrow_back,
                    onPressed: () => context.pop(),
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: CircleIconButton(
                      icon: isFavorito ? Icons.favorite : Icons.favorite_border,
                      iconColor: isFavorito ? kMedpheHeartColor : Colors.black87,
                      onPressed: () => toggleFavoriteDoctor(ref, doctor.id),
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [
                  StretchMode.zoomBackground,
                  StretchMode.fadeTitle,
                ],
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (doctor.fotoUrl != null)
                      Image.network(doctor.fotoUrl!, fit: BoxFit.cover)
                    else
                      Container(
                        color: kMedphePrimary,
                        child: const Icon(
                          Icons.person,
                          size: 96,
                          color: Colors.white70,
                        ),
                      ),
                    // Funde la foto hacia el color de fondo para que el
                    // contenido bajo el hero se integre sin corte duro.
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.30),
                            Colors.transparent,
                            kMedpheSurface.withValues(alpha: 0.0),
                            kMedpheSurface,
                          ],
                          stops: const [0, 0.45, 0.78, 1],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 118),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Column(
                    children: [
                      _IdentityCard(doctor: doctor),
                      const SizedBox(height: 16),
                      _StatsStrip(doctor: doctor),
                      const SizedBox(height: 16),
                      _ContactRow(
                        doctor: doctor,
                        onWhatsapp: _abrirWhatsapp,
                        onUrl: _abrirUrl,
                      ),
                      if (doctor.especialidades.length > 1) ...[
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          kMedphePrimary.withValues(alpha: 0.18),
                                          kMedphePrimary.withValues(alpha: 0.08),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(
                                      Icons.biotech_outlined,
                                      size: 20,
                                      color: kMedphePrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Subespecialidades',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: doctor.especialidades
                                    .skip(1)
                                    .map(
                                      (e) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 7,
                                        ),
                                        decoration: BoxDecoration(
                                          color: kMedphePrimary.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(100),
                                          border: Border.all(
                                            color: kMedphePrimary.withValues(alpha: 0.2),
                                          ),
                                        ),
                                        child: Text(
                                          e.nombre,
                                          style: GoogleFonts.poppins(
                                            color: kMedphePrimary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12.5,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      _InfoCard(
                        icon: Icons.local_hospital_outlined,
                        accent: kCategoryPalette[0],
                        titulo: 'Atiende en',
                        items: doctor.atiendeEn,
                      ),
                      _InfoCard(
                        icon: Icons.medical_services_outlined,
                        accent: kCategoryPalette[1],
                        titulo: 'Servicios médicos',
                        items: doctor.serviciosMedicos,
                      ),
                      _InfoCard(
                        icon: Icons.monitor_heart_outlined,
                        accent: kCategoryPalette[2],
                        titulo: 'Atención avanzada a pacientes con',
                        items: doctor.atencionAvanzadaPacientesCon,
                      ),
                    ],
                  ),
                ]),
              ),
            ),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  kMedpheSurface.withValues(alpha: 0),
                  kMedpheSurface,
                  kMedpheSurface,
                ],
                stops: const [0, 0.4, 1],
              ),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _abrirWhatsapp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kMedpheSecondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    textStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    shadowColor: kMedpheSecondary.withValues(alpha: 0.4),
                    elevation: 8,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _WhatsappLogo(size: 22),
                      SizedBox(width: 10),
                      Text('Contactar por WhatsApp'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


/// Logo oficial de WhatsApp (PNG blanco sobre transparente).
class _WhatsappLogo extends StatelessWidget {
  const _WhatsappLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/whatsapp.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}


class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    final especialidad = doctor.especialidades.isNotEmpty
        ? doctor.especialidades.first.nombre
        : '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: kMedphePrimary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  doctor.nombre,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.verified, color: kMedphePrimary, size: 20),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            especialidad,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: kMedpheSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: kMedpheSurface,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: kMedphePrimary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${doctor.ciudad.nombre}, ${doctor.ciudad.departamento}',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade800,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsStrip extends StatelessWidget {
  const _StatsStrip({required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    final stats = <(String, String, IconData, Color)>[
      (
        '${doctor.especialidades.length}',
        doctor.especialidades.length == 1 ? 'Especialidad' : 'Especialidades',
        Icons.school_outlined,
        kCategoryPalette[0],
      ),
      (
        '${doctor.atiendeEn.length}',
        doctor.atiendeEn.length == 1 ? 'Centro médico' : 'Centros médicos',
        Icons.location_city_outlined,
        kCategoryPalette[2],
      ),
      (
        '${doctor.serviciosMedicos.length}',
        'Servicios',
        Icons.medical_services_outlined,
        kCategoryPalette[3],
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0)
              Container(
                width: 1,
                height: 36,
                color: Colors.black.withValues(alpha: 0.06),
              ),
            Expanded(
              child: Column(
                children: [
                  Icon(stats[i].$3, size: 20, color: stats[i].$4),
                  const SizedBox(height: 4),
                  Text(
                    stats[i].$1,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    stats[i].$2,
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade600,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.doctor,
    required this.onWhatsapp,
    required this.onUrl,
  });

  final Doctor doctor;
  final Future<void> Function() onWhatsapp;
  final Future<void> Function(String url) onUrl;

  @override
  Widget build(BuildContext context) {
    final actions = <(Widget Function(Color), String, Color, VoidCallback)>[
      (
        (color) => _WhatsappLogo(size: 22),
        'WhatsApp',
        kMedpheSecondary,
        () => onWhatsapp(),
      ),
      if (doctor.instagramUrl != null)
        (
          (color) => Icon(Icons.camera_alt_outlined, color: color, size: 22),
          'Instagram',
          kCategoryPalette[3],
          () => onUrl(doctor.instagramUrl!),
        ),
      if (doctor.facebookUrl != null)
        (
          (color) => Icon(Icons.facebook, color: color, size: 22),
          'Facebook',
          kMedphePrimary,
          () => onUrl(doctor.facebookUrl!),
        ),
      if (doctor.tiktokUrl != null)
        (
          (color) => Icon(Icons.music_note, color: color, size: 22),
          'TikTok',
          kMedpheSecondary,
          () => onUrl(doctor.tiktokUrl!),
        ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (final action in actions)
          _ContactAction(
            iconBuilder: action.$1,
            label: action.$2,
            color: action.$3,
            onPressed: action.$4,
          ),
      ],
    );
  }
}

class _ContactAction extends StatelessWidget {
  const _ContactAction({
    required this.iconBuilder,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final Widget Function(Color color) iconBuilder;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onPressed,
              child: SizedBox(
                width: 52,
                height: 52,
                child: Center(child: iconBuilder(color)),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.accent,
    required this.titulo,
    required this.items,
  });

  final IconData icon;
  final Color accent;
  final String titulo;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accent.withValues(alpha: 0.18),
                        accent.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, size: 20, color: accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    titulo,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.check_circle,
                        size: 16,
                        color: accent.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade800,
                          fontSize: 13.5,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
