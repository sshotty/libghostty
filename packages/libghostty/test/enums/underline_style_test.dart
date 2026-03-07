import 'package:libghostty/src/enums/underline_style.dart';
import 'package:test/test.dart';

void main() {
  group('UnderlineStyle', () {
    test('fromNative round-trips for all values', () {
      for (final style in UnderlineStyle.values) {
        expect(UnderlineStyleNative.fromNative(style.nativeValue), style);
      }
    });

    test('fromNative returns none for out-of-bounds values', () {
      expect(UnderlineStyleNative.fromNative(-1), UnderlineStyle.none);
      expect(UnderlineStyleNative.fromNative(999), UnderlineStyle.none);
    });
  });
}
