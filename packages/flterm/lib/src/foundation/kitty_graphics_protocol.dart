import 'dart:convert';
import 'dart:typed_data';

class KittyGraphicsProtocol {
  static Uint8List imageEscape({
    required int placementId,
    required Uint8List imageBytes,
    String format = 'png',
    int? width,
    int? height,
  }) {
    final base64data = base64.encode(imageBytes);
    final formatCode = switch (format.toLowerCase()) {
      'png' => 100,
      _ => 100,
    };
    final buf = StringBuffer()
      ..write('\x1b_Gi=1,a=p,U=1,f=$formatCode,t=d,id=$placementId');

    if (width != null) buf.write(',s=$width');
    if (height != null) buf.write(',v=$height');

    buf.write(';$base64data\x1b\\');
    return Uint8List.fromList(utf8.encode(buf.toString()));
  }

  KittyGraphicsProtocol._();
}
