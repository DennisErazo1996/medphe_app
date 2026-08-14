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
    final isFavorito = ref
        .watch(favoriteDoctorIdsProvider)
        .contains(doctor.id);

    return InkWell(
      onTap: () => context.push('/doctors/${doctor.id}'),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: doctor.fotoUrl != null
                        ? Image.network(doctor.fotoUrl!, fit: BoxFit.cover)
                        : Container(
                            color: accent.withValues(alpha: 0.12),
                            child: Icon(Icons.person, color: accent, size: 32),
                          ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(width: 3, color: accent),
                ),
              ],
            ),
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
                  const SizedBox(height: 4),
                  Text(
                    doctor.especialidades.map((e) => e.nombre).join(', '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          doctor.ciudad.nombre,
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
            IconButton(
              icon: Icon(
                isFavorito ? Icons.favorite : Icons.favorite_border,
                color: isFavorito ? kMedpheHeartColor : Colors.black26,
              ),
              onPressed: () => toggleFavoriteDoctor(ref, doctor.id),
            ),
          ],
        ),
      ),
    );
  }
}

const kMedpheHeartColor = Color(0xFFE53E7A);
