import 'package:conveygrid_flutter_sdk/src/config/convey_grid_subject.dart';
import 'package:conveygrid_flutter_sdk/src/core/result/result.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/consent_notice.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/consent_submit_result.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/cookie_banner.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/cookie_preference.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/purpose_choice.dart';

abstract interface class ConsentRepository {
  Future<Result<ConsentNotice>> getConsentNotice({
    required String noticeCode,
    String? mobile,
  });

  Future<Result<ConsentSubmitResult>> submitConsent({
    required ConsentNotice notice,
    required List<PurposeChoice> choices,
    required ConveyGridSubject subject,
    String? pageUrl,
    String? language,
  });

  Future<Result<bool>> validateConsent({
    required String purposeCode,
    String? noticeCode,
    required ConveyGridSubject subject,
  });

  Future<Result<void>> linkReference({
    String? artifactId,
    String? preferenceToken,
    required String referenceId,
  });

  Future<Result<CookieBanner>> getCookieBanner({
    required String configCode,
    required String subjectRef,
  });

  Future<Result<CookiePreference>> submitCookiePreferences({
    required CookieBanner banner,
    required List<CookieCategoryChoice> choices,
    required String subjectRef,
    String? pageUrl,
  });

  Future<CookiePreference?> cachedCookiePreference();
}
