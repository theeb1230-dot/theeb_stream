import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:theeb_stream/services/tmdb_api_service.dart';

void main() {
  test('direct multi search sends Arabic locale and disables adult results', () async {
    Uri? captured;
    TmdbApiService.setHttpClient(
      MockClient((request) async {
        captured = request.url;
        return http.Response(jsonEncode({'results': []}), 200);
      }),
    );

    final result = await TmdbApiService.searchAll('الذئب', page: 2);

    expect(result, isEmpty);
    expect(captured, isNotNull);
    expect(captured!.path, '/3/search/multi');
    expect(captured!.queryParameters['query'], 'الذئب');
    expect(captured!.queryParameters['page'], '2');
    expect(captured!.queryParameters['include_adult'], 'false');
    expect(captured!.queryParameters['language'], 'ar-SA');
    expect(captured!.queryParameters['api_key'], isNotEmpty);
  });
}
