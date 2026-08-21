import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dio_client.dart';

/// Single shared [Dio] instance for the whole app.
final Provider<Dio> dioProvider = Provider<Dio>((Ref ref) {
  final Dio dio = DioClient.create();
  ref.onDispose(dio.close);
  return dio;
});
