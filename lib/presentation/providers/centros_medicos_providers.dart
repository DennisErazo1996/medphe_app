import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/api_client.dart';
import '../../data/repositories/centros_medicos_repository.dart';
import '../../domain/entities/centro_medico.dart';
import '../../domain/entities/doctor.dart';
import '../../infrastructure/datasources/centros_medicos_api_datasource.dart';
import '../../infrastructure/repositories/api_centros_medicos_repository.dart';
import 'doctors_providers.dart';

final centrosMedicosRepositoryProvider =
    Provider<CentrosMedicosRepository>((ref) {
      return ApiCentrosMedicosRepository(
        CentrosMedicosApiDatasource(buildApiClient()),
      );
    });

final allCentrosMedicosProvider = FutureProvider<List<CentroMedico>>((ref) {
  return ref.watch(centrosMedicosRepositoryProvider).getCentrosMedicos();
});

final centroMedicoByIdProvider =
    FutureProvider.family<CentroMedico, String>((ref, id) {
      return ref.watch(centrosMedicosRepositoryProvider).getCentroMedicoById(id);
    });

/// Doctores que atienden en un determinado centro médico (por nombre o acrónimo).
final doctorsByCentroMedicoProvider =
    FutureProvider.family<List<Doctor>, CentroMedico>((ref, centro) async {
      final doctors = await ref.watch(allDoctorsProvider.future);
      final nombre = centro.nombre.trim().toLowerCase();
      final acronimo = centro.acronimo.trim().toLowerCase();

      return doctors.where((doctor) {
        return doctor.atiendeEn.any((lugar) {
          final l = lugar.toLowerCase();
          return l.contains(nombre) ||
              (acronimo.isNotEmpty && l.contains(acronimo));
        });
      }).toList();
    });
