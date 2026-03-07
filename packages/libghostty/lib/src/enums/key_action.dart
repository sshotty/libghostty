/// Keyboard key state transition.
///
/// ```dart
/// event.action = KeyAction.press;
/// ```
enum KeyAction {
  release(0),
  press(1),
  repeat(2);

  final int _nativeValue;

  const KeyAction(this._nativeValue);
}

extension KeyActionNative on KeyAction {
  int get nativeValue => _nativeValue;

  static KeyAction fromNative(int value) {
    return KeyAction.values.firstWhere(
      (e) => e._nativeValue == value,
      orElse: () => KeyAction.press,
    );
  }
}
