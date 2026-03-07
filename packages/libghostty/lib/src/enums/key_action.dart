import 'package:meta/meta.dart';

/// Keyboard key state transition.
///
/// ```dart
/// event.action = KeyAction.press;
/// ```
enum KeyAction {
  release(0),
  press(1),
  repeat(2);

  @internal
  final int nativeValue;

  const KeyAction(this.nativeValue);

  @internal
  static KeyAction fromNative(int value) {
    return KeyAction.values.firstWhere(
      (e) => e.nativeValue == value,
      orElse: () => KeyAction.press,
    );
  }
}
