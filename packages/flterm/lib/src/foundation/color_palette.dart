import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';

/// A resolved 256-color terminal palette as Flutter [Color] values.
///
/// Indices 0–15 hold the configurable ANSI base colors. Indices 16–231
/// use the standard 6×6×6 RGB color cube, consistent with xterm and Ghostty.
/// Indices 232–255 are a 24-step grayscale ramp.
///
/// ```dart
/// final palette = ColorPalette.fromAnsiColors(myAnsiColors);
/// final red = palette[NamedColor.red]; // index 1
/// ```
@immutable
final class ColorPalette {
  final List<Color> _colors;

  /// Generates a [ColorPalette] from 16 ANSI base colors.
  ///
  /// [ansiColors] must contain exactly 16 entries (indices 0–15).
  /// Indices 16–255 are generated using the standard xterm formula:
  /// - 16–231: 6×6×6 RGB cube where each axis value is
  ///   `(v == 0) ? 0 : v * 40 + 55` for v in 0..5
  /// - 232–255: grayscale ramp `(i - 232) * 10 + 8`
  factory ColorPalette.fromAnsiColors(List<Color> ansiColors) {
    if (ansiColors.length != 16) {
      throw ArgumentError.value(
        ansiColors.length,
        'ansiColors',
        'must contain exactly 16 colors',
      );
    }

    final colors = List<Color>.filled(256, const Color(0xFF000000));

    // Indices 0–15: user-supplied ANSI colors.
    for (var i = 0; i < 16; i++) {
      colors[i] = ansiColors[i];
    }

    // Indices 16–231: standard 6×6×6 RGB cube.
    var idx = 16;
    for (var r = 0; r < 6; r++) {
      for (var g = 0; g < 6; g++) {
        for (var b = 0; b < 6; b++) {
          colors[idx++] = Color.fromARGB(
            255,
            r == 0 ? 0 : r * 40 + 55,
            g == 0 ? 0 : g * 40 + 55,
            b == 0 ? 0 : b * 40 + 55,
          );
        }
      }
    }

    // Indices 232–255: 24-step grayscale ramp.
    for (var i = 232; i < 256; i++) {
      final v = (i - 232) * 10 + 8;
      colors[i] = Color.fromARGB(255, v, v, v);
    }

    return ColorPalette._(List<Color>.unmodifiable(colors));
  }

  const ColorPalette._(this._colors)
    : assert(_colors.length == 256, 'palette must contain exactly 256 colors');

  @override
  int get hashCode => Object.hashAll(_colors);

  @override
  bool operator ==(Object other) {
    if (other is! ColorPalette) return false;
    for (var i = 0; i < 256; i++) {
      if (_colors[i] != other._colors[i]) return false;
    }
    return true;
  }

  /// Returns the [Color] at the given palette [index] (0–255).
  Color operator [](int index) => _colors[index];

  /// Linearly interpolates between two palettes.
  ///
  /// Each of the 256 entries is interpolated independently via [Color.lerp].
  /// Used by [TerminalTheme.lerp] for animated theme transitions.
  static ColorPalette? lerp(ColorPalette? begin, ColorPalette? end, double t) {
    if (identical(begin, end)) return begin;
    if (begin == null || end == null) return t < 0.5 ? begin : end;
    return ColorPalette._(
      .unmodifiable(.generate(256, (i) => Color.lerp(begin[i], end[i], t)!)),
    );
  }
}
