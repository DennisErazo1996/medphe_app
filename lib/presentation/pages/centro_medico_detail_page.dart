import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/theme/app_theme.dart';
import '../../domain/entities/centro_medico.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class CentroMedicoDetailPage extends ConsumerWidget {
  const CentroMedicoDetailPage({super.key, required this.centroId});

  final String centroId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final centroAsync = ref.watch(centroMedicoByIdProvider(centroId));

    return Scaffold(
      backgroundColor: kMedpheSurface,
      body: centroAsync.when(
        data: (centro) => _CentroMedicoContent(centro: centro),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ocurrió un error al cargar el centro médico: $error',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(centroMedicoByIdProvider(centroId)),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CentroMedicoContent extends ConsumerWidget {
  const _CentroMedicoContent({required this.centro});

  final CentroMedico centro;

  Future<void> _abrirUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _abrirWhatsapp() {
    final cleanPhone = (centro.whatsapp ?? '').replaceAll(RegExp(r'\D'), '');
    return _abrirUrl('https://wa.me/$cleanPhone');
  }

  Future<void> _abrirTelefono() {
    final cleanPhone = (centro.telefonos ?? '').replaceAll(RegExp(r'\s+'), '');
    return _abrirUrl('tel:$cleanPhone');
  }

  Future<void> _abrirMaps() {
    if (centro.googleMapsUrl != null &&
        centro.googleMapsUrl!.trim().isNotEmpty) {
      return _abrirUrl(centro.googleMapsUrl!);
    }
    final query = Uri.encodeComponent(
      '${centro.nombre}, ${centro.ciudad.nombre}, ${centro.departamento}',
    );
    return _abrirUrl('https://www.google.com/maps/search/?api=1&query=$query');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctoresAsync = ref.watch(doctorsByCentroMedicoProvider(centro));
    final isFavorito =
        ref.watch(favoriteCentroMedicoIdsProvider).contains(centro.id);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          stretch: true,
          expandedHeight: 260,
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
                  iconColor: isFavorito ? AppColors.favorite : Colors.black87,
                  onPressed: () => toggleFavoriteCentroMedico(ref, centro.id),
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
                if (centro.fotoPortadaUrl != null &&
                    centro.fotoPortadaUrl!.isNotEmpty)
                  Image.network(
                    centro.fotoPortadaUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [kMedphePrimary, kMedpheSecondary],
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [kMedphePrimary, kMedpheSecondary],
                      ),
                    ),
                  ),
                // Gradiente oscuro suave para contraste
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.35),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.65),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Título y Ciudad
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            centro.nombre,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w800,
                              fontSize: 22,
                              height: 1.25,
                            ),
                          ),
                        ),
                        if (centro.esActivo) ...[
                          const SizedBox(width: 6),
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.verified,
                              color: kMedphePrimary,
                              size: 20,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${centro.ciudad.nombre}, ${centro.departamento}',
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade600,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Métricas rápidas
                    _MetricsBar(centro: centro),

                    const SizedBox(height: 20),

                    // Botones de contacto
                    _ContactRow(
                      centro: centro,
                      onCall: centro.tieneTelefonos ? _abrirTelefono : null,
                      onWhatsapp: centro.tieneWhatsapp ? _abrirWhatsapp : null,
                      onMaps: _abrirMaps,
                      onWebsite: centro.tieneWebsite
                          ? () => _abrirUrl(centro.websiteUrl!)
                          : null,
                    ),

                    const SizedBox(height: 24),

                    // Horario
                    if (centro.horario != null &&
                        centro.horario!.trim().isNotEmpty) ...[
                      _DetailSectionCard(
                        icon: Icons.access_time_rounded,
                        accent: kCategoryPalette[0],
                        title: 'Horario de atención',
                        content: Text(
                          centro.horario!,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Ubicación y Dirección
                    _DetailSectionCard(
                      icon: Icons.map_rounded,
                      accent: kCategoryPalette[1],
                      title: 'Dirección y ubicación',
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            centro.direccion.isNotEmpty
                                ? centro.direccion
                                : '${centro.ciudad.nombre}, ${centro.departamento}',
                            style: GoogleFonts.poppins(
                              fontSize: 13.5,
                              color: Colors.grey.shade800,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _abrirMaps,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: kMedphePrimary,
                              side: const BorderSide(color: kMedphePrimary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(
                              Icons.directions_outlined,
                              size: 18,
                            ),
                            label: const Text(
                              'Cómo llegar en Google Maps',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Teléfonos y canales de atención
                    if (centro.tieneTelefonos || centro.tieneEmail) ...[
                      _DetailSectionCard(
                        icon: Icons.contact_phone_outlined,
                        accent: kCategoryPalette[2],
                        title: 'Canales de atención',
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (centro.tieneTelefonos)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.phone_rounded,
                                      size: 18,
                                      color: Colors.black54,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        centro.telefonos!,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (centro.tieneEmail)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.email_outlined,
                                    size: 18,
                                    color: Colors.black54,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      centro.email!,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Servicios médicos
                    if (centro.serviciosMedicos.isNotEmpty) ...[
                      _ChipsSectionCard(
                        icon: Icons.medical_services_outlined,
                        accent: kCategoryPalette[3 % kCategoryPalette.length],
                        title: 'Servicios Médicos',
                        items: centro.serviciosMedicos,
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Especialidades médicas
                    if (centro.especialidadesMedicas.isNotEmpty) ...[
                      _ChipsSectionCard(
                        icon: Icons.school_outlined,
                        accent: kCategoryPalette[4 % kCategoryPalette.length],
                        title: 'Especialidades Disponibles',
                        items: centro.especialidadesMedicas,
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Médicos disponibles en este centro
                    doctoresAsync.when(
                      data: (doctores) {
                        if (doctores.isEmpty) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              'Especialistas en este centro (${doctores.length})',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: doctores.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) => DoctorCard(
                                doctor: doctores[index],
                                accent:
                                    kCategoryPalette[index %
                                        kCategoryPalette.length],
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (error, stack) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricsBar extends StatelessWidget {
  const _MetricsBar({required this.centro});

  final CentroMedico centro;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _MetricItem(
              icon: Icons.medical_services_outlined,
              color: kCategoryPalette[0],
              value: '${centro.serviciosMedicos.length}',
              label: 'Servicios',
            ),
          ),
          Container(width: 1, height: 32, color: Colors.grey.shade200),
          Expanded(
            child: _MetricItem(
              icon: Icons.school_outlined,
              color: kCategoryPalette[1],
              value: '${centro.especialidadesMedicas.length}',
              label: 'Especialidades',
            ),
          ),
          Container(width: 1, height: 32, color: Colors.grey.shade200),
          Expanded(
            child: _MetricItem(
              icon: Icons.location_city_outlined,
              color: kCategoryPalette[2],
              value: centro.ciudad.nombre,
              label: 'Ubicación',
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.centro,
    this.onCall,
    this.onWhatsapp,
    required this.onMaps,
    this.onWebsite,
  });

  final CentroMedico centro;
  final VoidCallback? onCall;
  final VoidCallback? onWhatsapp;
  final VoidCallback onMaps;
  final VoidCallback? onWebsite;

  @override
  Widget build(BuildContext context) {
    final actions = <(IconData, String, Color, VoidCallback)>[
      if (onCall != null)
        (Icons.phone_rounded, 'Llamar', kMedphePrimary, onCall!),
      if (onWhatsapp != null)
        (Icons.chat_bubble, 'WhatsApp', const Color(0xFF25D366), onWhatsapp!),
      (Icons.directions_outlined, 'Mapa', kCategoryPalette[1], onMaps),
      if (onWebsite != null)
        (Icons.language_rounded, 'Web', kMedpheSecondary, onWebsite!),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (final action in actions)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: action.$3.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: action.$4,
                  child: SizedBox(
                    width: 52,
                    height: 52,
                    child: Icon(action.$1, color: action.$3, size: 22),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                action.$2,
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _DetailSectionCard extends StatelessWidget {
  const _DetailSectionCard({
    required this.icon,
    required this.accent,
    required this.title,
    required this.content,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
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
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 18, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          content,
        ],
      ),
    );
  }
}

class _ChipsSectionCard extends StatelessWidget {
  const _ChipsSectionCard({
    required this.icon,
    required this.accent,
    required this.title,
    required this.items,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
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
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 18, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accent.withValues(alpha: 0.16)),
                ),
                child: Text(
                  item,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: accent,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
