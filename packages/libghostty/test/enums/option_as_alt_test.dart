import 'package:libghostty/src/enums/option_as_alt.dart';
import 'package:test/test.dart';

void main() {
  group('OptionAsAlt', () {
    test('nativeValue equals index for all values', () {
      for (final option in OptionAsAlt.values) {
        expect(option.nativeValue, option.index);
      }
    });
  });
}
