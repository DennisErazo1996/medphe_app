import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Dio buildApiClient() {
  return Dio(BaseOptions(baseUrl: dotenv.env['API_BASE_URL'] ?? ''));
}
