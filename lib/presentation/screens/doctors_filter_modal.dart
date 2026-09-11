import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../config/theme/app_theme.dart';
import '../providers/providers.dart';

Future<void> showDoctorsFilterModal(BuildContext context, WidgetRef ref) {
  final pageIndexNotifier = ValueNotifier<int>(0);

  return WoltModalSheet.show<void>(
    context: context,
    useSafeArea: true,
    pageIndexNotifier: pageIndexNotifier,
    pageListBuilder: (modalContext) {
      return [
        // Página 0: Filtros principales
        WoltModalSheetPage(
          backgroundColor: kMedpheSurface,
          surfaceTintColor: Colors.transparent,
          hasTopBarLayer: true,
          isTopBarLayerAlwaysVisible: true,
          topBarTitle: const Text(
            'Filtros',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          trailingNavBarWidget: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _CloseButton(onPressed: () => Navigator.of(modalContext).pop()),
          ),
          stickyActionBar: const _FilterActionBar(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 140),
            child: _DoctorsFilterForm(pageIndexNotifier: pageIndexNotifier),
          ),
        ),

        // Página 1: Selector de Especialidad con buscador
        WoltModalSheetPage(
          backgroundColor: kMedpheSurface,
          surfaceTintColor: Colors.transparent,
          hasTopBarLayer: true,
          isTopBarLayerAlwaysVisible: true,
          topBarTitle: const Text(
            'Especialidad',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          leadingNavBarWidget: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: _BackButton(onPressed: () => pageIndexNotifier.value = 0),
          ),
          trailingNavBarWidget: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _CloseButton(onPressed: () => Navigator.of(modalContext).pop()),
          ),
          child: _SpecialtySelectionView(
            onSelected: (id) {
              final filter = ref.read(doctorsSearchFilterProvider);
              ref.read(doctorsSearchFilterProvider.notifier).state =
                  filter.copyWith(especialidadId: () => id);
              pageIndexNotifier.value = 0;
            },
          ),
        ),

        // Página 2: Selector de Ciudad con buscador
        WoltModalSheetPage(
          backgroundColor: kMedpheSurface,
          surfaceTintColor: Colors.transparent,
          hasTopBarLayer: true,
          isTopBarLayerAlwaysVisible: true,
          topBarTitle: const Text(
            'Ciudad',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          leadingNavBarWidget: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: _BackButton(onPressed: () => pageIndexNotifier.value = 0),
          ),
          trailingNavBarWidget: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _CloseButton(onPressed: () => Navigator.of(modalContext).pop()),
          ),
          child: _CitySelectionView(
            onSelected: (id) {
              final filter = ref.read(doctorsSearchFilterProvider);
              ref.read(doctorsSearchFilterProvider.notifier).state =
                  filter.copyWith(ciudadId: () => id);
              pageIndexNotifier.value = 0;
            },
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
          child: Icon(Icons.close, size: 20, color: Colors.black54),
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
          child: Icon(Icons.arrow_back_rounded, size: 20, color: Colors.black54),
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
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
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
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
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
    final filter = ref.watch(doctorsSearchFilterProvider);

    final especialidadSeleccionada = especialidadesAsync.asData?.value
        .where((e) => e.id == filter.especialidadId)
        .firstOrNull;
    final nombreEspecialidad = especialidadSeleccionada?.nombre;

    final ciudadSeleccionada = ciudadesAsync.asData?.value
        .where((c) => c.id == filter.ciudadId)
        .firstOrNull;
    final nombreCiudad = ciudadSeleccionada?.nombre;

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
                      style: TextStyle(
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
                      style: TextStyle(
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
  const _SpecialtySelectionView({required this.onSelected});

  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final especialidadesAsync = ref.watch(especialidadesProvider);
    final filter = ref.watch(doctorsSearchFilterProvider);

    return especialidadesAsync.when(
      data: (especialidades) => _SearchableSelectionView(
        titleAll: 'Todas las especialidades',
        searchHint: 'Buscar especialidad...',
        selectedId: filter.especialidadId,
        items: [
          for (final e in especialidades) (id: e.id, nombre: e.nombre),
        ],
        isLoading: false,
        errorMessage: null,
        onSelected: onSelected,
      ),
      loading: () => _SearchableSelectionView(
        titleAll: 'Todas las especialidades',
        searchHint: 'Buscar especialidad...',
        selectedId: null,
        items: const [],
        isLoading: true,
        errorMessage: null,
        onSelected: onSelected,
      ),
      error: (error, _) => _SearchableSelectionView(
        titleAll: 'Todas las especialidades',
        searchHint: 'Buscar especialidad...',
        selectedId: null,
        items: const [],
        isLoading: false,
        errorMessage: error.toString(),
        onSelected: onSelected,
      ),
    );
  }
}

class _CitySelectionView extends ConsumerWidget {
  const _CitySelectionView({required this.onSelected});

  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ciudadesAsync = ref.watch(ciudadesProvider);
    final filter = ref.watch(doctorsSearchFilterProvider);

    return ciudadesAsync.when(
      data: (ciudades) => _SearchableSelectionView(
        titleAll: 'Todas las ciudades',
        searchHint: 'Buscar ciudad...',
        selectedId: filter.ciudadId,
        items: [
          for (final c in ciudades) (id: c.id, nombre: c.nombre),
        ],
        isLoading: false,
        errorMessage: null,
        onSelected: onSelected,
      ),
      loading: () => _SearchableSelectionView(
        titleAll: 'Todas las ciudades',
        searchHint: 'Buscar ciudad...',
        selectedId: null,
        items: const [],
        isLoading: true,
        errorMessage: null,
        onSelected: onSelected,
      ),
      error: (error, _) => _SearchableSelectionView(
        titleAll: 'Todas las ciudades',
        searchHint: 'Buscar ciudad...',
        selectedId: null,
        items: [],
        isLoading: false,
        errorMessage: error.toString(),
        onSelected: onSelected,
      ),
    );
  }
}

class _SearchableSelectionView extends StatefulWidget {
  const _SearchableSelectionView({
    required this.titleAll,
    required this.searchHint,
    required this.selectedId,
    required this.items,
    required this.isLoading,
    required this.errorMessage,
    required this.onSelected,
  });

  final String titleAll;
  final String searchHint;
  final String? selectedId;
  final List<({String id, String nombre})> items;
  final bool isLoading;
  final String? errorMessage;
  final ValueChanged<String?> onSelected;

  @override
  State<_SearchableSelectionView> createState() =>
      _SearchableSelectionViewState();
}

class _SearchableSelectionViewState extends State<_SearchableSelectionView> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.trim().toLowerCase();
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

    final filteredItems = widget.items.where((item) {
      if (_query.isEmpty) return true;
      return item.nombre.toLowerCase().contains(_query);
    }).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Buscador en vivo
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: widget.searchHint,
                hintStyle: TextStyle(
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
              onTap: () => widget.onSelected(null),
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
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
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
                  isSelected: widget.selectedId == item.id,
                  onTap: () => widget.onSelected(item.id),
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
  });

  final String title;
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
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? kMedphePrimary : Colors.black87,
                  ),
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

