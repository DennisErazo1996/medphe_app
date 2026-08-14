import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/doctor.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'doctors_search_delegate.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allDoctoresAsync = ref.watch(allDoctorsProvider);
    final favoriteIds = ref.watch(favoriteDoctorIdsProvider);

    return SafeArea(
      bottom: false,
      child: allDoctoresAsync.when(
        data: (doctores) {
          final favoritos = doctores
              .where((d) => favoriteIds.contains(d.id))
              .toList();
          return CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(child: _FavoritesHeader(count: favoritos.length)),
              if (favoritos.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyFavorites(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                  sliver: SliverList.separated(
                    itemCount: favoritos.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 14),
                    itemBuilder: (context, index) => _DismissibleFavorite(
                      doctor: favoritos[index],
                      accent:
                          kCategoryPalette[index % kCategoryPalette.length],
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _ErrorState(
          onRetry: () => ref.invalidate(allDoctorsProvider),
        ),
      ),
    );
  }
}

class _FavoritesHeader extends StatelessWidget {
  const _FavoritesHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Favoritos',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 26),
                ),
                const SizedBox(height: 2),
                Text(
                  count == 0
                      ? 'Tu lista está vacía'
                      : count == 1
                          ? '1 médico guardado'
                          : '$count médicos guardados',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [kMedphePrimary, kMedpheSecondary],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: kMedpheSecondary.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

/// Envuelve la [DoctorCard] en un [Dismissible] para permitir quitar el
/// favorito con swipe, con opción de deshacer vía SnackBar.
class _DismissibleFavorite extends ConsumerWidget {
  const _DismissibleFavorite({required this.doctor, required this.accent});

  final Doctor doctor;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey('favorite-${doctor.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: kMedpheHeartColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.heart_broken_rounded, color: kMedpheHeartColor),
            SizedBox(height: 4),
            Text(
              'Quitar',
              style: TextStyle(
                color: kMedpheHeartColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (_) {
        toggleFavoriteDoctor(ref, doctor.id);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('${doctor.nombre} eliminado de favoritos'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              action: SnackBarAction(
                label: 'Deshacer',
                onPressed: () => toggleFavoriteDoctor(ref, doctor.id),
              ),
            ),
          );
      },
      child: DoctorCard(doctor: doctor, accent: accent),
    );
  }
}

class _EmptyFavorites extends ConsumerWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 0, 40, 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    kMedphePrimary.withValues(alpha: 0.10),
                    kMedpheSecondary.withValues(alpha: 0.10),
                  ],
                ),
              ),
              child: Icon(
                Icons.favorite_border_rounded,
                size: 44,
                color: kMedpheSecondary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aún no tienes favoritos',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
            ),
            const SizedBox(height: 8),
            Text(
              'Guarda a tus médicos de confianza tocando el corazón y encuéntralos aquí al instante.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13.5,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => openDoctorsSearch(context, ref),
              style: FilledButton.styleFrom(
                backgroundColor: kMedphePrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.search_rounded, size: 20),
              label: const Text(
                'Buscar médicos',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 44,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Ocurrió un error',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              'No pudimos cargar tus favoritos. Revisa tu conexión e inténtalo de nuevo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
