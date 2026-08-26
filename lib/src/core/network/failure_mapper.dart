import 'package:dio/dio.dart';
import 'package:conveygrid_flutter_sdk/src/core/constants/convey_grid_constants.dart';
import 'package:conveygrid_flutter_sdk/src/core/result/failure.dart';

abstract final class FailureMapper {
  static Failure fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure(
          message: ConveyGridUiStrings.timeoutError,
        );
      case DioExceptionType.connectionError:
        return const NetworkFailure(
          message: ConveyGridUiStrings.networkError,
        );
      case DioExceptionType.badResponse:
        return fromStatusCode(
          error.response?.statusCode,
          _messageFromBody(error.response?.data),
        );
      default:
        return const UnknownFailure(
          message: ConveyGridUiStrings.genericError,
        );
    }
  }

  static Failure fromStatusCode(int? statusCode, [String? serverMessage]) {
    switch (statusCode) {
      case 401:
      case 403:
        final lower = (serverMessage ?? '').toLowerCase();
        final unauthorizedMessage = lower.contains('origin')
            ? ConveyGridUiStrings.originNotAllowed
            : lower.contains('application key')
                ? ConveyGridUiStrings.invalidApplicationKey
                : (serverMessage ?? ConveyGridUiStrings.unauthorizedError);
        return UnauthorizedFailure(
          message: unauthorizedMessage,
          statusCode: statusCode,
        );
      case 422:
        return ValidationFailure(
          message: serverMessage ?? ConveyGridUiStrings.validationError,
          statusCode: statusCode,
        );
      case 404:
      case 429:
      case 500:
      case 503:
        return ServerFailure(
          message: serverMessage ?? ConveyGridUiStrings.serverError,
          statusCode: statusCode,
        );
      default:
        return ServerFailure(
          message: serverMessage ?? ConveyGridUiStrings.serverError,
          statusCode: statusCode,
        );
    }
  }

  static String? _messageFromBody(dynamic data) {
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return null;
  }
}
