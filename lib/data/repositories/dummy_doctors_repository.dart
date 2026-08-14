import '../../domain/entities/ciudad.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/entities/especialidad.dart';
import '../datasources/doctors_dummy_datasource.dart';
import 'doctors_repository.dart';

class DummyDoctorsRepository implements DoctorsRepository {
  static const _latencia = Duration(milliseconds: 500);

  @override
  Future<List<Especialidad>> getEspecialidades() async {
    await Future.delayed(_latencia);
    return especialidadesDummy;
  }

  @override
  Future<List<Ciudad>> getCiudades() async {
    await Future.delayed(_latencia);
    return ciudadesDummy;
  }

  @override
  Future<List<Doctor>> searchDoctors({
    String? especialidadId,
    String? ciudadId,
    String? nombre,
  }) async {
    await Future.delayed(_latencia);
    final nombreBusqueda = nombre?.trim().toLowerCase();
    return doctoresDummy.where((doctor) {
      final coincideEspecialidad =
          especialidadId == null ||
          doctor.especialidades.any((e) => e.id == especialidadId);
      final coincideCiudad = ciudadId == null || doctor.ciudad.id == ciudadId;
      final coincideNombre =
          nombreBusqueda == null ||
          nombreBusqueda.isEmpty ||
          doctor.nombre.toLowerCase().contains(nombreBusqueda);
      return coincideEspecialidad && coincideCiudad && coincideNombre;
    }).toList();
  }

  @override
  Future<Doctor> getDoctorById(String id) async {
    await Future.delayed(_latencia);
    return doctoresDummy.firstWhere((doctor) => doctor.id == id);
  }
}
