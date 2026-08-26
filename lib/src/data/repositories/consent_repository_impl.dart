import 'package:conveygrid_flutter_sdk/src/config/convey_grid_subject.dart';
import 'package:conveygrid_flutter_sdk/src/core/constants/convey_grid_constants.dart';
import 'package:conveygrid_flutter_sdk/src/core/result/failure.dart';
import 'package:conveygrid_flutter_sdk/src/core/result/result.dart';
import 'package:conveygrid_flutter_sdk/src/data/datasources/consent_local_data_source.dart';
import 'package:conveygrid_flutter_sdk/src/data/datasources/consent_remote_data_source.dart';
import 'package:conveygrid_flutter_sdk/src/data/mappers/consent_mappers.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/consent_notice.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/consent_submit_result.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/cookie_banner.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/cookie_preference.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/purpose_choice.dart';
import 'package:conveygrid_flutter_sdk/src/domain/repositories/consent_repository.dart';

final class ConsentRepositoryImpl implements ConsentRepository {
  ConsentRepositoryImpl({
    required ConsentRemoteDataSource remote,
    required ConsentLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  final ConsentRemoteDataSource _remote;
  final ConsentLocalDataSource _local;

  @override
  Future<Result<ConsentNotice>> getConsentNotice({
    required String noticeCode,
    String? mobile,
  }) async {
    try {
      final payload = await _remote.getPublishedNotice(
        noticeCode: noticeCode,
        mobile: mobile,
      );
      final data = ConsentMappers.unwrap(payload) as Map<String, dynamic>;
      final notice = ConsentMappers.noticeFromJson(data);
      await _local.cacheNoticeVersion(notice.noticeCode, notice.version);
      return Success(notice);
    } on Failure catch (failure) {
      return FailureResult(failure);
    } on FormatException {
      return const FailureResult(
        UnknownFailure(message: ConveyGridUiStrings.genericError),
      );
    } catch (_) {
      return const FailureResult(
        UnknownFailure(message: ConveyGridUiStrings.genericError),
      );
    }
  }

  @override
  Future<Result<ConsentSubmitResult>> submitConsent({
    required ConsentNotice notice,
    required List<PurposeChoice> choices,
    required ConveyGridSubject subject,
    String? pageUrl,
    String? language,
  }) async {
    try {
      final payload = await _remote.submitNotice(
        noticeId: notice.noticeId,
        version: notice.version,
        choices: choices,
        subject: subject,
        pageUrl: pageUrl,
        language: language,
      );
      final data = ConsentMappers.unwrap(payload) as Map<String, dynamic>;
      return Success(ConsentMappers.submitFromJson(data));
    } on Failure catch (failure) {
      return FailureResult(failure);
    } catch (_) {
      return const FailureResult(
        UnknownFailure(message: ConveyGridUiStrings.genericError),
      );
    }
  }

  @override
  Future<Result<bool>> validateConsent({
    required String purposeCode,
    String? noticeCode,
    required ConveyGridSubject subject,
  }) async {
    try {
      final payload = await _remote.validateConsent(
        purposeCode: purposeCode,
        noticeCode: noticeCode,
        subject: subject,
      );
      final data = ConsentMappers.unwrap(payload);
      if (data is Map && data['allowed'] is bool) {
        return Success(data['allowed'] as bool);
      }
      return const Success(false);
    } on Failure catch (failure) {
      return FailureResult(failure);
    } catch (_) {
      return const FailureResult(
        UnknownFailure(message: ConveyGridUiStrings.genericError),
      );
    }
  }

  @override
  Future<Result<void>> linkReference({
    String? artifactId,
    String? preferenceToken,
    required String referenceId,
  }) async {
    try {
      await _remote.linkReference(
        artifactId: artifactId,
        preferenceToken: preferenceToken,
        referenceId: referenceId,
      );
      return const Success(null);
    } on Failure catch (failure) {
      return FailureResult(failure);
    } catch (_) {
      return const FailureResult(
        UnknownFailure(message: ConveyGridUiStrings.genericError),
      );
    }
  }

  @override
  Future<Result<CookieBanner>> getCookieBanner({
    required String configCode,
    required String subjectRef,
  }) async {
    try {
      final payload = await _remote.initCookieBanner(
        configCode: configCode,
        subjectRef: subjectRef,
      );
      final data = ConsentMappers.unwrap(payload) as Map<String, dynamic>;
      return Success(ConsentMappers.bannerFromJson(data));
    } on Failure catch (failure) {
      return FailureResult(failure);
    } catch (_) {
      return const FailureResult(
        UnknownFailure(message: ConveyGridUiStrings.genericError),
      );
    }
  }

  @override
  Future<Result<CookiePreference>> submitCookiePreferences({
    required CookieBanner banner,
    required List<CookieCategoryChoice> choices,
    required String subjectRef,
    String? pageUrl,
  }) async {
    try {
      final payload = await _remote.submitCookiePreferences(
        bannerConfigId: banner.bannerConfigId,
        version: banner.version,
        subjectRef: subjectRef,
        choices: choices,
        pageUrl: pageUrl,
      );
      final data = ConsentMappers.unwrap(payload) as Map<String, dynamic>;
      final preference = ConsentMappers.preferenceFromSubmit(
        data,
        choices,
        banner.version,
      );
      await _local.cacheCookiePreference(preference);
      return Success(preference);
    } on Failure catch (failure) {
      return FailureResult(failure);
    } catch (_) {
      return const FailureResult(
        UnknownFailure(message: ConveyGridUiStrings.genericError),
      );
    }
  }

  @override
  Future<CookiePreference?> cachedCookiePreference() {
    return _local.readCookiePreference();
  }
}
