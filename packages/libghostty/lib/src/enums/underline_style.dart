/// Underline rendering style for terminal text set via SGR sequences.
enum UnderlineStyle {
  none(0),
  single(1),
  doubleLine(2),
  curly(3),
  dotted(4),
  dashed(5);

  final int _nativeValue;

  const UnderlineStyle(this._nativeValue);
}

extension UnderlineStyleNative on UnderlineStyle {
  static final _nativeMap = {
    for (final style in UnderlineStyle.values) style._nativeValue: style,
  };

  int get nativeValue => _nativeValue;

  static UnderlineStyle fromNative(int value) => _nativeMap[value] ?? .none;
}
