import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_theme.dart';
import 'doctors_search_delegate.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';

/// Contenedor raíz con bottom navigation: Inicio y Favoritos son pestañas
/// reales (IndexedStack); Buscar es una acción que abre el buscador sin
/// cambiar de pestaña.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMedpheSurface,
      body: IndexedStack(
        index: _index,
        children: const [HomeScreen(), FavoritesScreen()],
      ),
      bottomNavigationBar: _MedpheBottomNav(
        currentIndex: _index,
        onHome: () => setState(() => _index = 0),
        onSearch: () => openDoctorsSearch(context, ref),
        onFavorites: () => setState(() => _index = 1),
      ),
    );
  }
}

class _MedpheBottomNav extends StatelessWidget {
  const _MedpheBottomNav({
    required this.currentIndex,
    required this.onHome,
    required this.onSearch,
    required this.onFavorites,
  });

  final int currentIndex;
  final VoidCallback onHome;
  final VoidCallback onSearch;
  final VoidCallback onFavorites;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: kMedphePrimary.withValues(alpha: 0.14),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Inicio',
                selected: currentIndex == 0,
                onTap: onHome,
              ),
              _NavItem(
                icon: Icons.search_rounded,
                label: 'Buscar',
                selected: false,
                onTap: onSearch,
              ),
              _NavItem(
                icon: Icons.favorite_rounded,
                label: 'Favoritos',
                selected: currentIndex == 1,
                onTap: onFavorites,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? kMedphePrimary : Colors.grey.shade400;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: selected ? 18 : 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected ? kMedphePrimary.withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            if (selected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
