import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/api_config.dart';

/// Builds and configures the shared [Dio] instance used across the app.
///
/// Security notes:
/// * Base URL is HTTPS-only (see [ApiConfig.baseUrl]).
/// * We reject any non-HTTPS request defensively via an interceptor.
/// * Logging is enabled only in debug builds so we never leak data in release.
class DioClient {
  const DioClient._();

  static Dio create() {
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        responseType: ResponseType.json,
        headers: <String, String>{
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          // Defense-in-depth: block any accidental plaintext request.
          if (!options.uri.isScheme('https')) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.badCertificate,
                error: 'Blocked non-HTTPS request to ${options.uri}',
              ),
            );
            return;
          }
          handler.next(options);
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: false,
          responseBody: false,
          logPrint: (Object object) => debugPrint(object.toString()),
        ),
      );
    }

    return dio;
  }
}
