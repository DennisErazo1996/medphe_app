import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../config/theme/app_theme.dart';
import '../providers/providers.dart';

Future<void> showDoctorsFilterModal(BuildContext context, WidgetRef ref) {
  return WoltModalSheet.show<void>(
    context: context,
    useSafeArea: true,
    pageListBuilder: (modalContext) {
      return [
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
          child: const Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 140),
            child: _DoctorsFilterForm(),
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
  const _DoctorsFilterForm();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final especialidadesAsync = ref.watch(especialidadesProvider);
    final ciudadesAsync = ref.watch(ciudadesProvider);
    final filter = ref.watch(doctorsSearchFilterProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FilterSectionHeader(
          icon: Icons.medical_services_outlined,
          title: 'Especialidad',
        ),
        const SizedBox(height: 12),
        especialidadesAsync.when(
          data: (especialidades) => _ChipGroup(
            selectedId: filter.especialidadId,
            options: [
              for (final e in especialidades) (id: e.id, nombre: e.nombre),
            ],
            onSelected: (value) {
              ref.read(doctorsSearchFilterProvider.notifier).state = filter
                  .copyWith(especialidadId: () => value);
            },
          ),
          loading: () => const _ChipGroupSkeleton(),
          error: (error, stackTrace) => Text('Error: $error'),
        ),
        const SizedBox(height: 24),
        const _FilterSectionHeader(
          icon: Icons.location_on_outlined,
          title: 'Ciudad',
        ),
        const SizedBox(height: 12),
        ciudadesAsync.when(
          data: (ciudades) => _ChipGroup(
            selectedId: filter.ciudadId,
            options: [for (final c in ciudades) (id: c.id, nombre: c.nombre)],
            onSelected: (value) {
              ref.read(doctorsSearchFilterProvider.notifier).state = filter
                  .copyWith(ciudadId: () => value);
            },
          ),
          loading: () => const _ChipGroupSkeleton(),
          error: (error, stackTrace) => Text('Error: $error'),
        ),
      ],
    );
  }
}

class _FilterSectionHeader extends StatelessWidget {
  const _FilterSectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: kMedphePrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: kMedphePrimary),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ],
    );
  }
}

/// Nube de chips de selección única. Incluye siempre la opción "Todas"
/// (id nulo) al inicio.
class _ChipGroup extends StatelessWidget {
  const _ChipGroup({
    required this.selectedId,
    required this.options,
    required this.onSelected,
  });

  final String? selectedId;
  final List<({String id, String nombre})> options;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _FilterChip(
          label: 'Todas',
          selected: selectedId == null,
          onTap: () => onSelected(null),
        ),
        for (final option in options)
          _FilterChip(
            label: option.nombre,
            selected: selectedId == option.id,
            onTap: () => onSelected(option.id),
          ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: selected ? kMedphePrimary : Colors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: selected
              ? kMedphePrimary
              : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected) ...[
                  const Icon(Icons.check, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Placeholder de carga con forma de chips para evitar saltos de layout.
class _ChipGroupSkeleton extends StatelessWidget {
  const _ChipGroupSkeleton();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final width in const [72.0, 104.0, 88.0, 120.0])
          Container(
            width: width,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
      ],
    );
  }
}
