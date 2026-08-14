import 'package:flutter_riverpod/flutter_riverpod.dart';

final favoriteDoctorIdsProvider = StateProvider<Set<String>>((ref) => {});

void toggleFavoriteDoctor(WidgetRef ref, String doctorId) {
  final updated = Set<String>.from(ref.read(favoriteDoctorIdsProvider));
  if (!updated.remove(doctorId)) {
    updated.add(doctorId);
  }
  ref.read(favoriteDoctorIdsProvider.notifier).state = updated;
}
