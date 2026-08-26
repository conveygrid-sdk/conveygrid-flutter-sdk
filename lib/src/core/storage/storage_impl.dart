import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:conveygrid_flutter_sdk/src/core/constants/convey_grid_constants.dart';
import 'package:conveygrid_flutter_sdk/src/core/storage/storage_contracts.dart';

final class SecureSessionStore implements SessionStore {
  SecureSessionStore({
    FlutterSecureStorage? storage,
    Uuid? uuid,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _uuid = uuid ?? const Uuid();

  final FlutterSecureStorage _storage;
  final Uuid _uuid;

  @override
  Future<String> getOrCreateAnonymousSessionId() async {
    final existing = await _storage.read(
      key: ConveyGridStorageKeys.anonymousSessionId,
    );
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final created =
        '${ConveyGridConstants.anonymousSessionPrefix}${_uuid.v4()}';
    await _storage.write(
      key: ConveyGridStorageKeys.anonymousSessionId,
      value: created,
    );
    return created;
  }
}

final class SharedPreferencesCacheStore implements PreferenceCacheStore {
  SharedPreferencesCacheStore({SharedPreferences? preferences})
      : _preferences = preferences;

  SharedPreferences? _preferences;

  Future<SharedPreferences> _prefs() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  @override
  Future<void> saveJson(String key, String value) async {
    final prefs = await _prefs();
    await prefs.setString(key, value);
  }

  @override
  Future<String?> readJson(String key) async {
    final prefs = await _prefs();
    return prefs.getString(key);
  }

  @override
  Future<void> clear(String key) async {
    final prefs = await _prefs();
    await prefs.remove(key);
  }
}
