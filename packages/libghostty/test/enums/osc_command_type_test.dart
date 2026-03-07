import 'package:libghostty/parsing.dart';
import 'package:test/test.dart';

void main() {
  group('OscCommandType', () {
    test('fromNative round-trips for all values', () {
      for (final type in OscCommandType.values) {
        expect(OscCommandType.fromNative(type.nativeValue), type);
      }
    });

    test('fromNative returns invalid for out-of-bounds values', () {
      expect(OscCommandType.fromNative(-1), OscCommandType.invalid);
      expect(OscCommandType.fromNative(999), OscCommandType.invalid);
    });
  });
}
