import 'dart:io';
import 'package:image/image.dart' as img;

void main() async {
  const size = 1024;
  const colorStart = 0xFF0B4F6C;
  const colorEnd = 0xFF2AC4A4;
  final image = img.Image(width: size, height: size);

  for (var y = 0; y < size; y++) {
    final tY = y / (size - 1);
    for (var x = 0; x < size; x++) {
      final tX = x / (size - 1);
      final t = (tX + tY) / 2; // diagonal blend
      final r = _lerp((colorStart >> 16) & 0xFF, (colorEnd >> 16) & 0xFF, t);
      final g = _lerp((colorStart >> 8) & 0xFF, (colorEnd >> 8) & 0xFF, t);
      final b = _lerp(colorStart & 0xFF, colorEnd & 0xFF, t);
      image.setPixelRgba(x, y, r, g, b, 255);
    }
  }

  const stroke = 88;
  final white = img.ColorInt8.rgb(255, 255, 255);
  img.drawLine(
    image,
    x1: 320,
    y1: 536,
    x2: 470,
    y2: 686,
    color: white,
    thickness: stroke,
    antialias: true,
  );
  img.drawLine(
    image,
    x1: 470,
    y1: 686,
    x2: 760,
    y2: 330,
    color: white,
    thickness: stroke,
    antialias: true,
  );

  final file = File('assets/icon/app_icon.png');
  await file.create(recursive: true);
  await file.writeAsBytes(img.encodePng(image));
  stdout.writeln('Generated ${file.path}');
}

int _lerp(int a, int b, double t) => a + ((b - a) * t).round();
