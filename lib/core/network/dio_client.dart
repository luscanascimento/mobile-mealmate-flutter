import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/api_config.dart';

/// Builds and configures the shared [Dio] instance used across the app.
///
/// The base URL is HTTPS (see [ApiConfig.baseUrl]); an interceptor rejects any
/// request that somehow ends up on another scheme. Request logging is wired
/// only in debug builds.
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
          if (!options.uri.isScheme('https')) {
            // `badCertificate` is the closest Dio type to "transport was not
            // trustworthy": it is what makes ApiException render "Insecure
            // connection was blocked" instead of the generic fallback.
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
