import 'package:dio/dio.dart';
import 'package:conveygrid_flutter_sdk/src/config/convey_grid_config.dart';
import 'package:conveygrid_flutter_sdk/src/core/constants/convey_grid_constants.dart';

final class ConveyGridHeaderInterceptor extends Interceptor {
  ConveyGridHeaderInterceptor(this._config);

  final ConveyGridConfig _config;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers[ConveyGridHeaders.contentType] =
        ConveyGridHeaders.jsonContentType;
    options.headers[ConveyGridHeaders.applicationKey] =
        _config.applicationKey.trim();
    if (_config.sendOriginRefererHeaders) {
      if (_config.origin.trim().isNotEmpty) {
        options.headers[ConveyGridHeaders.origin] = _config.origin.trim();
      }
      if (_config.referer.trim().isNotEmpty) {
        options.headers[ConveyGridHeaders.referer] = _config.referer.trim();
      }
    }
    handler.next(options);
  }
}

final class ConveyGridSafeLogInterceptor extends Interceptor {
  ConveyGridSafeLogInterceptor({required this.enabled});

  final bool enabled;

  static const Set<String> _redactedHeaders = {
    ConveyGridHeaders.applicationKey,
    'Authorization',
    'authorization',
  };

  static const Set<String> _redactedBodyKeys = {
    'email',
    'mobile',
    'fullName',
    'full_name',
    'applicationKey',
    'preference_token',
    'choices',
    'subject',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (enabled) {
      // ignore: avoid_print
      print(
        'ConveyGrid ${options.method} ${options.uri.path} headers=${_sanitizeHeaders(options.headers)}',
      );
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (enabled) {
      // ignore: avoid_print
      print(
        'ConveyGrid error ${err.response?.statusCode} ${err.requestOptions.uri.path}',
      );
    }
    handler.next(err);
  }

  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    return headers.map((key, value) {
      if (_redactedHeaders.contains(key)) {
        return MapEntry(key, '[redacted]');
      }
      return MapEntry(key, value);
    });
  }

  static Map<String, dynamic> sanitizeBody(Map<String, dynamic> body) {
    return body.map((key, value) {
      if (_redactedBodyKeys.contains(key)) {
        return MapEntry(key, '[redacted]');
      }
      return MapEntry(key, value);
    });
  }
}

Dio createConveyGridDio(ConveyGridConfig config) {
  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: config.timeout,
      receiveTimeout: config.timeout,
      sendTimeout: config.timeout,
      headers: {
        ConveyGridHeaders.contentType: ConveyGridHeaders.jsonContentType,
      },
    ),
  );
  dio.interceptors.add(ConveyGridHeaderInterceptor(config));
  dio.interceptors.add(
    ConveyGridSafeLogInterceptor(enabled: config.enableDebugLogging),
  );
  return dio;
}
