import 'package:meta/meta.dart';

/// Underline rendering style for terminal text set via SGR sequences.
enum UnderlineStyle {
  none(0),
  single(1),
  doubleLine(2),
  curly(3),
  dotted(4),
  dashed(5);

  static final _nativeMap = {
    for (final style in values) style.nativeValue: style,
  };

  @internal
  final int nativeValue;

  const UnderlineStyle(this.nativeValue);

  @internal
  static UnderlineStyle fromNative(int value) => _nativeMap[value] ?? .none;
}
