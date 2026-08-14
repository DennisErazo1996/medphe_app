import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/doctor.dart';
import '../../domain/entities/especialidad.dart';
import '../theme/app_theme.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';
import 'doctors_filter_modal.dart';
import 'doctors_search_delegate.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  bool _tieneFiltroActivo(DoctorsSearchFilter filter) {
    return filter.especialidadId != null ||
        filter.ciudadId != null ||
        (filter.nombre != null && filter.nombre!.isNotEmpty);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(doctorsSearchResultsProvider);
    final filter = ref.watch(doctorsSearchFilterProvider);
    final tieneFiltro = _tieneFiltroActivo(filter);

    return resultsAsync.when(
      data: (doctores) {
        if (tieneFiltro) {
          return _FilteredResults(doctores: doctores);
        }
        return _HomeContent(doctores: doctores);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => _ErrorState(
        onRetry: () => ref.invalidate(doctorsSearchResultsProvider),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Ocurrió un error'),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}

class _FilteredResults extends ConsumerWidget {
  const _FilteredResults({required this.doctores});

  final List<Doctor> doctores;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 20, 8),
            child: Row(
              children: [
                CircleIconButton(
                  icon: Icons.close,
                  onPressed: () {
                    ref.read(doctorsSearchFilterProvider.notifier).state =
                        const DoctorsSearchFilter();
                  },
                ),
                const Expanded(
                  child: Text(
                    'Resultados',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
                CircleIconButton(
                  icon: Icons.tune,
                  onPressed: () => showDoctorsFilterModal(context, ref),
                ),
              ],
            ),
          ),
          Expanded(
            child: doctores.isEmpty
                ? const EmptyState(
                    icon: Icons.search_off,
                    title: 'Sin resultados',
                    message: 'Intenta con otra especialidad, ciudad o nombre.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: doctores.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) => DoctorCard(
                      doctor: doctores[index],
                      accent: kCategoryPalette[index % kCategoryPalette.length],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({required this.doctores});

  final List<Doctor> doctores;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final especialidadesAsync = ref.watch(especialidadesProvider);
    final destacados = doctores.take(6).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _HomeHeader(ref: ref)),
        const SliverToBoxAdapter(
          child: _SectionHeader(title: 'Especialidades'),
        ),
        SliverToBoxAdapter(
          child: especialidadesAsync.when(
            data: (especialidades) =>
                _SpecialtyCarousel(especialidades: especialidades, ref: ref),
            loading: () => const SizedBox(
              height: 96,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stackTrace) => const SizedBox.shrink(),
          ),
        ),
        const SliverToBoxAdapter(
          child: _SectionHeader(title: 'Médicos destacados'),
        ),
        SliverToBoxAdapter(
          child: _FeaturedDoctorsCarousel(doctores: destacados),
        ),
        const SliverToBoxAdapter(
          child: _SectionHeader(title: 'Todos los médicos'),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          sliver: SliverList.separated(
            itemCount: doctores.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => DoctorCard(
              doctor: doctores[index],
              accent: kCategoryPalette[index % kCategoryPalette.length],
            ),
          ),
        ),
      ],
    );
  }
}

/// Bloque de color sólido a modo de portada — el elemento distintivo de la
/// pantalla, con saludo y buscador integrados. El resto de la pantalla se
/// mantiene tranquilo (superficie lavanda + tarjetas blancas) para que este
/// bloque destaque.
class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kMedphePrimary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Medphe',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                  _HeaderIconButton(
                    icon: Icons.tune,
                    onPressed: () => showDoctorsFilterModal(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Encuentra a tu\nespecialista ideal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Médicos verificados, agenda de citas y atención cerca de ti.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
              ),
              const SizedBox(height: 18),
              _SearchPill(ref: ref),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.16),
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}

class _SearchPill extends StatelessWidget {
  const _SearchPill({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => openDoctorsSearch(context, ref),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.black38),
              SizedBox(width: 10),
              Text(
                'Busca por nombre o especialidad',
                style: TextStyle(color: Colors.black38, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _SpecialtyCarousel extends StatelessWidget {
  const _SpecialtyCarousel({required this.especialidades, required this.ref});

  final List<Especialidad> especialidades;
  final WidgetRef ref;

  static const _icons = [
    Icons.favorite_outline,
    Icons.child_care_outlined,
    Icons.spa_outlined,
    Icons.pregnant_woman_outlined,
    Icons.psychology_outlined,
    Icons.medical_services_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    if (especialidades.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: especialidades.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final especialidad = especialidades[index];
          final icon = _icons[index % _icons.length];
          final color = kCategoryPalette[index % kCategoryPalette.length];
          return _SpecialtyTile(
            nombre: especialidad.nombre,
            icon: icon,
            color: color,
            onTap: () {
              final current = ref.read(doctorsSearchFilterProvider);
              ref.read(doctorsSearchFilterProvider.notifier).state = current
                  .copyWith(especialidadId: () => especialidad.id);
            },
          );
        },
      ),
    );
  }
}

class _SpecialtyTile extends StatelessWidget {
  const _SpecialtyTile({
    required this.nombre,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String nombre;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 84,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              nombre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedDoctorsCarousel extends StatelessWidget {
  const _FeaturedDoctorsCarousel({required this.doctores});

  final List<Doctor> doctores;

  @override
  Widget build(BuildContext context) {
    if (doctores.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 216,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: doctores.length,
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) => _FeaturedDoctorCard(
          doctor: doctores[index],
          accent: kCategoryPalette[index % kCategoryPalette.length],
        ),
      ),
    );
  }
}

class _FeaturedDoctorCard extends ConsumerWidget {
  const _FeaturedDoctorCard({required this.doctor, required this.accent});

  final Doctor doctor;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorito = ref
        .watch(favoriteDoctorIdsProvider)
        .contains(doctor.id);

    return InkWell(
      onTap: () => context.push('/doctors/${doctor.id}'),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: SizedBox(
                    width: 160,
                    height: 110,
                    child: doctor.fotoUrl != null
                        ? Image.network(doctor.fotoUrl!, fit: BoxFit.cover)
                        : Container(
                            color: accent.withValues(alpha: 0.12),
                            child: Icon(Icons.person, color: accent, size: 40),
                          ),
                  ),
                ),
                Positioned(
                  right: 6,
                  top: 6,
                  child: InkWell(
                    onTap: () => toggleFavoriteDoctor(ref, doctor.id),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorito ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: isFavorito ? kMedpheHeartColor : Colors.black26,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor.especialidades.isNotEmpty
                        ? doctor.especialidades.first.nombre
                        : '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          doctor.ciudad.nombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
