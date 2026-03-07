import 'package:libghostty/input.dart';
import 'package:test/test.dart';

void main() {
  group('KeyAction', () {
    test('fromNative round-trips for all values', () {
      for (final action in KeyAction.values) {
        expect(KeyAction.fromNative(action.nativeValue), action);
      }
    });

    test('fromNative defaults to press for unknown values', () {
      expect(KeyAction.fromNative(-1), KeyAction.press);
      expect(KeyAction.fromNative(3), KeyAction.press);
      expect(KeyAction.fromNative(999), KeyAction.press);
    });
  });
}
