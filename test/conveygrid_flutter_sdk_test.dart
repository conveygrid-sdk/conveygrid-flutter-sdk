import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:conveygrid_flutter_sdk/conveygrid_flutter_sdk.dart';
import 'package:conveygrid_flutter_sdk/src/core/network/convey_grid_api_client.dart';
import 'package:conveygrid_flutter_sdk/src/core/storage/storage_contracts.dart';
import 'package:conveygrid_flutter_sdk/src/data/datasources/consent_remote_data_source.dart';
import 'package:conveygrid_flutter_sdk/src/data/datasources/consent_local_data_source.dart';
import 'package:conveygrid_flutter_sdk/src/data/repositories/consent_repository_impl.dart';
import 'package:conveygrid_flutter_sdk/src/domain/usecases/consent_choice_factory.dart';

class _MockRemote extends Mock implements ConsentRemoteDataSource {}

class _MockLocal extends Mock implements ConsentLocalDataSource {}

class _MockSessionStore extends Mock implements SessionStore {}

Map<String, dynamic> _noticeJson() => {
      'success': true,
      'data': {
        'notice_id': 'n1',
        'notice_code': 'LUXESTAY_BOOKING_NOTICE',
        'notice_name': 'Booking notice',
        'version': '1.0',
        'status': 'Published',
        'introduction_text': 'Intro',
        'rights_text': 'https://example.com',
        'contact_information': 'privacy@example.com',
        'footer_text': 'Footer',
        'supports_minors': false,
        'show_notice': true,
        'already_granted_purpose_ids': [],
        'purposes': [
          {
            'notice_purpose_id': 'np1',
            'purpose_id': 'p-mandatory',
            'purpose_code': 'ROOM_BOOKING',
            'purpose_name': 'Room Booking',
            'purpose_description': 'Required',
            'is_mandatory': true,
            'validity_days': 30,
            'retention_days': 730,
            'display_order': 1,
            'already_granted': false,
            'categories': [],
          },
          {
            'notice_purpose_id': 'np2',
            'purpose_id': 'p-optional',
            'purpose_code': 'MARKETING_OFFERS',
            'purpose_name': 'Marketing',
            'purpose_description': 'Optional',
            'is_mandatory': false,
            'validity_days': 365,
            'retention_days': 365,
            'display_order': 2,
            'already_granted': false,
            'categories': [],
          },
        ],
      },
    };

Map<String, dynamic> _bannerJson() => {
      'success': true,
      'data': {
        'banner_config_id': 'b1',
        'config_code': 'LUXESTAY_COOKIE_BANNER',
        'banner_title': 'Privacy',
        'banner_description': 'Cookies',
        'about_content': 'About',
        'current_version': '1.0',
        'show_accept_all': true,
        'show_decline_all': true,
        'show_customise': true,
        'preference_expiry_days': 180,
        'categories': [
          {
            'category_id': 'c1',
            'category_code': 'essential',
            'category_name': 'Essential',
            'description': 'Required',
            'is_essential': true,
            'display_order': 1,
            'is_active': true,
          },
          {
            'category_id': 'c2',
            'category_code': 'lux_analytics',
            'category_name': 'Analytics',
            'description': 'Optional',
            'is_essential': false,
            'display_order': 2,
            'is_active': true,
          },
        ],
      },
    };

void main() {
  late _MockRemote remote;
  late _MockLocal local;
  late _MockSessionStore sessions;
  late ConsentRepositoryImpl repository;
  late ConveyGridClient client;

  const config = ConveyGridConfig(
    apiBaseUrl: 'https://api.example.com',
    applicationKey: 'test-key',
    origin: 'https://app.example.com',
    referer: 'https://app.example.com/',
  );

  setUpAll(() {
    registerFallbackValue(const ConveyGridSubject());
    registerFallbackValue(<PurposeChoice>[]);
    registerFallbackValue(<CookieCategoryChoice>[]);
    registerFallbackValue(
      const CookiePreference(choices: [], version: '1'),
    );
  });

  setUp(() {
    remote = _MockRemote();
    local = _MockLocal();
    sessions = _MockSessionStore();
    repository = ConsentRepositoryImpl(remote: remote, local: local);
    when(() => sessions.getOrCreateAnonymousSessionId())
        .thenAnswer((_) async => 'cg_anon_test');
    when(() => local.readCookiePreference()).thenAnswer((_) async => null);
    when(() => local.cacheNoticeVersion(any(), any())).thenAnswer((_) async {});
    when(() => local.cacheCookiePreference(any())).thenAnswer((_) async {});
    client = ConveyGridClient(
      config: config,
      sessionStore: sessions,
      repository: repository,
    );
  });

  test('initialize fails when application key is missing', () async {
    final emptyClient = ConveyGridClient(
      config: const ConveyGridConfig(
        apiBaseUrl: 'https://example.com',
        applicationKey: '',
        origin: 'https://origin',
        referer: 'https://origin/',
      ),
      sessionStore: sessions,
      repository: repository,
    );
    final result = await emptyClient.initialize();
    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, isA<ValidationFailure>());
  });

  test('initialize succeeds and stores anonymous session', () async {
    final result = await client.initialize();
    expect(result.isSuccess, isTrue);
    expect(client.isInitialized, isTrue);
    expect(client.resolvedSubject().sessionId, 'cg_anon_test');
  });

  test('notice fetch success maps purposes without preselecting optional',
      () async {
    when(
      () => remote.getPublishedNotice(
        noticeCode: any(named: 'noticeCode'),
        mobile: any(named: 'mobile'),
      ),
    ).thenAnswer((_) async => _noticeJson());

    final result = await client.getConsentNotice(
      noticeCode: 'LUXESTAY_BOOKING_NOTICE',
    );
    final notice = result.valueOrNull!;
    expect(notice.purposes, hasLength(2));
    expect(notice.optionalPurposes.first.alreadyGranted, isFalse);
    expect(ConsentChoiceFactory.rejectOptional(notice).last.granted, isFalse);
  });

  test('notice fetch error maps failure', () async {
    when(
      () => remote.getPublishedNotice(
        noticeCode: any(named: 'noticeCode'),
        mobile: any(named: 'mobile'),
      ),
    ).thenThrow(const ServerFailure(message: 'down', statusCode: 500));

    final result = await client.getConsentNotice(noticeCode: 'X');
    expect(result.failureOrNull, isA<ServerFailure>());
  });

  test('accept all submits granted true for every pending purpose', () async {
    when(
      () => remote.getPublishedNotice(
        noticeCode: any(named: 'noticeCode'),
        mobile: any(named: 'mobile'),
      ),
    ).thenAnswer((_) async => _noticeJson());
    when(
      () => remote.submitNotice(
        noticeId: any(named: 'noticeId'),
        version: any(named: 'version'),
        choices: any(named: 'choices'),
        subject: any(named: 'subject'),
        language: any(named: 'language'),
        pageUrl: any(named: 'pageUrl'),
      ),
    ).thenAnswer(
      (_) async => {
        'success': true,
        'data': {
          'artifact_id': 'a1',
          'all_mandatory_granted': true,
          'link_required': true,
          'status': 'recorded',
        },
      },
    );

    await client.initialize();
    final notice =
        (await client.getConsentNotice(noticeCode: 'LUXESTAY_BOOKING_NOTICE'))
            .valueOrNull!;
    final result = await client.acceptAll(
      notice: notice,
      subject: const ConveyGridSubject(email: 'a@b.com', mobile: '999'),
      pageUrl: 'https://app.example.com/book',
    );
    expect(result.valueOrNull?.allMandatoryGranted, isTrue);
    expect(result.valueOrNull?.linkRequired, isTrue);
  });

  test('reject optional keeps mandatory only', () {
    final notice = sampleNotice();
    final choices = ConsentChoiceFactory.rejectOptional(notice);
    expect(choices.first.granted, isTrue);
    expect(choices.last.granted, isFalse);
  });

  test('customized purposes only grant selected optional ids', () {
    final notice = sampleNotice();
    final choices = ConsentChoiceFactory.fromSelection(
      notice: notice,
      grantedPurposeIds: {'p-optional'},
    );
    expect(choices.every((c) => c.granted), isTrue);
  });

  test('cookie init and submit persist preference', () async {
    when(
      () => remote.initCookieBanner(
        configCode: any(named: 'configCode'),
        subjectRef: any(named: 'subjectRef'),
      ),
    ).thenAnswer((_) async => _bannerJson());
    when(
      () => remote.submitCookiePreferences(
        bannerConfigId: any(named: 'bannerConfigId'),
        version: any(named: 'version'),
        subjectRef: any(named: 'subjectRef'),
        choices: any(named: 'choices'),
        pageUrl: any(named: 'pageUrl'),
      ),
    ).thenAnswer(
      (_) async => {
        'success': true,
        'data': {'preference_token': 'tok'},
      },
    );

    await client.initialize();
    final banner =
        (await client.getCookieBanner(configCode: 'LUXESTAY_COOKIE_BANNER'))
            .valueOrNull!;
    final result = await client.submitCookiePreferences(
      banner: banner,
      grantedCategoryCodes: {'essential'},
    );
    expect(result.isSuccess, isTrue);
    expect(client.isCategoryGranted('lux_analytics'), isFalse);
  });

  test('validate and link reference success', () async {
    when(
      () => remote.validateConsent(
        purposeCode: any(named: 'purposeCode'),
        noticeCode: any(named: 'noticeCode'),
        subject: any(named: 'subject'),
      ),
    ).thenAnswer(
      (_) async => {
        'success': true,
        'data': {'allowed': true},
      },
    );
    when(
      () => remote.linkReference(
        artifactId: any(named: 'artifactId'),
        preferenceToken: any(named: 'preferenceToken'),
        referenceId: any(named: 'referenceId'),
      ),
    ).thenAnswer((_) async => {'success': true, 'data': {}});

    final allowed = await client.validateConsent(purposeCode: 'ROOM_BOOKING');
    expect(allowed.valueOrNull, isTrue);
    final linked = await client.linkReference(
      referenceId: 'booking-1',
      artifactId: 'a1',
    );
    expect(linked.isSuccess, isTrue);
  });

  test('maps 401 unauthorized', () async {
    when(
      () => remote.getPublishedNotice(
        noticeCode: any(named: 'noticeCode'),
        mobile: any(named: 'mobile'),
      ),
    ).thenThrow(const UnauthorizedFailure());
    final result = await client.getConsentNotice(noticeCode: 'X');
    expect(result.failureOrNull, isA<UnauthorizedFailure>());
  });

  test('safe log interceptor redacts application key', () {
    final sanitized = ConveyGridSafeLogInterceptor.sanitizeBody({
      'email': 'secret@example.com',
      'notice_id': 'n1',
    });
    expect(sanitized['email'], '[redacted]');
    expect(sanitized['notice_id'], 'n1');
  });
}

ConsentNotice sampleNotice() {
  return const ConsentNotice(
    noticeId: 'n1',
    noticeCode: 'CODE',
    noticeName: 'Name',
    version: '1.0',
    status: 'Published',
    introductionText: '',
    rightsText: '',
    contactInformation: '',
    footerText: '',
    supportsMinors: false,
    showNotice: true,
    purposes: [
      ConsentPurpose(
        noticePurposeId: 'np1',
        purposeId: 'p-mandatory',
        purposeCode: 'ROOM_BOOKING',
        purposeName: 'Booking',
        purposeDescription: '',
        isMandatory: true,
        validityDays: 30,
        retentionDays: 30,
        displayOrder: 1,
        alreadyGranted: false,
        categories: [],
      ),
      ConsentPurpose(
        noticePurposeId: 'np2',
        purposeId: 'p-optional',
        purposeCode: 'MARKETING',
        purposeName: 'Marketing',
        purposeDescription: '',
        isMandatory: false,
        validityDays: 30,
        retentionDays: 30,
        displayOrder: 2,
        alreadyGranted: false,
        categories: [],
      ),
    ],
  );
}
