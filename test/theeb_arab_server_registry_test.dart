import 'package:flutter_test/flutter_test.dart';
import 'package:maxstream/services/theeb_arab_server_registry.dart';

void main() {
  test('Theeb Arab migration inventory contains exactly 27 unique servers', () {
    expect(TheebArabServerRegistry.all, hasLength(27));
    expect(
      TheebArabServerRegistry.all.map((server) => server.id).toSet(),
      hasLength(27),
    );
    expect(
      TheebArabServerRegistry.all.map((server) => server.name).toSet(),
      hasLength(27),
    );
  });

  test('known runtime overlaps are deduplicated instead of added twice', () {
    expect(
      TheebArabServerRegistry.integrated.map((server) => server.name).toList(),
      containsAll(<String>['Videasy', 'VidFast', '2Embed', 'Frembed', 'VidLink']),
    );
    expect(TheebArabServerRegistry.integrated, hasLength(5));
    expect(TheebArabServerRegistry.pending, hasLength(22));
  });
}
