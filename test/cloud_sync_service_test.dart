import 'package:flutter_test/flutter_test.dart';
import 'package:theeb_stream/services/cloud_sync_service.dart';

void main() {
  test('pullToDevice does not emit revision notifications in account-free mode', () async {
    var historyNotifications = 0;
    var watchlistNotifications = 0;

    void onHistory() => historyNotifications++;
    void onWatchlist() => watchlistNotifications++;

    CloudSyncService.historyRevision.addListener(onHistory);
    CloudSyncService.watchlistRevision.addListener(onWatchlist);

    try {
      final historyBefore = CloudSyncService.historyRevision.value;
      final watchlistBefore = CloudSyncService.watchlistRevision.value;

      await CloudSyncService.pullToDevice();
      await CloudSyncService.pullToDevice();

      expect(CloudSyncService.historyRevision.value, historyBefore);
      expect(CloudSyncService.watchlistRevision.value, watchlistBefore);
      expect(historyNotifications, 0);
      expect(watchlistNotifications, 0);
    } finally {
      CloudSyncService.historyRevision.removeListener(onHistory);
      CloudSyncService.watchlistRevision.removeListener(onWatchlist);
    }
  });

  test('local watchlist mutations still emit watchlist revisions', () async {
    var notifications = 0;
    void listener() => notifications++;
    CloudSyncService.watchlistRevision.addListener(listener);

    try {
      final before = CloudSyncService.watchlistRevision.value;
      await CloudSyncService.deleteWatchlist('123', 'movie');

      expect(CloudSyncService.watchlistRevision.value, before + 1);
      expect(notifications, 1);
    } finally {
      CloudSyncService.watchlistRevision.removeListener(listener);
    }
  });
}
