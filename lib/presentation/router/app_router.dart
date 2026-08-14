import 'package:go_router/go_router.dart';

import '../pages/pages.dart';
import '../screens/screens.dart';

final appRouter = GoRouter(
  initialLocation: '/doctors',
  routes: [
    GoRoute(
      path: '/doctors',
      builder: (context, state) => const DoctorsListScreen(),
    ),
    GoRoute(
      path: '/doctors/:id',
      builder: (context, state) => DoctorProfilePage(
        doctorId: state.pathParameters['id']!,
      ),
    ),
  ],
);
