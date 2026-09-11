import '../../data/repositories/doctors_repository.dart';
import '../../domain/entities/ciudad.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/entities/especialidad.dart';
import '../datasources/especialistas_api_datasource.dart';
import '../mappers/especialista_mapper.dart';

/// Implementación de [DoctorsRepository] contra el backend real.
///
/// Solo existe el endpoint `/doctors`, así que especialidades y ciudades se
/// derivan de la lista de especialistas y el filtrado se hace en cliente.
/// La lista se cachea en memoria para no repetir la petición por cada
/// provider que consulta.
class ApiDoctorsRepository implements DoctorsRepository {
  ApiDoctorsRepository(this._datasource);

  final EspecialistasApiDatasource _datasource;

  Future<List<Doctor>>? _doctoresCache;

  Future<List<Doctor>> _getDoctores() {
    return _doctoresCache ??= _fetchDoctores().catchError((Object error) {
      // Si la petición falla, se limpia el cache para permitir reintentos.
      _doctoresCache = null;
      throw error;
    });
  }

  Future<List<Doctor>> _fetchDoctores() async {
    final doctores = <Doctor>[];
    var page = 1;

    while (true) {
      final response = await _datasource.getEspecialistas(page: page);
      doctores.addAll(response.data.map(EspecialistaMapper.toEntity));

      if (response.nextPageUrl == null || page >= response.lastPage) break;
      page++;
    }

    return doctores;
  }

  @override
  Future<List<Especialidad>> getEspecialidades() async {
    final doctores = await _getDoctores();
    final porId = <String, Especialidad>{};

    for (final doctor in doctores) {
      for (final especialidad in doctor.especialidades) {
        porId[especialidad.id] = especialidad;
      }
    }

    return porId.values.toList()..sort((a, b) => a.nombre.compareTo(b.nombre));
  }

  @override
  Future<List<Ciudad>> getCiudades() async {
    final doctores = await _getDoctores();
    final porId = <String, Ciudad>{};

    for (final doctor in doctores) {
      porId[doctor.ciudad.id] = doctor.ciudad;
    }

    return porId.values.toList()..sort((a, b) => a.nombre.compareTo(b.nombre));
  }

  @override
  Future<List<Doctor>> searchDoctors({
    String? especialidadId,
    String? ciudadId,
    String? centroMedicoId,
    String? nombre,
  }) async {
    final doctores = await _getDoctores();
    final nombreBusqueda = nombre?.trim().toLowerCase();

    return doctores.where((doctor) {
      final coincideEspecialidad =
          especialidadId == null ||
          doctor.especialidades.any((e) => e.id == especialidadId);
      final coincideCiudad = ciudadId == null || doctor.ciudad.id == ciudadId;
      final coincideCentro = centroMedicoId == null ||
          doctor.centrosMedicosIds.contains(centroMedicoId) ||
          doctor.atiendeEn.any((c) =>
              c.toLowerCase() == centroMedicoId.toLowerCase() ||
              c.toLowerCase().contains(centroMedicoId.toLowerCase()));
      final coincideNombre =
          nombreBusqueda == null ||
          nombreBusqueda.isEmpty ||
          doctor.nombre.toLowerCase().contains(nombreBusqueda);
      return coincideEspecialidad &&
          coincideCiudad &&
          coincideCentro &&
          coincideNombre;
    }).toList();
  }

  @override
  Future<Doctor> getDoctorById(String id) async {
    final doctores = await _getDoctores();
    return doctores.firstWhere((doctor) => doctor.id == id);
  }
}
