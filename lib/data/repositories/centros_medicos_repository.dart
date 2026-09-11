import '../../domain/entities/centro_medico.dart';

abstract class CentrosMedicosRepository {
  Future<List<CentroMedico>> getCentrosMedicos();

  Future<List<CentroMedico>> searchCentrosMedicos({
    String? ciudadId,
    String? query,
  });

  Future<CentroMedico> getCentroMedicoById(String id);
}
