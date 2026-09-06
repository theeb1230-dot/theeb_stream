import 'package:flutter/foundation.dart';

import '../models/movie.dart';

/// Compatibility layer for the former account-backed cloud sync feature.
///
/// Theeb Stream is intentionally account-free. Watch history and watchlist are
/// persisted by their existing local repositories, while these methods remain
/// as safe no-ops so callers do not need account or Firebase state.
class CloudSyncService {
  static final ValueNotifier<int> historyRevision = ValueNotifier<int>(0);
  static final ValueNotifier<int> watchlistRevision = ValueNotifier<int>(0);

  static String watchHistoryKey(
    String tmdbId,
    bool isMovie,
    int season,
    int episode,
  ) {
    return isMovie ? 'movie_$tmdbId' : 'tv_${tmdbId}_${season}_$episode';
  }

  static String watchlistKey(String id, String mediaType) => '${id}_$mediaType';

  static Future<void> pushEntireWatchlist() async {}

  static void startListening() {}

  static void stopListening() {}

  static Future<void> pushWatchProgress(Map<String, dynamic> item) async {}

  static Future<void> deleteWatchProgress(
    String tmdbId,
    bool isMovie,
    int season,
    int episode,
  ) async {}

  static Future<void> pushWatchlist(Movie movie) async {
    // Local watchlist persistence is handled by DBHelper at the call site.
    watchlistRevision.value++;
  }

  static Future<void> deleteWatchlist(String id, String mediaType) async {
    // Local watchlist persistence is handled by DBHelper at the call site.
    watchlistRevision.value++;
  }

  static Future<void> pullToDevice() async {
    // Local state is already authoritative in the account-free product.
    historyRevision.value++;
    watchlistRevision.value++;
  }
}
