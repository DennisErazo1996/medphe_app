import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/doctor.dart';
import '../../main.dart';
import '../providers/providers.dart';

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
                onPressed: () =>
                    ref.invalidate(doctorByIdProvider(doctorId)),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoctorProfileContent extends StatelessWidget {
  const _DoctorProfileContent({required this.doctor});

  final Doctor doctor;

  Future<void> _abrirUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _abrirWhatsapp() {
    return _abrirUrl('https://wa.me/${doctor.whatsappNumero}');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
          children: [
            Row(
              children: [
                _CircleIconButton(
                  icon: Icons.arrow_back,
                  onPressed: () => context.pop(),
                ),
                const Expanded(
                  child: Text(
                    'Médico',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 168,
                height: 168,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: kMedphePrimary.withValues(alpha: 0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                  image: doctor.fotoUrl != null
                      ? DecorationImage(
                          image: NetworkImage(doctor.fotoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: doctor.fotoUrl == null
                    ? const Icon(Icons.person, size: 64, color: kMedphePrimary)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.nombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doctor.especialidades.isNotEmpty
                              ? doctor.especialidades.first.nombre
                              : '',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: kMedpheSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              doctor.ciudad.nombre,
                              style: const TextStyle(
                                color: kMedpheSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _QuickActionButton(
                    icon: Icons.chat_bubble,
                    color: const Color(0xFF25D366),
                    onPressed: _abrirWhatsapp,
                  ),
                  if (doctor.instagramUrl != null) ...[
                    const SizedBox(width: 8),
                    _QuickActionButton(
                      icon: Icons.camera_alt_outlined,
                      color: kCategoryPalette[3],
                      onPressed: () => _abrirUrl(doctor.instagramUrl!),
                    ),
                  ],
                  if (doctor.facebookUrl != null) ...[
                    const SizedBox(width: 8),
                    _QuickActionButton(
                      icon: Icons.facebook,
                      color: kMedphePrimary,
                      onPressed: () => _abrirUrl(doctor.facebookUrl!),
                    ),
                  ],
                  if (doctor.tiktokUrl != null) ...[
                    const SizedBox(width: 8),
                    _QuickActionButton(
                      icon: Icons.music_note,
                      color: kMedpheSecondary,
                      onPressed: () => _abrirUrl(doctor.tiktokUrl!),
                    ),
                  ],
                ],
              ),
            ),
            if (doctor.especialidades.length > 1) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: doctor.especialidades
                    .map((e) => Chip(label: Text(e.nombre)))
                    .toList(),
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
              icon: Icons.favorite_border,
              accent: kCategoryPalette[2],
              titulo: 'Atención avanzada a pacientes con',
              items: doctor.atencionAvanzadaPacientesCon,
            ),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: kMedpheSurface.withValues(alpha: 0.0),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  kMedpheSurface.withValues(alpha: 0),
                  kMedpheSurface,
                  kMedpheSurface,
                ],
                stops: const [0, 0.35, 1],
              ),
            ),
            child: SafeArea(
              top: false,
              child: ElevatedButton.icon(
                onPressed: _abrirWhatsapp,
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Contactar por WhatsApp'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icon, color: Colors.black87),
        onPressed: onPressed,
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
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
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border(left: BorderSide(color: accent, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 16, color: accent),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 13.5,
                          height: 1.4,
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
