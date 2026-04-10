import 'package:flterm/src/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ColorPalette', () {
    late ColorPalette palette;

    setUp(() => palette = ColorPalette.fromAnsiColors(_ansiColors));

    test('indices 0–15 match the provided ANSI colors', () {
      for (var i = 0; i < 16; i++) {
        expect(palette[i], _ansiColors[i], reason: 'index $i');
      }
    });

    test('all 256 indices return opaque Colors', () {
      for (var i = 0; i < 256; i++) {
        final c = palette[i];
        expect(c, isA<Color>(), reason: 'index $i');
        expect(
          (c.a * 255.0).round().clamp(0, 255),
          255,
          reason: 'index $i should be opaque',
        );
      }
    });

    test('equality and hashCode', () {
      final other = ColorPalette.fromAnsiColors(_ansiColors);
      expect(palette, equals(other));
      expect(palette.hashCode, other.hashCode);
    });

    test('index 16 is black (cube 0,0,0)', () {
      expect(palette[16], const Color(0xFF000000));
    });

    test('index 231 is white (cube 5,5,5)', () {
      expect(palette[231], const Color(0xFFFFFFFF));
    });

    test('standard cube color at index 196 is red (5,0,0)', () {
      // r=5 → 5*40+55=255, g=0, b=0
      expect(palette[196], const Color(0xFFFF0000));
    });

    test('grayscale ramp values match standard formula', () {
      for (var i = 232; i < 256; i++) {
        final v = (i - 232) * 10 + 8;
        expect(palette[i], Color.fromARGB(255, v, v, v), reason: 'index $i');
      }
    });

    test('requires exactly 16 ANSI colors', () {
      expect(
        () => ColorPalette.fromAnsiColors(const [Color(0xFF000000)]),
        throwsArgumentError,
      );
    });
  });
}

const _ansiColors = [
  Color(0xFF282828), // 0: black
  Color(0xFFCC4242), // 1: red
  Color(0xFF66994C), // 2: green
  Color(0xFFE5B566), // 3: yellow
  Color(0xFF668ECC), // 4: blue
  Color(0xFFB266B2), // 5: magenta
  Color(0xFF4CB2B2), // 6: cyan
  Color(0xFFAAAAAA), // 7: white
  Color(0xFF505050), // 8: bright black
  Color(0xFFE66464), // 9: bright red
  Color(0xFF8CBE6E), // 10: bright green
  Color(0xFFF0C878), // 11: bright yellow
  Color(0xFF82A0DC), // 12: bright blue
  Color(0xFFC882C8), // 13: bright magenta
  Color(0xFF64C8C8), // 14: bright cyan
  Color(0xFFDCDCDC), // 15: bright white
];
