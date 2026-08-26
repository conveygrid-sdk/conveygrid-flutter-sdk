abstract interface class SessionStore {
  Future<String> getOrCreateAnonymousSessionId();
}

abstract interface class PreferenceCacheStore {
  Future<void> saveJson(String key, String value);
  Future<String?> readJson(String key);
  Future<void> clear(String key);
}
