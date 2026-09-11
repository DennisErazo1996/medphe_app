import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../config/theme/app_theme.dart';
import '../providers/providers.dart';

Future<void> showDoctorsFilterModal(BuildContext context, [WidgetRef? ref]) {
  final pageIndexNotifier = ValueNotifier<int>(0);

  return WoltModalSheet.show<void>(
    context: context,
    useSafeArea: true,
    pageIndexNotifier: pageIndexNotifier,
    modalTypeBuilder: (context) {
      return const WoltBottomSheetType(
        shapeBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        showDragHandle: true,
      );
    },
    pageListBuilder: (modalContext) {
      return [
        // Página 0: Filtros principales
        WoltModalSheetPage(
          backgroundColor: kMedpheSurface,
          surfaceTintColor: Colors.transparent,
          hasTopBarLayer: false,
          stickyActionBar: const _FilterActionBar(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 42, 20, 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Filtros',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Personaliza tu búsqueda de médicos',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _CloseButton(onPressed: () => Navigator.of(modalContext).pop()),
                  ],
                ),
                const SizedBox(height: 20),
                _DoctorsFilterForm(pageIndexNotifier: pageIndexNotifier),
              ],
            ),
          ),
        ),

        // Página 1: Selector de Especialidad con buscador
        WoltModalSheetPage(
          backgroundColor: kMedpheSurface,
          surfaceTintColor: Colors.transparent,
          hasTopBarLayer: false,
          child: _SpecialtySelectionView(
            pageIndexNotifier: pageIndexNotifier,
            onBack: () => pageIndexNotifier.value = 0,
            onClose: () => Navigator.of(modalContext).pop(),
          ),
        ),

        // Página 2: Selector de Ciudad con buscador
        WoltModalSheetPage(
          backgroundColor: kMedpheSurface,
          surfaceTintColor: Colors.transparent,
          hasTopBarLayer: false,
          child: _CitySelectionView(
            pageIndexNotifier: pageIndexNotifier,
            onBack: () => pageIndexNotifier.value = 0,
            onClose: () => Navigator.of(modalContext).pop(),
          ),
        ),

        // Página 3: Selector de Centro Médico con buscador
        WoltModalSheetPage(
          backgroundColor: kMedpheSurface,
          surfaceTintColor: Colors.transparent,
          hasTopBarLayer: false,
          child: _CentroMedicoSelectionView(
            pageIndexNotifier: pageIndexNotifier,
            onBack: () => pageIndexNotifier.value = 0,
            onClose: () => Navigator.of(modalContext).pop(),
          ),
        ),
      ];
    },
  );
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.05),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(Icons.close_rounded, size: 18, color: Colors.black54),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.05),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(Icons.arrow_back_rounded, size: 18, color: Colors.black54),
        ),
      ),
    );
  }
}

/// Barra fija inferior con las acciones principales del modal: limpiar y
/// aplicar. Se mantiene visible aunque el contenido haga scroll.
class _FilterActionBar extends ConsumerWidget {
  const _FilterActionBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(doctorsSearchFilterProvider);
    final tieneFiltros = filter.especialidadId != null ||
        filter.ciudadId != null ||
        filter.centroMedicoId != null ||
        (filter.nombre != null && filter.nombre!.isNotEmpty);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: kMedpheSurface,
        border: Border(
          top: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: tieneFiltros
                    ? () {
                        ref
                            .read(doctorsSearchFilterProvider.notifier)
                            .state = const DoctorsSearchFilter();
                      }
                    : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: kMedphePrimary,
                  side: BorderSide(
                    color: tieneFiltros
                        ? kMedphePrimary.withValues(alpha: 0.4)
                        : Colors.black.withValues(alpha: 0.1),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                child: const Text('Limpiar'),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: kMedphePrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                ),
                child: const Text('Aplicar filtros'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorsFilterForm extends ConsumerWidget {
  const _DoctorsFilterForm({required this.pageIndexNotifier});

  final ValueNotifier<int> pageIndexNotifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final especialidadesAsync = ref.watch(especialidadesProvider);
    final ciudadesAsync = ref.watch(ciudadesProvider);
    final centrosAsync = ref.watch(allCentrosMedicosProvider);
    final filter = ref.watch(doctorsSearchFilterProvider);

    final especialidadSeleccionada = especialidadesAsync.asData?.value
        .where((e) => e.id == filter.especialidadId)
        .firstOrNull;
    final nombreEspecialidad =
        especialidadSeleccionada?.nombre ?? filter.especialidadId;

    final ciudadSeleccionada = ciudadesAsync.asData?.value
        .where((c) => c.id == filter.ciudadId)
        .firstOrNull;
    final nombreCiudad = ciudadSeleccionada != null
        ? '${ciudadSeleccionada.nombre}, ${ciudadSeleccionada.departamento}'
        : filter.ciudadId;

    final centroSeleccionado = centrosAsync.asData?.value
        .where((c) => c.id == filter.centroMedicoId)
        .firstOrNull;
    final nombreCentro =
        centroSeleccionado?.displayNombre ?? filter.centroMedicoId;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SelectorTile(
          icon: Icons.medical_services_outlined,
          label: 'Especialidad',
          valueText: nombreEspecialidad ?? 'Todas las especialidades',
          isSelected: filter.especialidadId != null,
          onTap: () => pageIndexNotifier.value = 1,
          onClear: () {
            ref.read(doctorsSearchFilterProvider.notifier).state =
                filter.copyWith(especialidadId: () => null);
          },
        ),
        const SizedBox(height: 14),
        _SelectorTile(
          icon: Icons.location_on_outlined,
          label: 'Ciudad',
          valueText: nombreCiudad ?? 'Todas las ciudades',
          isSelected: filter.ciudadId != null,
          onTap: () => pageIndexNotifier.value = 2,
          onClear: () {
            ref.read(doctorsSearchFilterProvider.notifier).state =
                filter.copyWith(ciudadId: () => null);
          },
        ),
        const SizedBox(height: 14),
        _SelectorTile(
          icon: Icons.location_city_outlined,
          label: 'Centro Médico',
          valueText: nombreCentro ?? 'Todos los centros médicos',
          isSelected: filter.centroMedicoId != null,
          onTap: () => pageIndexNotifier.value = 3,
          onClear: () {
            ref.read(doctorsSearchFilterProvider.notifier).state =
                filter.copyWith(centroMedicoId: () => null);
          },
        ),
      ],
    );
  }
}

class _SelectorTile extends StatelessWidget {
  const _SelectorTile({
    required this.icon,
    required this.label,
    required this.valueText,
    required this.isSelected,
    required this.onTap,
    required this.onClear,
  });

  final IconData icon;
  final String label;
  final String valueText;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? kMedphePrimary.withValues(alpha: 0.35)
                  : Colors.black.withValues(alpha: 0.08),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isSelected
                      ? kMedphePrimary.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? kMedphePrimary : Colors.black54,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      valueText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? kMedphePrimary : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                IconButton(
                  tooltip: 'Quitar filtro',
                  icon: const Icon(Icons.close, size: 18, color: Colors.black45),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: onClear,
                ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.black38,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpecialtySelectionView extends ConsumerWidget {
  const _SpecialtySelectionView({
    required this.onBack,
    required this.onClose,
    required this.pageIndexNotifier,
  });

  final VoidCallback onBack;
  final VoidCallback onClose;
  final ValueNotifier<int> pageIndexNotifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final especialidadesAsync = ref.watch(especialidadesProvider);
    final filter = ref.watch(doctorsSearchFilterProvider);

    void onSelected(String? id) {
      final current = ref.read(doctorsSearchFilterProvider);
      ref.read(doctorsSearchFilterProvider.notifier).state =
          current.copyWith(especialidadId: () => id);
      pageIndexNotifier.value = 0;
    }

    return especialidadesAsync.when(
      data: (especialidades) => _SearchableSelectionView(
        screenTitle: 'Especialidad',
        screenSubtitle: 'Selecciona una especialidad',
        titleAll: 'Todas las especialidades',
        searchHint: 'Buscar especialidad...',
        selectedId: filter.especialidadId,
        items: [
          for (final e in especialidades) (id: e.id, nombre: e.nombre, subtitle: null),
        ],
        isLoading: false,
        errorMessage: null,
        onBack: onBack,
        onClose: onClose,
        onSelected: onSelected,
      ),
      loading: () => _SearchableSelectionView(
        screenTitle: 'Especialidad',
        screenSubtitle: 'Selecciona una especialidad',
        titleAll: 'Todas las especialidades',
        searchHint: 'Buscar especialidad...',
        selectedId: null,
        items: const [],
        isLoading: true,
        errorMessage: null,
        onBack: onBack,
        onClose: onClose,
        onSelected: onSelected,
      ),
      error: (error, _) => _SearchableSelectionView(
        screenTitle: 'Especialidad',
        screenSubtitle: 'Selecciona una especialidad',
        titleAll: 'Todas las especialidades',
        searchHint: 'Buscar especialidad...',
        selectedId: null,
        items: const [],
        isLoading: false,
        errorMessage: error.toString(),
        onBack: onBack,
        onClose: onClose,
        onSelected: onSelected,
      ),
    );
  }
}

class _CitySelectionView extends ConsumerWidget {
  const _CitySelectionView({
    required this.onBack,
    required this.onClose,
    required this.pageIndexNotifier,
  });

  final VoidCallback onBack;
  final VoidCallback onClose;
  final ValueNotifier<int> pageIndexNotifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ciudadesAsync = ref.watch(ciudadesProvider);
    final filter = ref.watch(doctorsSearchFilterProvider);

    void onSelected(String? id) {
      final current = ref.read(doctorsSearchFilterProvider);
      ref.read(doctorsSearchFilterProvider.notifier).state =
          current.copyWith(ciudadId: () => id);
      pageIndexNotifier.value = 0;
    }

    return ciudadesAsync.when(
      data: (ciudades) => _SearchableSelectionView(
        screenTitle: 'Ciudad',
        screenSubtitle: 'Selecciona tu ciudad',
        titleAll: 'Todas las ciudades',
        searchHint: 'Buscar ciudad...',
        selectedId: filter.ciudadId,
        items: [
          for (final c in ciudades)
            (id: c.id, nombre: c.nombre, subtitle: c.departamento),
        ],
        isLoading: false,
        errorMessage: null,
        onBack: onBack,
        onClose: onClose,
        onSelected: onSelected,
      ),
      loading: () => _SearchableSelectionView(
        screenTitle: 'Ciudad',
        screenSubtitle: 'Selecciona tu ciudad',
        titleAll: 'Todas las ciudades',
        searchHint: 'Buscar ciudad...',
        selectedId: null,
        items: const [],
        isLoading: true,
        errorMessage: null,
        onBack: onBack,
        onClose: onClose,
        onSelected: onSelected,
      ),
      error: (error, _) => _SearchableSelectionView(
        screenTitle: 'Ciudad',
        screenSubtitle: 'Selecciona tu ciudad',
        titleAll: 'Todas las ciudades',
        searchHint: 'Buscar ciudad...',
        selectedId: null,
        items: const [],
        isLoading: false,
        errorMessage: error.toString(),
        onBack: onBack,
        onClose: onClose,
        onSelected: onSelected,
      ),
    );
  }
}

class _CentroMedicoSelectionView extends ConsumerWidget {
  const _CentroMedicoSelectionView({
    required this.onBack,
    required this.onClose,
    required this.pageIndexNotifier,
  });

  final VoidCallback onBack;
  final VoidCallback onClose;
  final ValueNotifier<int> pageIndexNotifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final centrosAsync = ref.watch(allCentrosMedicosProvider);
    final filter = ref.watch(doctorsSearchFilterProvider);

    void onSelected(String? id) {
      final current = ref.read(doctorsSearchFilterProvider);
      ref.read(doctorsSearchFilterProvider.notifier).state =
          current.copyWith(centroMedicoId: () => id);
      pageIndexNotifier.value = 0;
    }

    return centrosAsync.when(
      data: (centros) => _SearchableSelectionView(
        screenTitle: 'Centro Médico',
        screenSubtitle: 'Selecciona un centro médico u hospital',
        titleAll: 'Todos los centros médicos',
        searchHint: 'Buscar centro médico...',
        selectedId: filter.centroMedicoId,
        items: [
          for (final c in centros)
            (
              id: c.id,
              nombre: c.acronimo.isNotEmpty && c.acronimo != c.nombre
                  ? '${c.nombre} (${c.acronimo})'
                  : c.nombre,
              subtitle: null,
            ),
        ],
        isLoading: false,
        errorMessage: null,
        onBack: onBack,
        onClose: onClose,
        onSelected: onSelected,
      ),
      loading: () => _SearchableSelectionView(
        screenTitle: 'Centro Médico',
        screenSubtitle: 'Selecciona un centro médico u hospital',
        titleAll: 'Todos los centros médicos',
        searchHint: 'Buscar centro médico...',
        selectedId: null,
        items: const [],
        isLoading: true,
        errorMessage: null,
        onBack: onBack,
        onClose: onClose,
        onSelected: onSelected,
      ),
      error: (error, _) => _SearchableSelectionView(
        screenTitle: 'Centro Médico',
        screenSubtitle: 'Selecciona un centro médico u hospital',
        titleAll: 'Todos los centros médicos',
        searchHint: 'Buscar centro médico...',
        selectedId: null,
        items: const [],
        isLoading: false,
        errorMessage: error.toString(),
        onBack: onBack,
        onClose: onClose,
        onSelected: onSelected,
      ),
    );
  }
}

class _SearchableSelectionView extends StatefulWidget {
  const _SearchableSelectionView({
    required this.screenTitle,
    required this.screenSubtitle,
    required this.titleAll,
    required this.searchHint,
    required this.selectedId,
    required this.items,
    required this.isLoading,
    required this.errorMessage,
    required this.onBack,
    required this.onClose,
    required this.onSelected,
  });

  final String screenTitle;
  final String screenSubtitle;
  final String titleAll;
  final String searchHint;
  final String? selectedId;
  final List<({String id, String nombre, String? subtitle})> items;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onBack;
  final VoidCallback onClose;
  final ValueChanged<String?> onSelected;

  @override
  State<_SearchableSelectionView> createState() =>
      _SearchableSelectionViewState();
}

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

class _SearchableSelectionViewState extends State<_SearchableSelectionView> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (widget.errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(child: Text('Error: ${widget.errorMessage}')),
      );
    }

    final queryFolded = _fold(_query).trim();
    final tokens =
        queryFolded.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    final filteredItems = widget.items.where((item) {
      if (tokens.isEmpty) return true;
      final itemFolded = _fold(item.nombre);
      final subtitleFolded =
          item.subtitle != null ? _fold(item.subtitle!) : '';
      return tokens.every((token) =>
          itemFolded.contains(token) || subtitleFolded.contains(token));
    }).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 42, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header moderno con navegación y título
          Row(
            children: [
              _BackButton(
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  widget.onBack();
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.screenTitle,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      widget.screenSubtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              _CloseButton(
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  widget.onClose();
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Buscador en vivo
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
            ),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
              decoration: InputDecoration(
                hintText: widget.searchHint,
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.black45, size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18, color: Colors.black45),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Opción "Todas"
          if (_query.isEmpty) ...[
            _SelectionOptionTile(
              title: widget.titleAll,
              isSelected: widget.selectedId == null,
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
                widget.onSelected(null);
              },
            ),
            const SizedBox(height: 6),
          ],

          if (filteredItems.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(Icons.search_off_rounded, size: 40, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text(
                    'No se encontraron coincidencias',
                    style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return _SelectionOptionTile(
                  title: item.nombre,
                  subtitle: item.subtitle,
                  isSelected: widget.selectedId == item.id,
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    widget.onSelected(item.id);
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

class _SelectionOptionTile extends StatelessWidget {
  const _SelectionOptionTile({
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? kMedphePrimary
                  : Colors.black.withValues(alpha: 0.05),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? kMedphePrimary : Colors.black87,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: isSelected
                              ? kMedphePrimary.withValues(alpha: 0.7)
                              : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: isSelected ? kMedphePrimary : Colors.black26,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

