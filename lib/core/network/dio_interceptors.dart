import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioInterceptors extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    debugPrint('REQUEST[${options.method}] => ${options.path}');

    options.headers['Content-Type'] = 'application/json';

    super.onRequest(options, handler);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    debugPrint(
      'RESPONSE[${response.statusCode}] => ${response.requestOptions.path}',
    );

    super.onResponse(response, handler);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    debugPrint(
      'ERROR[${err.response?.statusCode}] => ${err.requestOptions.path}',
    );

    super.onError(err, handler);
  }
}
