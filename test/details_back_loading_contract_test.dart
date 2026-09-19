import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('details route remains poppable while loading', () {
    final source =
        File('lib/screens/maxstream_details_screen.dart').readAsStringSync();

    expect(source, contains('return PopScope('));
    expect(source, contains('canPop: true'));
    expect(source, contains('? buildLoadingShimmer()'));
    expect(source, contains('Widget buildLoadingShimmer()'));
    expect(source, contains('leading: BackButton('));
    expect(source, contains('Navigator.of(context).maybePop()'));
  });

  test('system back pauses trailer after a successful pop', () {
    final source =
        File('lib/screens/maxstream_details_screen.dart').readAsStringSync();

    expect(source, contains('onPopInvoked: (didPop)'));
    expect(source, contains('if (didPop)'));
    expect(source, contains('_youtubeController?.pause()'));
  });
}
