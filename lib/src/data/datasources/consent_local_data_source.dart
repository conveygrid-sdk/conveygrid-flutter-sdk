import 'dart:convert';

import 'package:conveygrid_flutter_sdk/src/core/constants/convey_grid_constants.dart';
import 'package:conveygrid_flutter_sdk/src/core/storage/storage_contracts.dart';
import 'package:conveygrid_flutter_sdk/src/domain/entities/cookie_preference.dart';

abstract interface class ConsentLocalDataSource {
  Future<void> cacheCookiePreference(CookiePreference preference);
  Future<CookiePreference?> readCookiePreference();
  Future<void> cacheNoticeVersion(String noticeCode, String version);
  Future<String?> readNoticeVersion(String noticeCode);
}

final class ConsentLocalDataSourceImpl implements ConsentLocalDataSource {
  ConsentLocalDataSourceImpl(this._cache);

  final PreferenceCacheStore _cache;

  @override
  Future<void> cacheCookiePreference(CookiePreference preference) async {
    final payload = jsonEncode({
      'version': preference.version,
      'preference_token': preference.preferenceToken,
      'recorded_at': preference.recordedAt?.toIso8601String(),
      'choices': preference.choices.map((c) => c.toJson()).toList(),
    });
    await _cache.saveJson(ConveyGridStorageKeys.cookiePreferenceCache, payload);
    await _cache.saveJson(
      ConveyGridStorageKeys.lastSyncTimestamp,
      DateTime.now().toUtc().toIso8601String(),
    );
  }

  @override
  Future<CookiePreference?> readCookiePreference() async {
    final raw =
        await _cache.readJson(ConveyGridStorageKeys.cookiePreferenceCache);
    if (raw == null) {
      return null;
    }
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return CookiePreference(
      version: json['version'] as String? ?? '',
      preferenceToken: json['preference_token'] as String?,
      recordedAt: json['recorded_at'] != null
          ? DateTime.tryParse(json['recorded_at'] as String)
          : null,
      choices: (json['choices'] as List<dynamic>? ?? [])
          .map(
            (e) => CookieCategoryChoice(
              categoryCode:
                  (e as Map<String, dynamic>)['category_code'] as String,
              granted: e['granted'] as bool? ?? false,
            ),
          )
          .toList(),
    );
  }

  @override
  Future<void> cacheNoticeVersion(String noticeCode, String version) {
    return _cache.saveJson(
      '${ConveyGridStorageKeys.noticeVersionCache}_$noticeCode',
      version,
    );
  }

  @override
  Future<String?> readNoticeVersion(String noticeCode) {
    return _cache.readJson(
      '${ConveyGridStorageKeys.noticeVersionCache}_$noticeCode',
    );
  }
}
