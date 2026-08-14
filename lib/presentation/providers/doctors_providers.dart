import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/doctors_repository.dart';
import '../../data/repositories/dummy_doctors_repository.dart';
import '../../domain/entities/ciudad.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/entities/especialidad.dart';

final doctorsRepositoryProvider = Provider<DoctorsRepository>((ref) {
  return DummyDoctorsRepository();
});

final especialidadesProvider = FutureProvider<List<Especialidad>>((ref) {
  return ref.watch(doctorsRepositoryProvider).getEspecialidades();
});

final ciudadesProvider = FutureProvider<List<Ciudad>>((ref) {
  return ref.watch(doctorsRepositoryProvider).getCiudades();
});

final allDoctorsProvider = FutureProvider<List<Doctor>>((ref) {
  return ref.watch(doctorsRepositoryProvider).searchDoctors();
});

class DoctorsSearchFilter {
  const DoctorsSearchFilter({this.especialidadId, this.ciudadId, this.nombre});

  final String? especialidadId;
  final String? ciudadId;
  final String? nombre;

  DoctorsSearchFilter copyWith({
    String? Function()? especialidadId,
    String? Function()? ciudadId,
    String? Function()? nombre,
  }) {
    return DoctorsSearchFilter(
      especialidadId: especialidadId != null
          ? especialidadId()
          : this.especialidadId,
      ciudadId: ciudadId != null ? ciudadId() : this.ciudadId,
      nombre: nombre != null ? nombre() : this.nombre,
    );
  }
}

final doctorsSearchFilterProvider = StateProvider<DoctorsSearchFilter>(
  (ref) => const DoctorsSearchFilter(),
);

final doctorsSearchResultsProvider = FutureProvider<List<Doctor>>((ref) {
  final filter = ref.watch(doctorsSearchFilterProvider);
  return ref
      .watch(doctorsRepositoryProvider)
      .searchDoctors(
        especialidadId: filter.especialidadId,
        ciudadId: filter.ciudadId,
        nombre: filter.nombre,
      );
});

final doctorByIdProvider = FutureProvider.family<Doctor, String>((ref, id) {
  return ref.watch(doctorsRepositoryProvider).getDoctorById(id);
});
