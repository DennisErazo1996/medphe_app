import '../../data/repositories/centros_medicos_repository.dart';
import '../../domain/entities/centro_medico.dart';
import '../datasources/centros_medicos_api_datasource.dart';
import '../mappers/centro_medico_mapper.dart';

/// Implementación de [CentrosMedicosRepository] contra el backend real.
class ApiCentrosMedicosRepository implements CentrosMedicosRepository {
  ApiCentrosMedicosRepository(this._datasource);

  final CentrosMedicosApiDatasource _datasource;

  Future<List<CentroMedico>>? _centrosMedicosCache;

  Future<List<CentroMedico>> _getCentrosMedicos() {
    return _centrosMedicosCache ??= _fetchCentrosMedicos().catchError(
      (Object error) {
        _centrosMedicosCache = null;
        throw error;
      },
    );
  }

  Future<List<CentroMedico>> _fetchCentrosMedicos() async {
    final centros = <CentroMedico>[];
    var page = 1;

    while (true) {
      final response = await _datasource.getCentrosMedicos(page: page);
      centros.addAll(response.data.map(CentroMedicoMapper.toEntity));

      if (response.nextPageUrl == null || page >= response.lastPage) break;
      page++;
    }

    return centros;
  }

  @override
  Future<List<CentroMedico>> getCentrosMedicos() {
    return _getCentrosMedicos();
  }

  @override
  Future<List<CentroMedico>> searchCentrosMedicos({
    String? ciudadId,
    String? query,
  }) async {
    final centros = await _getCentrosMedicos();
    final q = query?.trim().toLowerCase();

    return centros.where((centro) {
      final coincideCiudad =
          ciudadId == null ||
          ciudadId.isEmpty ||
          centro.ciudad.id.toLowerCase() == ciudadId.toLowerCase() ||
          centro.ciudad.nombre.toLowerCase() == ciudadId.toLowerCase();

      if (!coincideCiudad) return false;

      if (q == null || q.isEmpty) return true;

      final coincideNombre = centro.nombre.toLowerCase().contains(q);
      final coincideAcronimo = centro.acronimo.toLowerCase().contains(q);
      final coincideCiudadTexto =
          centro.ciudad.nombre.toLowerCase().contains(q) ||
          centro.departamento.toLowerCase().contains(q);
      final coincideServicio = centro.serviciosMedicos.any(
        (s) => s.toLowerCase().contains(q),
      );
      final coincideEspecialidad = centro.especialidadesMedicas.any(
        (e) => e.toLowerCase().contains(q),
      );

      return coincideNombre ||
          coincideAcronimo ||
          coincideCiudadTexto ||
          coincideServicio ||
          coincideEspecialidad;
    }).toList();
  }

  @override
  Future<CentroMedico> getCentroMedicoById(String id) async {
    final centros = await _getCentrosMedicos();
    return centros.firstWhere((c) => c.id == id);
  }
}
