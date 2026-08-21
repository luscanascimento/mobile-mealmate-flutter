import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

/// Domain-level exception that the UI can render safely.
///
/// We never surface raw [DioException] stack traces or server internals to the
/// user; instead we translate them into a small, friendly message.
class ApiException extends Equatable implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  /// Maps a low-level [DioException] into a user-safe [ApiException].
  factory ApiException.fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          'The connection timed out. Please check your network and try again.',
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          'Unable to reach the server. Please check your internet connection.',
        );
      case DioExceptionType.badCertificate:
        return const ApiException('Insecure connection was blocked.');
      case DioExceptionType.badResponse:
        final int? code = error.response?.statusCode;
        return ApiException(
          'The server responded with an error. Please try again later.',
          statusCode: code,
        );
      case DioExceptionType.cancel:
        return const ApiException('The request was cancelled.');
      // DioExceptionType.unknown, transformTimeout, and any future variants.
      default:
        return const ApiException(
          'Something went wrong. Please try again.',
        );
    }
  }

  @override
  List<Object?> get props => <Object?>[message, statusCode];

  @override
  String toString() => 'ApiException($statusCode): $message';
}
