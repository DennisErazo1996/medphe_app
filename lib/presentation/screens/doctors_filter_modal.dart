import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../providers/providers.dart';

Future<void> showDoctorsFilterModal(BuildContext context, WidgetRef ref) {
  return WoltModalSheet.show<void>(
    context: context,
    pageListBuilder: (modalContext) {
      return [
        WoltModalSheetPage(
          topBarTitle: const Text('Filtrar médicos'),
          isTopBarLayerAlwaysVisible: true,
          trailingNavBarWidget: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(modalContext).pop(),
          ),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: _DoctorsFilterForm(),
          ),
        ),
      ];
    },
  );
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        especialidadesAsync.when(
          data: (especialidades) => DropdownButtonFormField<String?>(
            initialValue: filter.especialidadId,
            decoration: const InputDecoration(labelText: 'Especialidad'),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Todas'),
              ),
              ...especialidades.map(
                (e) => DropdownMenuItem<String?>(
                  value: e.id,
                  child: Text(e.nombre),
                ),
              ),
            ],
            onChanged: (value) {
              ref.read(doctorsSearchFilterProvider.notifier).state =
                  filter.copyWith(especialidadId: () => value);
            },
          ),
          loading: () => const LinearProgressIndicator(),
          error: (error, stackTrace) => Text('Error: $error'),
        ),
        const SizedBox(height: 16),
        ciudadesAsync.when(
          data: (ciudades) => DropdownButtonFormField<String?>(
            initialValue: filter.ciudadId,
            decoration: const InputDecoration(labelText: 'Ciudad'),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Todas'),
              ),
              ...ciudades.map(
                (c) => DropdownMenuItem<String?>(
                  value: c.id,
                  child: Text(c.nombre),
                ),
              ),
            ],
            onChanged: (value) {
              ref.read(doctorsSearchFilterProvider.notifier).state =
                  filter.copyWith(ciudadId: () => value);
            },
          ),
          loading: () => const LinearProgressIndicator(),
          error: (error, stackTrace) => Text('Error: $error'),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Aplicar filtros'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            ref.read(doctorsSearchFilterProvider.notifier).state =
                const DoctorsSearchFilter();
            Navigator.of(context).pop();
          },
          child: const Text('Limpiar filtros'),
        ),
      ],
    );
  }
}
