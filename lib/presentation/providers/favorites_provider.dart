import 'package:flutter_riverpod/flutter_riverpod.dart';

final favoriteDoctorIdsProvider = StateProvider<Set<String>>((ref) => {});
final favoriteCentroMedicoIdsProvider = StateProvider<Set<String>>((ref) => {});

void toggleFavoriteDoctor(dynamic ref, String doctorId) {
  final updated = Set<String>.from(ref.read(favoriteDoctorIdsProvider));
  if (!updated.remove(doctorId)) {
    updated.add(doctorId);
  }
  ref.read(favoriteDoctorIdsProvider.notifier).state = updated;
}

void toggleFavoriteCentroMedico(dynamic ref, String centroId) {
  final updated = Set<String>.from(ref.read(favoriteCentroMedicoIdsProvider));
  if (!updated.remove(centroId)) {
    updated.add(centroId);
  }
  ref.read(favoriteCentroMedicoIdsProvider.notifier).state = updated;
}

