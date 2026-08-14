import '../../domain/entities/ciudad.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/entities/especialidad.dart';

abstract class DoctorsRepository {
  Future<List<Especialidad>> getEspecialidades();

  Future<List<Ciudad>> getCiudades();

  Future<List<Doctor>> searchDoctors({
    String? especialidadId,
    String? ciudadId,
    String? nombre,
  });

  Future<Doctor> getDoctorById(String id);
}
