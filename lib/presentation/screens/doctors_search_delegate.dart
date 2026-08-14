import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/doctor.dart';
import '../providers/providers.dart';
import '../../config/theme/app_theme.dart';

/// Abre el buscador de médicos y aplica el nombre ingresado como filtro.
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
    : super(searchFieldLabel: 'Buscar médicos o especialidades');

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
        return doctoresAsync.when(
          data: (doctores) => query.trim().isEmpty
              ? _SearchLanding(
                  doctores: doctores,
                  onEspecialidadTap: (nombre) => query = nombre,
                )
              : _LiveResults(
                  doctores: doctores,
                  query: query,
                  onApplyFilter: () {
                    onSubmit(query);
                    close(context, query);
                  },
                  onDoctorTap: (doctor) {
                    close(context, null);
                    context.push('/doctors/${doctor.id}');
                  },
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              const Center(child: Text('Ocurrió un error')),
        );
      },
    );
  }
}

/// Estado inicial del buscador: chips de especialidades para explorar.
class _SearchLanding extends StatelessWidget {
  const _SearchLanding({required this.doctores, required this.onEspecialidadTap});

  final List<Doctor> doctores;
  final void Function(String nombre) onEspecialidadTap;

  @override
  Widget build(BuildContext context) {
    final especialidades = <String>{
      for (final doctor in doctores)
        for (final especialidad in doctor.especialidades) especialidad.nombre,
    }.toList()..sort();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: [
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
                'Escribe un nombre o especialidad para ver resultados al instante.',
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

/// Resultados en vivo mientras se escribe: match por nombre o especialidad.
class _LiveResults extends StatelessWidget {
  const _LiveResults({
    required this.doctores,
    required this.query,
    required this.onApplyFilter,
    required this.onDoctorTap,
  });

  final List<Doctor> doctores;
  final String query;
  final VoidCallback onApplyFilter;
  final void Function(Doctor doctor) onDoctorTap;

  @override
  Widget build(BuildContext context) {
    final folded = _fold(query.trim());
    final matches = doctores.where((doctor) {
      if (_fold(doctor.nombre).contains(folded)) return true;
      return doctor.especialidades
          .any((e) => _fold(e.nombre).contains(folded));
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        _ApplyFilterTile(query: query, onTap: onApplyFilter),
        const SizedBox(height: 18),
        if (matches.isEmpty)
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
          Text(
            matches.length == 1
                ? '1 médico encontrado'
                : '${matches.length} médicos encontrados',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < matches.length; i++) ...[
            _SuggestionTile(
              doctor: matches[i],
              accent: kCategoryPalette[i % kCategoryPalette.length],
              onTap: () => onDoctorTap(matches[i]),
            ),
            if (i != matches.length - 1) const SizedBox(height: 10),
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
