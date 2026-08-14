import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/doctor.dart';
import '../../domain/entities/especialidad.dart';
import '../../main.dart';
import '../providers/providers.dart';
import 'doctors_filter_modal.dart';
import 'doctors_search_delegate.dart';

class DoctorsListScreen extends ConsumerWidget {
  const DoctorsListScreen({super.key});

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

    if (tieneFiltro) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Resultados'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              ref.read(doctorsSearchFilterProvider.notifier).state =
                  const DoctorsSearchFilter();
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.tune),
              onPressed: () => showDoctorsFilterModal(context, ref),
            ),
          ],
        ),
        body: resultsAsync.when(
          data: (doctores) => doctores.isEmpty
              ? const _EmptyState()
              : _ResultadosList(doctores: doctores),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              _ErrorState(onRetry: () => ref.invalidate(doctorsSearchResultsProvider)),
        ),
      );
    }

    return Scaffold(
      body: resultsAsync.when(
        data: (doctores) => _HomeContent(doctores: doctores),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            _ErrorState(onRetry: () => ref.invalidate(doctorsSearchResultsProvider)),
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
        SliverToBoxAdapter(
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
        SliverToBoxAdapter(
          child: _SectionHeader(title: 'Médicos destacados'),
        ),
        SliverToBoxAdapter(
          child: _FeaturedDoctorsCarousel(doctores: destacados),
        ),
        SliverToBoxAdapter(
          child: _SectionHeader(title: 'Todos los médicos'),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          sliver: SliverList.separated(
            itemCount: doctores.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                _DoctorCard(doctor: doctores[index], accent: kCategoryPalette[index % kCategoryPalette.length]),
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
        onTap: () {
          showSearch<String?>(
            context: context,
            delegate: DoctorsSearchDelegate(
              onSubmit: (nombre) {
                final current = ref.read(doctorsSearchFilterProvider);
                ref.read(doctorsSearchFilterProvider.notifier).state =
                    current.copyWith(nombre: () => nombre);
              },
            ),
          );
        },
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

class _FeaturedDoctorCard extends StatelessWidget {
  const _FeaturedDoctorCard({required this.doctor, required this.accent});

  final Doctor doctor;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/doctors/${doctor.id}'),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border(left: BorderSide(color: accent, width: 3)),
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
            CircleAvatar(
              radius: 32,
              backgroundColor: accent.withValues(alpha: 0.12),
              backgroundImage: doctor.fotoUrl != null
                  ? NetworkImage(doctor.fotoUrl!)
                  : null,
              child: doctor.fotoUrl == null
                  ? Icon(Icons.person, color: accent)
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              doctor.nombre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
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
            const Spacer(),
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
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultadosList extends StatelessWidget {
  const _ResultadosList({required this.doctores});

  final List<Doctor> doctores;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: doctores.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _DoctorCard(
        doctor: doctores[index],
        accent: kCategoryPalette[index % kCategoryPalette.length],
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({required this.doctor, required this.accent});

  final Doctor doctor;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/doctors/${doctor.id}'),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border(left: BorderSide(color: accent, width: 3)),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.1),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: accent.withValues(alpha: 0.12),
              backgroundImage: doctor.fotoUrl != null
                  ? NetworkImage(doctor.fotoUrl!)
                  : null,
              child: doctor.fotoUrl == null
                  ? Icon(Icons.person, color: accent)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor.especialidades.map((e) => e.nombre).join(', '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        doctor.ciudad.nombre,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Sin resultados',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Intenta con otra especialidad, ciudad o nombre.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
