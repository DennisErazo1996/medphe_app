import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Dio buildApiClient() {
  final dio = Dio(BaseOptions(baseUrl: dotenv.env['API_BASE_URL'] ?? ''));

  // En desarrollo el backend corre en Herd (dominio .test con certificado
  // self-signed) y el dispositivo llega vía `adb reverse` a localhost, por lo
  // que nginx necesita el header Host del sitio para rutear.
  final hostHeader = dotenv.env['API_HOST_HEADER'];
  if (hostHeader != null && hostHeader.isNotEmpty) {
    dio.options.headers[HttpHeaders.hostHeader] = hostHeader;
  }

  if (kDebugMode) {
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        // Acepta el certificado self-signed de Herd SOLO en builds de debug.
        client.badCertificateCallback = (cert, host, port) =>
            host == 'localhost' || host.endsWith('.test');
        return client;
      },
    );
  }

  return dio;
}
