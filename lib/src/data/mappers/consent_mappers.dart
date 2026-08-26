import 'package:conveygrid_flutter_sdk/src/domain/entities/consent_notice.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/consent_purpose.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/consent_submit_result.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/cookie_banner.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/cookie_category.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/cookie_preference.dart';

abstract final class ConsentMappers {
  static dynamic unwrap(dynamic payload) {
    if (payload is Map &&
        payload['success'] == true &&
        payload.containsKey('data')) {
      return payload['data'];
    }
    return payload;
  }

  static ConsentNotice noticeFromJson(Map<String, dynamic> json) {
    final purposes = (json['purposes'] as List<dynamic>? ?? [])
        .map((e) => purposeFromJson(e as Map<String, dynamic>))
        .toList();
    final themeJson = json['theme'] as Map<String, dynamic>?;
    return ConsentNotice(
      noticeId: json['notice_id'] as String,
      noticeCode: json['notice_code'] as String,
      noticeName: json['notice_name'] as String? ?? '',
      version: json['version'] as String? ?? '',
      status: json['status'] as String? ?? '',
      introductionText: json['introduction_text'] as String? ?? '',
      rightsText: json['rights_text'] as String? ?? '',
      contactInformation: json['contact_information'] as String? ?? '',
      footerText: json['footer_text'] as String? ?? '',
      supportsMinors: json['supports_minors'] as bool? ?? false,
      showNotice: json['show_notice'] as bool? ?? true,
      purposes: purposes,
      theme: themeJson == null
          ? null
          : ConsentNoticeTheme(
              themeId: themeJson['theme_id'] as String? ?? '',
              themeName: themeJson['theme_name'] as String? ?? '',
              primaryColor: themeJson['primary_color'] as String? ?? '#2F64F5',
              secondaryColor:
                  themeJson['secondary_color'] as String? ?? '#0F172A',
              fontFamily: themeJson['font_family'] as String?,
            ),
      alreadyGrantedPurposeIds:
          (json['already_granted_purpose_ids'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList(),
    );
  }

  static ConsentPurpose purposeFromJson(Map<String, dynamic> json) {
    return ConsentPurpose(
      noticePurposeId: json['notice_purpose_id'] as String? ?? '',
      purposeId: json['purpose_id'] as String,
      purposeCode: json['purpose_code'] as String? ?? '',
      purposeName: json['purpose_name'] as String? ?? '',
      purposeDescription: json['purpose_description'] as String? ?? '',
      isMandatory: json['is_mandatory'] as bool? ?? false,
      validityDays: json['validity_days'] as int?,
      retentionDays: json['retention_days'] as int?,
      displayOrder: json['display_order'] as int? ?? 0,
      alreadyGranted: json['already_granted'] as bool? ?? false,
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map((e) => categoryFromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static ConsentDataCategory categoryFromJson(Map<String, dynamic> json) {
    return ConsentDataCategory(
      categoryId: json['category_id'] as String? ?? '',
      categoryCode: json['category_code'] as String? ?? '',
      categoryName: json['category_name'] as String? ?? '',
      categoryDescription: json['category_description'] as String? ?? '',
      isMandatory: json['is_mandatory'] as bool? ?? false,
      isSensitive: json['is_sensitive'] as bool? ?? false,
      displayOrder: json['display_order'] as int? ?? 0,
    );
  }

  static ConsentSubmitResult submitFromJson(Map<String, dynamic> json) {
    return ConsentSubmitResult(
      artifactId: json['artifact_id'] as String?,
      subjectId: json['subject_id'] as String?,
      allMandatoryGranted: json['all_mandatory_granted'] as bool? ?? false,
      preferenceToken: json['preference_token'] as String?,
      status: json['status'] as String?,
      linkRequired: json['link_required'] as bool? ?? false,
      linkExpiresAt: json['link_expires_at'] as String?,
    );
  }

  static CookieBanner bannerFromJson(Map<String, dynamic> json) {
    return CookieBanner(
      bannerConfigId: json['banner_config_id'] as String,
      configCode: json['config_code'] as String,
      bannerTitle: json['banner_title'] as String? ?? '',
      bannerDescription: json['banner_description'] as String? ?? '',
      aboutContent: json['about_content'] as String? ?? '',
      version: json['current_version'] as String? ?? '',
      showAcceptAll: json['show_accept_all'] as bool? ?? true,
      showDeclineAll: json['show_decline_all'] as bool? ?? true,
      showCustomise: json['show_customise'] as bool? ?? true,
      preferenceExpiryDays: json['preference_expiry_days'] as int? ?? 180,
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map((e) => cookieCategoryFromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static CookieCategory cookieCategoryFromJson(Map<String, dynamic> json) {
    return CookieCategory(
      categoryId: json['category_id'] as String? ?? '',
      categoryCode: json['category_code'] as String,
      categoryName: json['category_name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isEssential: json['is_essential'] as bool? ?? false,
      displayOrder: json['display_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  static CookiePreference preferenceFromSubmit(
    Map<String, dynamic> json,
    List<CookieCategoryChoice> choices,
    String version,
  ) {
    return CookiePreference(
      preferenceToken: json['preference_token'] as String?,
      choices: choices,
      version: version,
      recordedAt: DateTime.now().toUtc(),
    );
  }
}
