enum SourceHealthState {
  notTested,
  playbackStarted,
  urlExtracted,
  failed,
  webViewRequired,
  unsupported,
}

extension SourceHealthStateUi on SourceHealthState {
  String get arabicLabel => switch (this) {
        SourceHealthState.notTested => 'لم يُختبر',
        SourceHealthState.playbackStarted => 'بدأ فعليًا',
        SourceHealthState.urlExtracted => 'رابط مستخرج',
        SourceHealthState.failed => 'فشل',
        SourceHealthState.webViewRequired => 'غير مؤكد / يتطلب WebView',
        SourceHealthState.unsupported => 'غير مدعوم',
      };

  bool get isPlaybackConfirmed => this == SourceHealthState.playbackStarted;
  bool get isFailure => this == SourceHealthState.failed;
  bool get isUnverified => switch (this) {
        SourceHealthState.notTested ||
        SourceHealthState.urlExtracted ||
        SourceHealthState.webViewRequired ||
        SourceHealthState.unsupported => true,
        SourceHealthState.playbackStarted || SourceHealthState.failed => false,
      };
}

SourceHealthState sourceHealthStateFromRuntime({
  required bool available,
  required bool playbackStarted,
  required String? url,
  bool requiresWebView = false,
  bool supported = true,
}) {
  if (!supported) return SourceHealthState.unsupported;
  if (playbackStarted && available && (url?.isNotEmpty ?? false)) {
    return SourceHealthState.playbackStarted;
  }
  if (available && (url?.isNotEmpty ?? false)) {
    return SourceHealthState.urlExtracted;
  }
  if (requiresWebView) return SourceHealthState.webViewRequired;
  return SourceHealthState.failed;
}
