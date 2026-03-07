import 'package:meta/meta.dart';

import 'exceptions.dart';

abstract class Disposable {
  final String _typeName;
  var _disposed = false;

  Disposable(this._typeName);

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    releaseResources();
  }

  @protected
  void ensureNotDisposed() {
    if (_disposed) throw DisposedException(_typeName);
  }

  @protected
  void releaseResources();
}
