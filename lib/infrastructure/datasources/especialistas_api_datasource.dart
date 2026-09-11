import 'package:dio/dio.dart';

import '../models/especialistas_response.dart';

/// Acceso HTTP al endpoint de especialistas del backend.
class EspecialistasApiDatasource {
  EspecialistasApiDatasource(this._dio);

  final Dio _dio;

  Future<EspecialistasResponse> getEspecialistas({int page = 1}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/doctors',
      queryParameters: {'page': page},
    );

    return EspecialistasResponse.fromJson(response.data ?? const {});
  }
}
