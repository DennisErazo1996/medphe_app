import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/centro_medico.dart';
import '../../domain/entities/doctor.dart';
import '../providers/providers.dart';
import '../../config/theme/app_theme.dart';

/// Abre el buscador de médicos y centros médicos y aplica el nombre ingresado como filtro.
/// Punto único usado tanto por la píldora de búsqueda del home como por el
/// botón de búsqueda del bottom navigation.
void openDoctorsSearch(BuildContext context, WidgetRef ref) {
  showSearch<String?>(
    context: context,
    delegate: DoctorsSearchDelegate(
      onSubmit: (nombre) {
        final current = ref.read(doctorsSearchFilterProvider);
        ref.read(doctorsSearchFilterProvider.notifier).state = current.copyWith(
          nombre: () => nombre,
        );
      },
    ),
  );
}

/// Normaliza texto para búsqueda: minúsculas y sin tildes.
String _fold(String value) {
  const accents = 'áàäâãéèëêíìïîóòöôõúùüûñ';
  const plain = 'aaaaaeeeeiiiiooooouuuun';
  final buffer = StringBuffer();
  for (final rune in value.toLowerCase().runes) {
    final char = String.fromCharCode(rune);
    final index = accents.indexOf(char);
    buffer.write(index == -1 ? char : plain[index]);
  }
  return buffer.toString();
}

class DoctorsSearchDelegate extends SearchDelegate<String?> {
  DoctorsSearchDelegate({required this.onSubmit})
    : super(searchFieldLabel: 'Buscar médicos o centros médicos');

  final void Function(String nombre) onSubmit;

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      scaffoldBackgroundColor: kMedpheSurface,
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: Colors.black26,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: kMedphePrimary,
      ),
    );
  }

  @override
  TextStyle get searchFieldStyle =>
      const TextStyle(fontSize: 15, fontWeight: FontWeight.w500);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.black45),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSubmit(query);
    close(context, query);
    return const SizedBox.shrink();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final doctoresAsync = ref.watch(allDoctorsProvider);
        final centrosAsync = ref.watch(allCentrosMedicosProvider);

        if (doctoresAsync.isLoading || centrosAsync.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final doctores = doctoresAsync.value ?? const [];
        final centros = centrosAsync.value ?? const [];

        return query.trim().isEmpty
            ? _SearchLanding(
                doctores: doctores,
                centros: centros,
                onEspecialidadTap: (nombre) => query = nombre,
                onCentroTap: (centro) {
                  close(context, null);
                  context.push('/centros-medicos/${centro.id}');
                },
              )
            : _LiveResults(
                doctores: doctores,
                centros: centros,
                query: query,
                onApplyFilter: () {
                  onSubmit(query);
                  close(context, query);
                },
                onDoctorTap: (doctor) {
                  close(context, null);
                  context.push('/doctors/${doctor.id}');
                },
                onCentroTap: (centro) {
                  close(context, null);
                  context.push('/centros-medicos/${centro.id}');
                },
              );
      },
    );
  }
}

/// Estado inicial del buscador: chips de especialidades y centros médicos para explorar.
class _SearchLanding extends StatelessWidget {
  const _SearchLanding({
    required this.doctores,
    required this.centros,
    required this.onEspecialidadTap,
    required this.onCentroTap,
  });

  final List<Doctor> doctores;
  final List<CentroMedico> centros;
  final void Function(String nombre) onEspecialidadTap;
  final void Function(CentroMedico centro) onCentroTap;

  @override
  Widget build(BuildContext context) {
    final especialidades = <String>{
      for (final doctor in doctores)
        for (final especialidad in doctor.especialidades) especialidad.nombre,
    }.toList()..sort();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: [
        if (centros.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Centros médicos',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Colors.grey.shade800,
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/centros-medicos');
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Text(
                    'Ver todos',
                    style: TextStyle(
                      color: kMedphePrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: centros.take(6).length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final centro = centros[index];
                final accent = kCategoryPalette[index % kCategoryPalette.length];
                return InkWell(
                  onTap: () => onCentroTap(centro),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 130,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: centro.logoUrl != null &&
                                      centro.logoUrl!.isNotEmpty
                                  ? Image.network(
                                      centro.logoUrl!,
                                      fit: BoxFit.contain,
                                      errorBuilder: (c, e, s) => Icon(
                                        Icons.local_hospital_rounded,
                                        color: accent,
                                        size: 18,
                                      ),
                                    )
                                  : Icon(
                                      Icons.local_hospital_rounded,
                                      color: accent,
                                      size: 18,
                                    ),
                            ),
                            const Spacer(),
                            if (centro.acronimo.isNotEmpty)
                              Text(
                                centro.acronimo,
                                style: TextStyle(
                                  color: accent,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          centro.nombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          centro.ciudad.nombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],

        Text(
          'Explora por especialidad',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (var i = 0; i < especialidades.length; i++)
              _EspecialidadChip(
                nombre: especialidades[i],
                accent: kCategoryPalette[i % kCategoryPalette.length],
                onTap: () => onEspecialidadTap(especialidades[i]),
              ),
          ],
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Icon(Icons.tips_and_updates_outlined,
                size: 16, color: Colors.grey.shade500),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Escribe un médico, centro médico o especialidad para ver resultados al instante.',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12.5),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EspecialidadChip extends StatelessWidget {
  const _EspecialidadChip({
    required this.nombre,
    required this.accent,
    required this.onTap,
  });

  final String nombre;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          nombre,
          style: TextStyle(
            color: accent,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Resultados en vivo mientras se escribe: match por médico o centro médico.
class _LiveResults extends StatelessWidget {
  const _LiveResults({
    required this.doctores,
    required this.centros,
    required this.query,
    required this.onApplyFilter,
    required this.onDoctorTap,
    required this.onCentroTap,
  });

  final List<Doctor> doctores;
  final List<CentroMedico> centros;
  final String query;
  final VoidCallback onApplyFilter;
  final void Function(Doctor doctor) onDoctorTap;
  final void Function(CentroMedico centro) onCentroTap;

  @override
  Widget build(BuildContext context) {
    final folded = _fold(query.trim());

    final doctorMatches = doctores.where((doctor) {
      if (_fold(doctor.nombre).contains(folded)) return true;
      return doctor.especialidades
          .any((e) => _fold(e.nombre).contains(folded));
    }).toList();

    final centroMatches = centros.where((centro) {
      if (_fold(centro.nombre).contains(folded)) return true;
      if (centro.acronimo.isNotEmpty &&
          _fold(centro.acronimo).contains(folded)) {
        return true;
      }
      if (_fold(centro.ciudad.nombre).contains(folded)) return true;
      if (_fold(centro.departamento).contains(folded)) return true;
      if (centro.serviciosMedicos.any((s) => _fold(s).contains(folded))) {
        return true;
      }
      return centro.especialidadesMedicas
          .any((e) => _fold(e).contains(folded));
    }).toList();

    final totalMatches = doctorMatches.length + centroMatches.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        _ApplyFilterTile(query: query, onTap: onApplyFilter),
        const SizedBox(height: 18),
        if (totalMatches == 0)
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Column(
              children: [
                Icon(Icons.search_off_rounded,
                    size: 40, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  'Sin coincidencias para "$query"',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13.5),
                ),
              ],
            ),
          )
        else ...[
          // Centros médicos encontrados
          if (centroMatches.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.location_city_rounded,
                    size: 17, color: kMedphePrimary),
                const SizedBox(width: 6),
                Text(
                  centroMatches.length == 1
                      ? '1 centro médico'
                      : '${centroMatches.length} centros médicos',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < centroMatches.length; i++) ...[
              _CentroMedicoSuggestionTile(
                centro: centroMatches[i],
                accent: kCategoryPalette[i % kCategoryPalette.length],
                onTap: () => onCentroTap(centroMatches[i]),
              ),
              if (i != centroMatches.length - 1) const SizedBox(height: 10),
            ],
            const SizedBox(height: 20),
          ],

          // Médicos encontrados
          if (doctorMatches.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.person_rounded,
                    size: 17, color: kMedphePrimary),
                const SizedBox(width: 6),
                Text(
                  doctorMatches.length == 1
                      ? '1 médico encontrado'
                      : '${doctorMatches.length} médicos encontrados',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < doctorMatches.length; i++) ...[
              _SuggestionTile(
                doctor: doctorMatches[i],
                accent: kCategoryPalette[i % kCategoryPalette.length],
                onTap: () => onDoctorTap(doctorMatches[i]),
              ),
              if (i != doctorMatches.length - 1) const SizedBox(height: 10),
            ],
          ],
        ],
      ],
    );
  }
}

/// Tile que aplica el texto actual como filtro en la lista del home.
class _ApplyFilterTile extends StatelessWidget {
  const _ApplyFilterTile({required this.query, required this.onTap});

  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [kMedphePrimary, kMedpheSecondary],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: kMedphePrimary.withValues(alpha: 0.28),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.filter_list_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Filtrar lista por "$query"',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_rounded,
                color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}

class _CentroMedicoSuggestionTile extends StatelessWidget {
  const _CentroMedicoSuggestionTile({
    required this.centro,
    required this.accent,
    required this.onTap,
  });

  final CentroMedico centro;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: accent.withValues(alpha: 0.10),
              ),
              clipBehavior: Clip.antiAlias,
              child: centro.logoUrl != null && centro.logoUrl!.isNotEmpty
                  ? Image.network(
                      centro.logoUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.local_hospital_rounded,
                              color: accent, size: 24),
                    )
                  : Icon(Icons.local_hospital_rounded,
                      color: accent, size: 24),
            ),
            const SizedBox(width: 12),
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
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (centro.acronimo.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            centro.acronimo,
                            style: TextStyle(
                              color: accent,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${centro.ciudad.nombre} · ${centro.serviciosMedicos.length} servicios',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({
    required this.doctor,
    required this.accent,
    required this.onTap,
  });

  final Doctor doctor;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: accent.withValues(alpha: 0.10),
              ),
              clipBehavior: Clip.antiAlias,
              child: doctor.fotoUrl != null
                  ? Image.network(
                      doctor.fotoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.person_rounded, color: accent, size: 24),
                    )
                  : Icon(Icons.person_rounded, color: accent, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    doctor.especialidades.map((e) => e.nombre).join(', '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
