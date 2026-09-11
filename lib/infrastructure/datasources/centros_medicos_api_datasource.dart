import 'package:dio/dio.dart';

import '../models/centros_medicos_response.dart';

/// Acceso HTTP al endpoint de centros médicos del backend.
class CentrosMedicosApiDatasource {
  CentrosMedicosApiDatasource(this._dio);

  final Dio _dio;

  Future<CentrosMedicosResponse> getCentrosMedicos({int page = 1}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/medical-centers',
      queryParameters: {'page': page},
    );

    return CentrosMedicosResponse.fromJson(response.data ?? const {});
  }
}
