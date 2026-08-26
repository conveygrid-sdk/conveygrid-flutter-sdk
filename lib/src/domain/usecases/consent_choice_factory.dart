import 'package:conveygrid_flutter_sdk/src/domain/entities/consent_notice.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/purpose_choice.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/cookie_banner.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/cookie_preference.dart';

abstract final class ConsentChoiceFactory {
  static List<PurposeChoice> acceptAll(ConsentNotice notice) {
    return notice.purposes
        .where((purpose) => !purpose.alreadyGranted)
        .map((purpose) =>
            PurposeChoice(purposeId: purpose.purposeId, granted: true))
        .toList();
  }

  static List<PurposeChoice> rejectOptional(ConsentNotice notice) {
    return notice.purposes
        .where((purpose) => !purpose.alreadyGranted)
        .map(
          (purpose) => PurposeChoice(
            purposeId: purpose.purposeId,
            granted: purpose.isMandatory,
          ),
        )
        .toList();
  }

  static List<PurposeChoice> fromSelection({
    required ConsentNotice notice,
    required Set<String> grantedPurposeIds,
  }) {
    return notice.purposes
        .where((purpose) => !purpose.alreadyGranted)
        .map(
          (purpose) => PurposeChoice(
            purposeId: purpose.purposeId,
            granted: purpose.isMandatory ||
                grantedPurposeIds.contains(purpose.purposeId),
          ),
        )
        .toList();
  }

  static List<CookieCategoryChoice> cookieChoices({
    required CookieBanner banner,
    required Set<String> grantedCategoryCodes,
  }) {
    return banner.categories
        .map(
          (category) => CookieCategoryChoice(
            categoryCode: category.categoryCode,
            granted: category.isEssential ||
                grantedCategoryCodes.contains(category.categoryCode),
          ),
        )
        .toList();
  }
}
