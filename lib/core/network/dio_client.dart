import 'package:dio/dio.dart';

import 'api_constants.dart';
import 'dio_interceptors.dart';
import 'network_exceptions.dart';

class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
      ),
    );

    dio.interceptors.add(DioInterceptors());
  }

  Future<Response> get(
    String path,
  ) async {
    try {
      final response = await dio.get(path);

      return response;
    } on DioException catch (e) {
      throw NetworkExceptions(
        e.message ?? 'Erreur réseau',
      );
    }
  }
}
