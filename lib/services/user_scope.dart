/// Resolves the local-data owner without requiring an account.
///
/// Theeb Stream no longer requires authentication. Keep one stable owner id so
/// watch history and watchlist remain consistent across launches on this device.
class UserScope {
  static const String anonymousOwner = '__local__';
  static const String legacyOwner = '__legacy__';

  /// Test hook. Production uses the stable local owner.
  static String Function()? ownerResolver;

  static String get currentOwner {
    final injected = ownerResolver;
    if (injected != null) return _normalize(injected());
    return anonymousOwner;
  }

  static String _normalize(String? owner) {
    final value = owner?.trim() ?? '';
    return value.isEmpty ? anonymousOwner : value;
  }
}
