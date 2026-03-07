import 'package:meta/meta.dart';

/// Kitty keyboard protocol mode flags.
///
/// Bitflags controlling the progressive enhancement modes of the Kitty
/// keyboard protocol.
///
/// ```dart
/// final flags =
///     KittyKeyFlags.disambiguate | KittyKeyFlags.reportEvents;
/// print(flags.isDisabled); // false
/// ```
@immutable
final class KittyKeyFlags {
  static const disabled = KittyKeyFlags(0);
  static const disambiguate = KittyKeyFlags(1 << 0);
  static const reportEvents = KittyKeyFlags(1 << 1);
  static const reportAlternates = KittyKeyFlags(1 << 2);
  static const reportAll = KittyKeyFlags(1 << 3);
  static const reportAssociated = KittyKeyFlags(1 << 4);
  static const all = KittyKeyFlags(0x1F);

  final int _value;

  const KittyKeyFlags(this._value);

  @override
  int get hashCode => _value.hashCode;

  bool get isDisabled => _value == 0;

  @override
  bool operator ==(Object other) =>
      other is KittyKeyFlags && other._value == _value;

  KittyKeyFlags operator |(KittyKeyFlags other) =>
      KittyKeyFlags(_value | other._value);

  @override
  String toString() => 'KittyKeyFlags(0x${_value.toRadixString(16)})';
}

extension KittyKeyFlagsNative on KittyKeyFlags {
  int get value => _value;
}
