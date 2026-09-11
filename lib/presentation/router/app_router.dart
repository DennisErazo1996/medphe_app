import 'package:go_router/go_router.dart';

import '../pages/pages.dart';
import '../screens/screens.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeShell()),
    GoRoute(
      path: '/doctors/:id',
      builder: (context, state) =>
          DoctorProfilePage(doctorId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/centros-medicos',
      builder: (context, state) => const CentrosMedicosScreen(),
    ),
    GoRoute(
      path: '/centros-medicos/:id',
      builder: (context, state) =>
          CentroMedicoDetailPage(centroId: state.pathParameters['id']!),
    ),
  ],
);
