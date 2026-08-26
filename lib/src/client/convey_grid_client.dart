import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:conveygrid_flutter_sdk/src/config/convey_grid_config.dart';
import 'package:conveygrid_flutter_sdk/src/config/convey_grid_subject.dart';
import 'package:conveygrid_flutter_sdk/src/core/constants/convey_grid_constants.dart';
import 'package:conveygrid_flutter_sdk/src/core/network/convey_grid_api_client.dart';
import 'package:conveygrid_flutter_sdk/src/core/result/failure.dart';
import 'package:conveygrid_flutter_sdk/src/core/result/result.dart';
import 'package:conveygrid_flutter_sdk/src/core/storage/storage_contracts.dart';
import 'package:conveygrid_flutter_sdk/src/core/storage/storage_impl.dart';
import 'package:conveygrid_flutter_sdk/src/data/datasources/consent_local_data_source.dart';
import 'package:conveygrid_flutter_sdk/src/data/datasources/consent_remote_data_source.dart';
import 'package:conveygrid_flutter_sdk/src/data/repositories/consent_repository_impl.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/consent_notice.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/consent_submit_result.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/cookie_banner.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/cookie_preference.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/purpose_choice.dart';
import 'package:conveygrid_flutter_sdk/src/domain/repositories/consent_repository.dart';
import 'package:conveygrid_flutter_sdk/src/domain/usecases/consent_choice_factory.dart';
import 'package:conveygrid_flutter_sdk/src/domain/usecases/consent_use_cases.dart';
import 'package:conveygrid_flutter_sdk/src/events/convey_grid_event.dart';
import 'package:conveygrid_flutter_sdk/src/presentation/widgets/convey_grid_consent_bottom_sheet.dart';
import 'package:conveygrid_flutter_sdk/src/presentation/widgets/convey_grid_consent_dialog.dart';

final class ConveyGridClient {
  ConveyGridClient({
    required ConveyGridConfig config,
    Dio? dio,
    SessionStore? sessionStore,
    PreferenceCacheStore? cacheStore,
    ConsentRepository? repository,
  })  : _config = config,
        _sessionStore = sessionStore ?? SecureSessionStore(),
        _eventsController = StreamController<ConveyGridEvent>.broadcast() {
    final resolvedDio = dio ?? createConveyGridDio(config);
    _repository = repository ??
        ConsentRepositoryImpl(
          remote: ConsentRemoteDataSourceImpl(resolvedDio),
          local: ConsentLocalDataSourceImpl(
            cacheStore ?? SharedPreferencesCacheStore(),
          ),
        );
    _getNotice = GetConsentNoticeUseCase(_repository);
    _submitConsent = SubmitConsentUseCase(_repository);
    _validateConsent = ValidateConsentUseCase(_repository);
    _linkReference = LinkConsentReferenceUseCase(_repository);
    _getCookieBanner = GetCookieBannerUseCase(_repository);
    _submitCookie = SubmitCookiePreferencesUseCase(_repository);
  }

  final ConveyGridConfig _config;
  final SessionStore _sessionStore;
  late final ConsentRepository _repository;
  late final GetConsentNoticeUseCase _getNotice;
  late final SubmitConsentUseCase _submitConsent;
  late final ValidateConsentUseCase _validateConsent;
  late final LinkConsentReferenceUseCase _linkReference;
  late final GetCookieBannerUseCase _getCookieBanner;
  late final SubmitCookiePreferencesUseCase _submitCookie;
  final StreamController<ConveyGridEvent> _eventsController;

  bool _initialized = false;
  String? _sessionId;
  CookiePreference? _cookiePreference;

  Stream<ConveyGridEvent> get events => _eventsController.stream;
  ConveyGridConfig get config => _config;
  CookiePreference? get cookiePreference => _cookiePreference;
  bool get isInitialized => _initialized;

  Future<Result<void>> initialize() async {
    if (_config.applicationKey.trim().isEmpty ||
        _config.apiBaseUrl.trim().isEmpty) {
      return const FailureResult(
        ValidationFailure(message: ConveyGridUiStrings.missingConfig),
      );
    }
    _sessionId = await _sessionStore.getOrCreateAnonymousSessionId();
    _cookiePreference = await _repository.cachedCookiePreference();
    _initialized = true;
    return const Success(null);
  }

  ConveyGridSubject resolvedSubject([ConveyGridSubject? override]) {
    final base = override ?? _config.subject ?? const ConveyGridSubject();
    return base.copyWith(sessionId: base.sessionId ?? _sessionId);
  }

  Future<Result<ConsentNotice>> getConsentNotice({
    required String noticeCode,
    ConveyGridSubject? subject,
  }) async {
    final result = await _getNotice(
      noticeCode: noticeCode,
      mobile: resolvedSubject(subject).mobile,
    );
    result.fold(
      onSuccess: (notice) => _eventsController.add(
        ConsentLoaded(
          noticeCode: notice.noticeCode,
          purposeCount: notice.purposes.length,
        ),
      ),
      onFailure: (failure) => _eventsController.add(
        ConsentFailed(message: failure.message, statusCode: failure.statusCode),
      ),
    );
    return result;
  }

  Future<Result<ConsentSubmitResult>> submitConsent({
    required ConsentNotice notice,
    required List<PurposeChoice> choices,
    ConveyGridSubject? subject,
    String? pageUrl,
  }) async {
    final result = await _submitConsent(
      notice: notice,
      choices: choices,
      subject: resolvedSubject(subject),
      pageUrl: pageUrl,
      language: resolvedSubject(subject).language ?? _config.language,
    );
    result.fold(
      onSuccess: (value) {
        final granted = choices.where((c) => c.granted).length;
        final withdrawn = choices.where((c) => !c.granted).length;
        if (!value.allMandatoryGranted) {
          _eventsController.add(const ConsentRejected());
        } else if (withdrawn > 0 && granted < notice.purposes.length) {
          _eventsController.add(
            ConsentUpdated(grantedPurposeCount: granted),
          );
          if (withdrawn > 0) {
            _eventsController.add(
              ConsentWithdrawn(withdrawnPurposeCount: withdrawn),
            );
          }
        } else {
          _eventsController.add(ConsentGranted(grantedPurposeCount: granted));
        }
      },
      onFailure: (failure) => _eventsController.add(
        ConsentFailed(message: failure.message, statusCode: failure.statusCode),
      ),
    );
    return result;
  }

  Future<Result<ConsentSubmitResult>> acceptAll({
    required ConsentNotice notice,
    ConveyGridSubject? subject,
    String? pageUrl,
  }) {
    return submitConsent(
      notice: notice,
      choices: ConsentChoiceFactory.acceptAll(notice),
      subject: subject,
      pageUrl: pageUrl,
    );
  }

  Future<Result<ConsentSubmitResult>> rejectOptional({
    required ConsentNotice notice,
    ConveyGridSubject? subject,
    String? pageUrl,
  }) {
    return submitConsent(
      notice: notice,
      choices: ConsentChoiceFactory.rejectOptional(notice),
      subject: subject,
      pageUrl: pageUrl,
    );
  }

  Future<Result<bool>> validateConsent({
    required String purposeCode,
    String? noticeCode,
    ConveyGridSubject? subject,
  }) {
    return _validateConsent(
      purposeCode: purposeCode,
      noticeCode: noticeCode,
      subject: resolvedSubject(subject),
    );
  }

  Future<Result<void>> linkReference({
    required String referenceId,
    String? artifactId,
    String? preferenceToken,
  }) {
    return _linkReference(
      referenceId: referenceId,
      artifactId: artifactId,
      preferenceToken: preferenceToken,
    );
  }

  Future<Result<CookieBanner>> getCookieBanner({
    required String configCode,
  }) {
    return _getCookieBanner(
      configCode: configCode,
      subjectRef: resolvedSubject().sessionId ?? '',
    );
  }

  Future<Result<CookiePreference>> submitCookiePreferences({
    required CookieBanner banner,
    required Set<String> grantedCategoryCodes,
    String? pageUrl,
  }) async {
    final choices = ConsentChoiceFactory.cookieChoices(
      banner: banner,
      grantedCategoryCodes: grantedCategoryCodes,
    );
    final result = await _submitCookie(
      banner: banner,
      choices: choices,
      subjectRef: resolvedSubject().sessionId ?? '',
      pageUrl: pageUrl,
    );
    result.fold(
      onSuccess: (preference) {
        _cookiePreference = preference;
        _eventsController.add(
          CookiePreferencesUpdated(
            grantedCategoryCount:
                preference.choices.where((c) => c.granted).length,
          ),
        );
      },
      onFailure: (failure) => _eventsController.add(
        ConsentFailed(message: failure.message, statusCode: failure.statusCode),
      ),
    );
    return result;
  }

  bool isCategoryGranted(String categoryCode) {
    return _cookiePreference?.isGranted(categoryCode) ?? false;
  }

  Future<Result<ConsentSubmitResult?>> showConsentNotice(
    BuildContext context, {
    required String noticeCode,
    ConveyGridSubject? subject,
    String? pageUrl,
  }) async {
    final noticeResult = await getConsentNotice(
      noticeCode: noticeCode,
      subject: subject,
    );
    final notice = noticeResult.valueOrNull;
    if (notice == null) {
      return FailureResult(
        noticeResult.failureOrNull ??
            const UnknownFailure(message: ConveyGridUiStrings.consentFailed),
      );
    }

    if (!context.mounted) {
      return const FailureResult(
        UnknownFailure(message: ConveyGridUiStrings.genericError),
      );
    }

    final ConsentSubmitResult? submitted;
    if (_config.theme.useBottomSheet) {
      submitted = await ConveyGridConsentBottomSheet.show(
        context,
        client: this,
        notice: notice,
        subject: subject,
        pageUrl: pageUrl,
      );
    } else {
      submitted = await ConveyGridConsentDialog.show(
        context,
        client: this,
        notice: notice,
        subject: subject,
        pageUrl: pageUrl,
      );
    }

    if (submitted == null) {
      return const Success(null);
    }
    return Success(submitted);
  }

  Future<void> dispose() async {
    await _eventsController.close();
  }
}
