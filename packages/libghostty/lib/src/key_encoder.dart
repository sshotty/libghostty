import 'bindings/bindings.dart';
import 'disposable.dart';
import 'enums/kitty_key_flags.dart';
import 'enums/option_as_alt.dart';
import 'key_event.dart';

/// Encodes key events into terminal escape sequences.
///
/// ```dart
/// final encoder = KeyEncoder();
/// encoder.setKittyFlags(KittyKeyFlags.all);
///
/// final event = KeyEvent()
///   ..action = KeyAction.press
///   ..key = Key.keyC
///   ..mods = Mods.ctrl;
///
/// final sequence = encoder.encode(event);
/// print(sequence); // the escape sequence bytes
///
/// event.dispose();
/// encoder.dispose();
/// ```
class KeyEncoder extends Disposable {
  static final _finalizer = Finalizer<int>(
    (handle) => bindings.keyEncoderFree(handle),
  );

  final int _handle;

  KeyEncoder() : _handle = bindings.keyEncoderNew(), super('KeyEncoder') {
    _finalizer.attach(this, _handle, detach: this);
  }

  /// Encodes [event] into a terminal escape sequence.
  ///
  /// Returns the escape sequence as a string, or an empty string if the
  /// event does not produce output (e.g., an unmodified modifier key press).
  String encode(KeyEvent event) {
    ensureNotDisposed();
    return bindings.keyEncoderEncode(_handle, event.nativeHandle);
  }

  @override
  void releaseResources() {
    _finalizer.detach(this);
    bindings.keyEncoderFree(_handle);
  }

  /// Sets alt-sends-escape-prefix mode (DECSET 1036).
  void setAltEscPrefix({required bool enabled}) {
    _setOptBool(KeyEncoderOpt.altEscPrefix, enabled);
  }

  /// Sets cursor key application mode (DECSET 1).
  void setCursorKeyApplication({required bool enabled}) {
    _setOptBool(KeyEncoderOpt.cursorKeyApplication, enabled);
  }

  /// Sets ignore-keypad-with-NumLock mode (DECSET 1035).
  void setIgnoreKeypadWithNumLock({required bool enabled}) {
    _setOptBool(KeyEncoderOpt.ignoreKeypadWithNumlock, enabled);
  }

  /// Sets keypad application mode (DECSET 66).
  void setKeypadKeyApplication({required bool enabled}) {
    _setOptBool(KeyEncoderOpt.keypadKeyApplication, enabled);
  }

  /// Sets Kitty keyboard protocol enhancement flags.
  void setKittyFlags(KittyKeyFlags flags) {
    ensureNotDisposed();
    bindings.keyEncoderSetKittyFlags(_handle, flags.value);
  }

  /// Sets xterm modifyOtherKeys mode 2.
  void setModifyOtherKeys({required bool enabled}) {
    _setOptBool(KeyEncoderOpt.modifyOtherKeysState2, enabled);
  }

  /// Sets macOS Option key behavior for encoding.
  void setOptionAsAlt(OptionAsAlt option) {
    ensureNotDisposed();
    bindings.keyEncoderSetOptionAsAlt(_handle, option.nativeValue);
  }

  void _setOptBool(int option, bool enabled) {
    ensureNotDisposed();
    bindings.keyEncoderSetBoolOpt(_handle, option, value: enabled);
  }
}
