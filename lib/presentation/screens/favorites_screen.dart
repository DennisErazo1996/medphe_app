import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/theme/app_theme.dart';
import '../../domain/entities/centro_medico.dart';
import '../../domain/entities/doctor.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';
import 'doctors_search_delegate.dart';

enum FavoriteTab { doctores, centros }

final favoriteSelectedTabProvider =
    StateProvider<FavoriteTab>((ref) => FavoriteTab.doctores);

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allDoctoresAsync = ref.watch(allDoctorsProvider);
    final allCentrosAsync = ref.watch(allCentrosMedicosProvider);
    final favoriteDoctorIds = ref.watch(favoriteDoctorIdsProvider);
    final favoriteCentroIds = ref.watch(favoriteCentroMedicoIdsProvider);
    final selectedTab = ref.watch(favoriteSelectedTabProvider);

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: _FavoritesHeader(
              selectedTab: selectedTab,
              doctorCount: favoriteDoctorIds.length,
              centroCount: favoriteCentroIds.length,
            ),
          ),
          SliverToBoxAdapter(
            child: _FavoriteTabSelector(
              selectedTab: selectedTab,
              doctorCount: favoriteDoctorIds.length,
              centroCount: favoriteCentroIds.length,
              onTabChanged: (tab) =>
                  ref.read(favoriteSelectedTabProvider.notifier).state = tab,
            ),
          ),
          if (selectedTab == FavoriteTab.doctores)
            allDoctoresAsync.when(
              data: (doctores) {
                final favoritos = doctores
                    .where((d) => favoriteDoctorIds.contains(d.id))
                    .toList();

                if (favoritos.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyFavorites(tab: FavoriteTab.doctores),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                  sliver: SliverList.separated(
                    itemCount: favoritos.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 14),
                    itemBuilder: (context, index) => _DismissibleFavoriteDoctor(
                      doctor: favoritos[index],
                      accent:
                          kCategoryPalette[index % kCategoryPalette.length],
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => SliverFillRemaining(
                hasScrollBody: false,
                child: _ErrorState(
                  onRetry: () => ref.invalidate(allDoctorsProvider),
                ),
              ),
            )
          else
            allCentrosAsync.when(
              data: (centros) {
                final favoritos = centros
                    .where((c) => favoriteCentroIds.contains(c.id))
                    .toList();

                if (favoritos.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyFavorites(tab: FavoriteTab.centros),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                  sliver: SliverList.separated(
                    itemCount: favoritos.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 14),
                    itemBuilder: (context, index) => _DismissibleFavoriteCentro(
                      centro: favoritos[index],
                      accent:
                          kCategoryPalette[index % kCategoryPalette.length],
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => SliverFillRemaining(
                hasScrollBody: false,
                child: _ErrorState(
                  onRetry: () => ref.invalidate(allCentrosMedicosProvider),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FavoritesHeader extends StatelessWidget {
  const _FavoritesHeader({
    required this.selectedTab,
    required this.doctorCount,
    required this.centroCount,
  });

  final FavoriteTab selectedTab;
  final int doctorCount;
  final int centroCount;

  @override
  Widget build(BuildContext context) {
    final currentCount =
        selectedTab == FavoriteTab.doctores ? doctorCount : centroCount;
    final itemTypeLabel =
        selectedTab == FavoriteTab.doctores ? 'médico' : 'centro médico';
    final pluralLabel =
        selectedTab == FavoriteTab.doctores ? 'médicos' : 'centros médicos';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Favoritos',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w800,
                    fontSize: 26,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  currentCount == 0
                      ? 'No hay $pluralLabel guardados'
                      : currentCount == 1
                          ? '1 $itemTypeLabel guardado'
                          : '$currentCount $pluralLabel guardados',
                  style: GoogleFonts.poppins(
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

class _FavoriteTabSelector extends StatelessWidget {
  const _FavoriteTabSelector({
    required this.selectedTab,
    required this.doctorCount,
    required this.centroCount,
    required this.onTabChanged,
  });

  final FavoriteTab selectedTab;
  final int doctorCount;
  final int centroCount;
  final ValueChanged<FavoriteTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            Expanded(
              child: _TabButton(
                label: 'Médicos ($doctorCount)',
                icon: Icons.person_rounded,
                isSelected: selectedTab == FavoriteTab.doctores,
                onTap: () => onTabChanged(FavoriteTab.doctores),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _TabButton(
                label: 'Centros ($centroCount)',
                icon: Icons.local_hospital_rounded,
                isSelected: selectedTab == FavoriteTab.centros,
                onTap: () => onTabChanged(FavoriteTab.centros),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? kMedphePrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: kMedphePrimary.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Envuelve la [DoctorCard] en un [Dismissible] para permitir quitar el
/// favorito con swipe, con opción de deshacer vía SnackBar.
class _DismissibleFavoriteDoctor extends ConsumerWidget {
  const _DismissibleFavoriteDoctor({
    required this.doctor,
    required this.accent,
  });

  final Doctor doctor;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey('favorite-doctor-${doctor.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppColors.favorite.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.heart_broken_rounded, color: AppColors.favorite),
            SizedBox(height: 4),
            Text(
              'Quitar',
              style: TextStyle(
                color: AppColors.favorite,
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

/// Envuelve la [CentroMedicoCard] en un [Dismissible] para permitir quitar el
/// favorito con swipe, con opción de deshacer vía SnackBar.
class _DismissibleFavoriteCentro extends ConsumerWidget {
  const _DismissibleFavoriteCentro({
    required this.centro,
    required this.accent,
  });

  final CentroMedico centro;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey('favorite-centro-${centro.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppColors.favorite.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.heart_broken_rounded, color: AppColors.favorite),
            SizedBox(height: 4),
            Text(
              'Quitar',
              style: TextStyle(
                color: AppColors.favorite,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (_) {
        toggleFavoriteCentroMedico(ref, centro.id);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('${centro.nombre} eliminado de favoritos'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              action: SnackBarAction(
                label: 'Deshacer',
                onPressed: () => toggleFavoriteCentroMedico(ref, centro.id),
              ),
            ),
          );
      },
      child: CentroMedicoCard(centro: centro, accent: accent),
    );
  }
}

class _EmptyFavorites extends ConsumerWidget {
  const _EmptyFavorites({required this.tab});

  final FavoriteTab tab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDoctors = tab == FavoriteTab.doctores;

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
                isDoctors
                    ? Icons.favorite_border_rounded
                    : Icons.local_hospital_outlined,
                size: 44,
                color: kMedpheSecondary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isDoctors
                  ? 'Aún no tienes médicos favoritos'
                  : 'Aún no tienes centros favoritos',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isDoctors
                  ? 'Guarda a tus médicos de confianza tocando el corazón y encuéntralos aquí al instante.'
                  : 'Guarda tus hospitales y clínicas preferidos tocando el corazón y encuéntralos aquí al instante.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.grey.shade600,
                fontSize: 13.5,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                if (isDoctors) {
                  openDoctorsSearch(context, ref);
                } else {
                  context.push('/centros-medicos');
                }
              },
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
              icon: Icon(
                isDoctors ? Icons.search_rounded : Icons.explore_outlined,
                size: 20,
              ),
              label: Text(
                isDoctors ? 'Buscar médicos' : 'Explorar centros médicos',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
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
            Text(
              'Ocurrió un error',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'No pudimos cargar tus favoritos. Revisa tu conexión e inténtalo de nuevo.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: Text(
                'Reintentar',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
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
