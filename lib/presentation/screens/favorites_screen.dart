import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allDoctoresAsync = ref.watch(allDoctorsProvider);
    final favoriteIds = ref.watch(favoriteDoctorIdsProvider);

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Text(
              'Favoritos',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
            ),
          ),
          Expanded(
            child: allDoctoresAsync.when(
              data: (doctores) {
                final favoritos = doctores
                    .where((d) => favoriteIds.contains(d.id))
                    .toList();
                if (favoritos.isEmpty) {
                  return const EmptyState(
                    icon: Icons.favorite_border,
                    title: 'Aún no tienes favoritos',
                    message:
                        'Toca el corazón en un médico para guardarlo aquí.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  itemCount: favoritos.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) => DoctorCard(
                    doctor: favoritos[index],
                    accent: kCategoryPalette[index % kCategoryPalette.length],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Ocurrió un error'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(allDoctorsProvider),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
