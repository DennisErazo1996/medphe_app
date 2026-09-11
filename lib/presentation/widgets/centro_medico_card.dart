import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/centro_medico.dart';

class CentroMedicoCard extends StatelessWidget {
  const CentroMedicoCard({
    super.key,
    required this.centro,
    required this.accent,
    this.onTap,
  });

  final CentroMedico centro;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () => context.push('/centros-medicos/${centro.id}'),
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
              _CentroFoto(centro: centro, accent: accent),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            centro.nombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (centro.acronimo.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              centro.acronimo,
                              style: TextStyle(
                                color: accent,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 13,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            centro.ciudad.nombre.isNotEmpty
                                ? '${centro.ciudad.nombre}, ${centro.departamento}'
                                : centro.departamento,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (centro.serviciosMedicos.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.medical_services_outlined,
                                  size: 11,
                                  color: accent,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${centro.serviciosMedicos.length} servicios',
                                  style: TextStyle(
                                    color: accent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (centro.horario != null &&
                            centro.horario!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 11,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 120,
                                  ),
                                  child: Text(
                                    centro.horario!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: accent,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CentroFoto extends StatelessWidget {
  const _CentroFoto({required this.centro, required this.accent});

  final CentroMedico centro;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final fotoUrl = centro.fotoPortadaUrl;
    final logoUrl = centro.logoUrl;

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(18),
          ),
          child: fotoUrl != null && fotoUrl.isNotEmpty
              ? Image.network(
                  fotoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _CentroLogoFallback(
                        logoUrl: logoUrl,
                        accent: accent,
                        acronimo: centro.acronimo,
                      ),
                )
              : _CentroLogoFallback(
                  logoUrl: logoUrl,
                  accent: accent,
                  acronimo: centro.acronimo,
                ),
        ),
      ),
    );
  }
}

class _CentroLogoFallback extends StatelessWidget {
  const _CentroLogoFallback({
    required this.logoUrl,
    required this.accent,
    required this.acronimo,
  });

  final String? logoUrl;
  final Color accent;
  final String acronimo;

  @override
  Widget build(BuildContext context) {
    if (logoUrl != null && logoUrl!.isNotEmpty) {
      return Image.network(
        logoUrl!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            _FallbackLogo(accent: accent, acronimo: acronimo),
      );
    }
    return _FallbackLogo(accent: accent, acronimo: acronimo);
  }
}

class _FallbackLogo extends StatelessWidget {
  const _FallbackLogo({required this.accent, required this.acronimo});

  final Color accent;
  final String acronimo;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: accent.withValues(alpha: 0.10),
      child: Center(
        child: acronimo.isNotEmpty
            ? Text(
                acronimo.length > 4 ? acronimo.substring(0, 4) : acronimo,
                style: GoogleFonts.poppins(
                  color: accent,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              )
            : Icon(Icons.local_hospital_rounded, color: accent, size: 32),
      ),
    );
  }
}
