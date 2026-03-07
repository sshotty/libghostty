import 'package:libghostty/src/enums/key.dart';
import 'package:test/test.dart';

void main() {
  group('Key', () {
    test('fromNative round-trips for all values', () {
      for (final key in Key.values) {
        expect(KeyNative.fromNative(key.nativeValue), key);
      }
    });

    test('fromNative returns unidentified for out-of-bounds values', () {
      expect(KeyNative.fromNative(-1), Key.unidentified);
      expect(KeyNative.fromNative(Key.values.length), Key.unidentified);
      expect(KeyNative.fromNative(999), Key.unidentified);
    });
  });
}
