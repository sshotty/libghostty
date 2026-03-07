import 'package:libghostty/input.dart';
import 'package:test/test.dart';

void main() {
  group('Key', () {
    test('fromNative round-trips for all values', () {
      for (final key in Key.values) {
        expect(Key.fromNative(key.nativeValue), key);
      }
    });

    test('fromNative returns unidentified for out-of-bounds values', () {
      expect(Key.fromNative(-1), Key.unidentified);
      expect(Key.fromNative(Key.values.length), Key.unidentified);
      expect(Key.fromNative(999), Key.unidentified);
    });
  });
}
