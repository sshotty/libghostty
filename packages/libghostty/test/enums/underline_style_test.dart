import 'package:libghostty/libghostty.dart';
import 'package:test/test.dart';

void main() {
  group('UnderlineStyle', () {
    test('fromNative round-trips for all values', () {
      for (final style in UnderlineStyle.values) {
        expect(UnderlineStyle.fromNative(style.nativeValue), style);
      }
    });

    test('fromNative returns none for out-of-bounds values', () {
      expect(UnderlineStyle.fromNative(-1), UnderlineStyle.none);
      expect(UnderlineStyle.fromNative(999), UnderlineStyle.none);
    });
  });
}
