@Tags(['ffi'])
library;

import 'package:libghostty/libghostty.dart';
import 'package:test/test.dart';

void main() {
  group('MouseShape', () {
    test('native values are sequential 0..33', () {
      expect(MouseShape.values.length, 34);
      for (var i = 0; i < MouseShape.values.length; i++) {
        expect(MouseShape.values[i].nativeValue, i);
      }
    });

    test('fromNative round-trips for every value', () {
      for (final shape in MouseShape.values) {
        expect(MouseShape.fromNative(shape.nativeValue), shape);
      }
    });

    test('fromNative returns text for unknown values', () {
      expect(MouseShape.fromNative(-1), MouseShape.text);
      expect(MouseShape.fromNative(34), MouseShape.text);
      expect(MouseShape.fromNative(999), MouseShape.text);
    });
  });
}
