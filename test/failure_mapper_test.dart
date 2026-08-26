import 'package:flutter_test/flutter_test.dart';
import 'package:conveygrid_flutter_sdk/src/core/network/failure_mapper.dart';
import 'package:conveygrid_flutter_sdk/src/core/result/failure.dart';
import 'package:dio/dio.dart';

void main() {
  test('maps timeout', () {
    final failure = FailureMapper.fromDio(
      DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.connectionTimeout,
      ),
    );
    expect(failure, isA<TimeoutFailure>());
  });

  test('maps connection error', () {
    final failure = FailureMapper.fromDio(
      DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.connectionError,
      ),
    );
    expect(failure, isA<NetworkFailure>());
  });

  test('maps 403 429 500', () {
    expect(FailureMapper.fromStatusCode(403), isA<UnauthorizedFailure>());
    expect(FailureMapper.fromStatusCode(429), isA<ServerFailure>());
    expect(FailureMapper.fromStatusCode(500), isA<ServerFailure>());
  });

  test('maps 403 origin not allowed', () {
    final failure = FailureMapper.fromStatusCode(
      403,
      'Origin not allowed for this application',
    );
    expect(failure, isA<UnauthorizedFailure>());
    expect(failure.message, contains('Origin is not allowed'));
  });

  test('maps 401 invalid application key to host mismatch hint', () {
    final failure =
        FailureMapper.fromStatusCode(401, 'Invalid application key');
    expect(failure, isA<UnauthorizedFailure>());
    expect(
      failure.message,
      contains('same API base URL as the working Swift app'),
    );
  });
}
