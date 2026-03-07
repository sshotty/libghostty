import 'package:meta/meta.dart';

import '../color.dart';

/// Default colors and scrollback limit for a [Terminal].
///
/// ```dart
/// final terminal = Terminal(
///   cols: 80,
///   rows: 24,
///   options: TerminalOptions(
///     foreground: RgbColor(255, 255, 255),
///     background: RgbColor(0, 0, 0),
///     scrollbackLimit: 5000,
///   ),
/// );
/// ```
@immutable
class TerminalOptions {
  final RgbColor? foreground;
  final RgbColor? background;

  /// Maximum number of scrollback rows. Defaults to 10,000.
  final int scrollbackLimit;

  const TerminalOptions({
    this.foreground,
    this.background,
    this.scrollbackLimit = 10_000,
  });

  @override
  int get hashCode => Object.hash(foreground, background, scrollbackLimit);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TerminalOptions &&
          foreground == other.foreground &&
          background == other.background &&
          scrollbackLimit == other.scrollbackLimit;
}
