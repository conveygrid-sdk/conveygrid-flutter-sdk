import 'package:conveygrid_flutter_sdk/src/config/convey_grid_subject.dart';
import 'package:conveygrid_flutter_sdk/src/core/result/result.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/consent_notice.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/consent_submit_result.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/cookie_banner.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/cookie_preference.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/purpose_choice.dart';
import 'package:conveygrid_flutter_sdk/src/domain/repositories/consent_repository.dart';

final class GetConsentNoticeUseCase {
  const GetConsentNoticeUseCase(this._repository);
  final ConsentRepository _repository;

  Future<Result<ConsentNotice>> call({
    required String noticeCode,
    String? mobile,
  }) {
    return _repository.getConsentNotice(
      noticeCode: noticeCode,
      mobile: mobile,
    );
  }
}

final class SubmitConsentUseCase {
  const SubmitConsentUseCase(this._repository);
  final ConsentRepository _repository;

  Future<Result<ConsentSubmitResult>> call({
    required ConsentNotice notice,
    required List<PurposeChoice> choices,
    required ConveyGridSubject subject,
    String? pageUrl,
    String? language,
  }) {
    return _repository.submitConsent(
      notice: notice,
      choices: choices,
      subject: subject,
      pageUrl: pageUrl,
      language: language,
    );
  }
}

final class ValidateConsentUseCase {
  const ValidateConsentUseCase(this._repository);
  final ConsentRepository _repository;

  Future<Result<bool>> call({
    required String purposeCode,
    String? noticeCode,
    required ConveyGridSubject subject,
  }) {
    return _repository.validateConsent(
      purposeCode: purposeCode,
      noticeCode: noticeCode,
      subject: subject,
    );
  }
}

final class LinkConsentReferenceUseCase {
  const LinkConsentReferenceUseCase(this._repository);
  final ConsentRepository _repository;

  Future<Result<void>> call({
    String? artifactId,
    String? preferenceToken,
    required String referenceId,
  }) {
    return _repository.linkReference(
      artifactId: artifactId,
      preferenceToken: preferenceToken,
      referenceId: referenceId,
    );
  }
}

final class GetCookieBannerUseCase {
  const GetCookieBannerUseCase(this._repository);
  final ConsentRepository _repository;

  Future<Result<CookieBanner>> call({
    required String configCode,
    required String subjectRef,
  }) {
    return _repository.getCookieBanner(
      configCode: configCode,
      subjectRef: subjectRef,
    );
  }
}

final class SubmitCookiePreferencesUseCase {
  const SubmitCookiePreferencesUseCase(this._repository);
  final ConsentRepository _repository;

  Future<Result<CookiePreference>> call({
    required CookieBanner banner,
    required List<CookieCategoryChoice> choices,
    required String subjectRef,
    String? pageUrl,
  }) {
    return _repository.submitCookiePreferences(
      banner: banner,
      choices: choices,
      subjectRef: subjectRef,
      pageUrl: pageUrl,
    );
  }
}
