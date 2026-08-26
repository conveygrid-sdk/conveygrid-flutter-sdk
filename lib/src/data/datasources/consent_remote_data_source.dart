import 'package:dio/dio.dart';
import 'package:conveygrid_flutter_sdk/src/config/convey_grid_subject.dart';
import 'package:conveygrid_flutter_sdk/src/core/constants/convey_grid_constants.dart';
import 'package:conveygrid_flutter_sdk/src/core/network/failure_mapper.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/purpose_choice.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/cookie_preference.dart';

abstract interface class ConsentRemoteDataSource {
  Future<Map<String, dynamic>> getPublishedNotice({
    required String noticeCode,
    String? mobile,
  });

  Future<Map<String, dynamic>> submitNotice({
    required String noticeId,
    required String version,
    required List<PurposeChoice> choices,
    required ConveyGridSubject subject,
    String? language,
    String? pageUrl,
  });

  Future<Map<String, dynamic>> validateConsent({
    required String purposeCode,
    String? noticeCode,
    required ConveyGridSubject subject,
  });

  Future<Map<String, dynamic>> linkReference({
    String? artifactId,
    String? preferenceToken,
    required String referenceId,
  });

  Future<Map<String, dynamic>> initCookieBanner({
    required String configCode,
    required String subjectRef,
  });

  Future<Map<String, dynamic>> submitCookiePreferences({
    required String bannerConfigId,
    required String version,
    required String subjectRef,
    required List<CookieCategoryChoice> choices,
    String? pageUrl,
  });
}

final class ConsentRemoteDataSourceImpl implements ConsentRemoteDataSource {
  ConsentRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<Map<String, dynamic>> getPublishedNotice({
    required String noticeCode,
    String? mobile,
  }) {
    final path = ConveyGridApiPaths.publishedNotice(noticeCode);
    if (mobile != null && mobile.trim().isNotEmpty) {
      return _post(path, {'mobile': mobile.trim()});
    }
    return _get(path);
  }

  @override
  Future<Map<String, dynamic>> submitNotice({
    required String noticeId,
    required String version,
    required List<PurposeChoice> choices,
    required ConveyGridSubject subject,
    String? language,
    String? pageUrl,
  }) {
    return _post(ConveyGridApiPaths.noticeSubmit, {
      'notice_id': noticeId,
      'version': version,
      'choices': choices.map((c) => c.toJson()).toList(),
      'language': language,
      'page_url': pageUrl,
      'subject': {
        'sessionId': subject.sessionId,
        'referenceId': subject.referenceId,
        'email': subject.email,
        'mobile': subject.mobile,
        if (subject.fullName != null) 'fullName': subject.fullName,
      },
    });
  }

  @override
  Future<Map<String, dynamic>> validateConsent({
    required String purposeCode,
    String? noticeCode,
    required ConveyGridSubject subject,
  }) {
    return _post(ConveyGridApiPaths.validate, {
      'purpose_code': purposeCode,
      'notice_code': noticeCode,
      'reference_id': subject.referenceId,
      'session_id': subject.sessionId,
    });
  }

  @override
  Future<Map<String, dynamic>> linkReference({
    String? artifactId,
    String? preferenceToken,
    required String referenceId,
  }) {
    final payload = <String, dynamic>{'reference_id': referenceId};
    if (artifactId != null) {
      payload['artifact_id'] = artifactId;
    } else if (preferenceToken != null) {
      payload['preferenceToken'] = preferenceToken;
    }
    return _post(ConveyGridApiPaths.linkReference, payload);
  }

  @override
  Future<Map<String, dynamic>> initCookieBanner({
    required String configCode,
    required String subjectRef,
  }) {
    return _post(ConveyGridApiPaths.cookieInit, {
      'config_code': configCode,
      'subject_ref': subjectRef,
    });
  }

  @override
  Future<Map<String, dynamic>> submitCookiePreferences({
    required String bannerConfigId,
    required String version,
    required String subjectRef,
    required List<CookieCategoryChoice> choices,
    String? pageUrl,
  }) {
    return _post(ConveyGridApiPaths.cookieSubmit, {
      'subject_ref': subjectRef,
      'banner_config_id': bannerConfigId,
      'version': version,
      'choices': choices.map((c) => c.toJson()).toList(),
      'page_url': pageUrl,
    });
  }

  Future<Map<String, dynamic>> _get(String path) async {
    try {
      final response = await _dio.get<dynamic>(path);
      return _asMap(response.data);
    } on DioException catch (error) {
      throw FailureMapper.fromDio(error);
    }
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.post<dynamic>(path, data: body);
      return _asMap(response.data);
    } on DioException catch (error) {
      throw FailureMapper.fromDio(error);
    }
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    throw const FormatException('Malformed ConveyGrid response');
  }
}
