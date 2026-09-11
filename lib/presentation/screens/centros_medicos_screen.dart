import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/theme/app_theme.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';
import 'doctors_search_delegate.dart';

final selectedCityFilterProvider = StateProvider<String?>((ref) => null);

class CentrosMedicosScreen extends ConsumerWidget {
  const CentrosMedicosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final centrosAsync = ref.watch(allCentrosMedicosProvider);
    final selectedCity = ref.watch(selectedCityFilterProvider);

    return Scaffold(
      backgroundColor: kMedpheSurface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Center(
          child: CircleIconButton(
            icon: Icons.arrow_back,
            onPressed: () => context.pop(),
          ),
        ),
        title: Text(
          'Centros Médicos',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: CircleIconButton(
              icon: Icons.search_rounded,
              onPressed: () => openDoctorsSearch(context, ref),
            ),
          ),
        ],
      ),
      body: centrosAsync.when(
        data: (centros) {
          final ciudades = <String>{
            for (final c in centros)
              if (c.ciudad.nombre.isNotEmpty) c.ciudad.nombre,
          }.toList()..sort();

          final filtrados = selectedCity == null
              ? centros
              : centros.where((c) => c.ciudad.nombre == selectedCity).toList();

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(allCentrosMedicosProvider),
            child: CustomScrollView(
              slivers: [
                if (ciudades.isNotEmpty)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 52,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        children: [
                          _CityChip(
                            label: 'Todos (${centros.length})',
                            isSelected: selectedCity == null,
                            onTap: () => ref
                                .read(selectedCityFilterProvider.notifier)
                                .state = null,
                          ),
                          const SizedBox(width: 8),
                          for (final ciudad in ciudades) ...[
                            _CityChip(
                              label: ciudad,
                              isSelected: selectedCity == ciudad,
                              onTap: () => ref
                                  .read(selectedCityFilterProvider.notifier)
                                  .state = ciudad,
                            ),
                            const SizedBox(width: 8),
                          ],
                        ],
                      ),
                    ),
                  ),
                if (filtrados.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: EmptyState(
                        icon: Icons.location_city_outlined,
                        title: 'No hay centros médicos',
                        message: 'No encontramos centros en esta ciudad.',
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final centro = filtrados[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: CentroMedicoCard(
                              centro: centro,
                              accent: kCategoryPalette[
                                  index % kCategoryPalette.length],
                            ),
                          );
                        },
                        childCount: filtrados.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error al cargar centros médicos: $error'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.refresh(allCentrosMedicosProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CityChip extends StatelessWidget {
  const _CityChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? kMedphePrimary : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected
                ? kMedphePrimary
                : Colors.black.withValues(alpha: 0.08),
          ),
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
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }
}
