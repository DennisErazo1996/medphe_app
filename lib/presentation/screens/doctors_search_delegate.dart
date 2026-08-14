import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';

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

class DoctorsSearchDelegate extends SearchDelegate<String?> {
  DoctorsSearchDelegate({required this.onSubmit});

  final void Function(String nombre) onSubmit;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
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
    return Center(
      child: TextButton(
        onPressed: () {
          onSubmit(query);
          close(context, query);
        },
        child: const Text('Buscar'),
      ),
    );
  }
}
