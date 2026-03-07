import 'exceptions.dart';

const _success = 0;
const _outOfMemory = -1;
const _invalidValue = -2;

Never throwResult(int result) {
  switch (result) {
    case _outOfMemory:
      throw const OutOfMemoryException();
    case _invalidValue:
      throw const InvalidValueException();
    default:
      throw StateError('Unknown error code: $result');
  }
}

void checkResult(int result) {
  if (result != _success) {
    throwResult(result);
  }
}
