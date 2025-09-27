// lib/ui/widgets/marker.dart
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../app/routes.dart';
import '../../data/models/coffee_shop.dart';

/// Creates a custom circular coffee marker icon.
Future<BitmapDescriptor> createCoffeeMarkerIcon() async {
  const double size = 100.0;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  final center = const Offset(size / 2, size / 2);

  // === Shadow ===
  final shadowPaint = Paint()
    ..color = const ui.Color.fromARGB(100, 0, 0, 0); // semi-transparent black
  canvas.drawCircle(center, size / 100, shadowPaint);

  // === Circle background ===
  final bgPaint = Paint()
    ..color = const ui.Color.fromARGB(255, 255, 255, 255); // white fill
  canvas.drawCircle(center, size / 2 - 4, bgPaint);

  // === Border ===
  final borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4
    ..color = const ui.Color.fromARGB(255, 106, 61, 2);
  canvas.drawCircle(center, size / 2 - 4, borderPaint);

  // === Emoji ☕ ===
  final textPainter = TextPainter(
    text: const TextSpan(
      text: "☕",
      style: TextStyle(
        fontSize: 60,
        color: CupertinoColors.activeOrange, // matches border
      ),
    ),
    textDirection: TextDirection.ltr,
    textAlign: TextAlign.center,
  );
  textPainter.layout();
  textPainter.paint(
    canvas,
    Offset(
      (size - textPainter.width) / 2,
      (size - textPainter.height) / 2,
    ),
  );

  final picture = recorder.endRecording();
  final image = await picture.toImage(size.toInt(), size.toInt());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

  return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
}

/// Creates a Google Map marker for a [CoffeeShop].
Future<Marker> createShopMarker(BuildContext context, CoffeeShop shop) async {
  final icon = await createCoffeeMarkerIcon();

  return Marker(
    markerId: MarkerId(shop.id),
    position: LatLng(shop.lat, shop.lng),
    icon: icon,
    infoWindow: InfoWindow(
      title: shop.name,
      snippet: shop.address ?? '',
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.shopDetail,
          arguments: shop.id,
        );
      },
    ),
  );
}
