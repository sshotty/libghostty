import 'package:libghostty/libghostty.dart';
import 'package:test/test.dart';

void main() {
  group('LibGhosttyException', () {
    test('OutOfMemoryException has default message', () {
      const exception = OutOfMemoryException();
      expect(exception.message, 'Memory allocation failed.');
      expect(exception.toString(), 'Memory allocation failed.');
    });

    test('OutOfMemoryException accepts custom message', () {
      const exception = OutOfMemoryException('Custom OOM message');
      expect(exception.message, 'Custom OOM message');
    });

    test('InvalidValueException has default message', () {
      const exception = InvalidValueException();
      expect(exception.message, 'Invalid value provided.');
      expect(exception.toString(), 'Invalid value provided.');
    });

    test('InvalidValueException accepts custom message', () {
      const exception = InvalidValueException('Bad input');
      expect(exception.message, 'Bad input');
    });

    test('DisposedException formats message with type name', () {
      const exception = DisposedException('Terminal');
      expect(exception.typeName, 'Terminal');
      expect(exception.message, contains('Terminal'));
      expect(exception.message, contains('disposed'));
      expect(exception.toString(), exception.message);
    });

    test('sealed class pattern matching covers all subtypes', () {
      String describe(LibGhosttyException e) {
        return switch (e) {
          OutOfMemoryException() => 'oom',
          InvalidValueException() => 'invalid',
          DisposedException() => 'disposed',
        };
      }

      expect(describe(const OutOfMemoryException()), 'oom');
      expect(describe(const InvalidValueException()), 'invalid');
      expect(describe(const DisposedException('X')), 'disposed');
    });
  });
}
