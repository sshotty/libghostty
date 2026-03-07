/// OSC (Operating System Command) sequence types.
///
/// Identifies the type of an OSC escape sequence parsed from terminal
/// output.
///
/// ```dart
/// final command = parser.next();
/// if (command.type == OscCommandType.changeWindowTitle) {
///   print('new title: ${command.data}');
/// }
/// ```
// Maps 1:1 with the native GhosttyOscCommandType enum.
enum OscCommandType {
  invalid(0),
  changeWindowTitle(1),
  changeWindowIcon(2),
  semanticPrompt(3),
  clipboardContents(4),
  reportPwd(5),
  mouseShape(6),
  colorOperation(7),
  kittyColorProtocol(8),
  showDesktopNotification(9),
  hyperlinkStart(10),
  hyperlinkEnd(11),
  conemuSleep(12),
  conemuShowMessageBox(13),
  conemuChangeTabTitle(14),
  conemuProgressReport(15),
  conemuWaitInput(16),
  conemuGuimacro(17),
  conemuRunProcess(18),
  conemuOutputEnvironmentVariable(19),
  conemuXtermEmulation(20),
  conemuComment(21),
  kittyTextSizing(22);

  final int _nativeValue;

  const OscCommandType(this._nativeValue);
}

extension OscCommandTypeNative on OscCommandType {
  static final _nativeMap = {
    for (final type in OscCommandType.values) type._nativeValue: type,
  };

  int get nativeValue => _nativeValue;

  static OscCommandType fromNative(int value) => _nativeMap[value] ?? .invalid;
}
