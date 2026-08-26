abstract final class ConveyGridConstants {
  static const String sdkName = 'ConveyGrid Consent SDK';
  static const String defaultLanguage = 'en';
  static const String anonymousSessionPrefix = 'cg_anon_';
}

abstract final class ConveyGridHeaders {
  static const String applicationKey = 'X-Application-Key';
  static const String origin = 'Origin';
  static const String referer = 'Referer';
  static const String contentType = 'Content-Type';
  static const String jsonContentType = 'application/json';
}

abstract final class ConveyGridApiPaths {
  static const String cookieInit = '/api/v1/public/consent/cookie/init';
  static const String cookieSubmit = '/api/v1/public/consent/cookie/submit';
  static const String noticeSubmit = '/api/v1/public/consent/notices/submit';
  static const String validate = '/api/v1/public/consent/validate';
  static const String linkReference =
      '/api/v1/public/consent/artifacts/link-reference';

  static String publishedNotice(String noticeCode) =>
      '/api/v1/public/consent/notices/$noticeCode/published';
}

abstract final class ConveyGridStorageKeys {
  static const String anonymousSessionId = 'conveygrid_anonymous_session_id';
  static const String cookiePreferenceCache = 'conveygrid_cookie_pref_cache';
  static const String noticeVersionCache = 'conveygrid_notice_version_cache';
  static const String lastSyncTimestamp = 'conveygrid_last_sync_timestamp';
}

abstract final class ConveyGridUiStrings {
  static const String acceptAll = 'Accept All';
  static const String rejectOptional = 'Reject Optional';
  static const String customize = 'Customize';
  static const String savePreferences = 'Save Preferences';
  static const String cancel = 'Cancel';
  static const String mandatory = 'Required';
  static const String optional = 'Optional';
  static const String cookieBannerTitle = 'Privacy preferences';
  static const String retry = 'Retry';
  static const String consentFailed = 'Unable to load consent notice.';
  static const String missingConfig = 'ConveyGrid configuration is incomplete.';
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'No internet connection.';
  static const String timeoutError = 'The request timed out.';
  static const String unauthorizedError = 'Consent request was not authorized.';
  static const String invalidApplicationKey =
      'Invalid application key for this ConveyGrid API host. Use the same API base URL as the working Swift app.';
  static const String originNotAllowed =
      'Origin is not allowed for this application. Send the Origin registered on this application key (do not omit Origin).';
  static const String serverError = 'ConveyGrid is temporarily unavailable.';
  static const String validationError = 'Consent data is invalid.';
  static const String essentialLocked =
      'Required for core app functions and cannot be disabled.';
}
