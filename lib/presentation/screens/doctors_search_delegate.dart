import 'package:flutter/material.dart';

class DoctorsSearchDelegate extends SearchDelegate<String?> {
  DoctorsSearchDelegate({required this.onSubmit});

  final void Function(String nombre) onSubmit;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
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
