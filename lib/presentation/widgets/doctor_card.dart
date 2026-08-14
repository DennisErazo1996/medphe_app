import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/doctor.dart';
import '../providers/favorites_provider.dart';

class DoctorCard extends ConsumerWidget {
  const DoctorCard({super.key, required this.doctor, required this.accent});

  final Doctor doctor;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorito = ref.watch(favoriteDoctorIdsProvider).contains(doctor.id);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/doctors/${doctor.id}'),
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.10),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _DoctorPhoto(doctor: doctor, accent: accent),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        doctor.especialidades.map((e) => e.nombre).join(', '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: accent,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            doctor.atiendeEn.isNotEmpty
                                ? '${doctor.ciudad.nombre} · ${doctor.atiendeEn.first}'
                                : doctor.ciudad.nombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _FavoriteButton(
                isFavorito: isFavorito,
                onTap: () => toggleFavoriteDoctor(ref, doctor.id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoctorPhoto extends StatelessWidget {
  const _DoctorPhoto({required this.doctor, required this.accent});

  final Doctor doctor;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.16),
            accent.withValues(alpha: 0.06),
          ],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: doctor.fotoUrl != null
          ? Image.network(
              doctor.fotoUrl!,
              fit: BoxFit.cover,
              // Fade-in suave al cargar; placeholder tintado ante error.
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) return child;
                return AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  child: child,
                );
              },
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.person_rounded, color: accent, size: 36),
            )
          : Icon(Icons.person_rounded, color: accent, size: 36),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.isFavorito, required this.onTap});

  final bool isFavorito;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: isFavorito
              ? kMedpheHeartColor.withValues(alpha: 0.12)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: Icon(
            isFavorito ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            key: ValueKey(isFavorito),
            size: 20,
            color: isFavorito ? kMedpheHeartColor : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}

const kMedpheHeartColor = Color(0xFFE53E7A);
