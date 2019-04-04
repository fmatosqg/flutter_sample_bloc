import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class GlowingButton extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GlowingButtonState();
}

class _GlowingButtonState extends State<GlowingButton> {
  bool _wasTapped = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(0),
      color: Colors.black.withOpacity(0.6),
      child: GestureDetector(
        child: CustomPaint(
          size: Size(200, 200),
          painter: _SparksPainter(_wasTapped),
        ),
        onTap: () {
          setState(() {
            _wasTapped = true;
          });
        },
      ),
    );
  }
}

class _SparksPainter extends CustomPainter {
  Offset _updatedPosition;
  Offset _updatedSize;

  List<Offset> _offsets = List();

  final bool _wasTapped;

  _SparksPainter(this._wasTapped) {
    _updatedPosition = Offset(50, 50);
    _updatedSize = Offset(100, 50);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  init(RRect rect) {
    var dx = 4;
    var dy = 4;

    for (double x = rect.left; x < rect.right; x += dx) {
      for (double y = rect.top; y < rect.bottom; y += dy) {
        var offset = Offset(x, y);
        if (rect.contains(offset)) {
          _offsets.add(offset);
        }
      }
    }
  }

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    // draw rect with primitive
    double sigma = 10.0;

    Paint paint = Paint();

    paint.color = Colors.yellow;

    paint.maskFilter = MaskFilter.blur(BlurStyle.outer, sigma);

    Rect rect =
        Rect.fromPoints(_updatedPosition, _updatedPosition + _updatedSize);

    RRect rrect = RRect.fromRectAndRadius(rect, Radius.circular(10));

    canvas.drawRRect(rrect, paint);

    // draw rect with collection of pixels
    init(rrect);
    double sz = 1;
    Paint paintPixels = Paint();

    paintPixels.maskFilter = MaskFilter.blur(BlurStyle.normal, 1);

    var r = Random(1);

    for (Offset offset in _offsets) {
      paintPixels.color = Colors.yellow.withOpacity(r.nextDouble());
      canvas.drawCircle(offset + Offset(sz, sz), sz * 2, paintPixels);
    }

    //
    if (_wasTapped) {
//      ui.Paragraph paragraph = ui.ParagraphBuilder(ui.ParagraphStyle())
//        ..addText("ello")
//          .build();

      var newPaint = Paint();
      newPaint.color = Colors.red;
      canvas.drawCircle(Offset(40, 40), 10, newPaint);

//      ui.ParagraphBuilder builder = ui.ParagraphBuilder(ui.ParagraphStyle());
//
//      builder.addText("aaaa");
//
//      ui.Paragraph paragraph = builder.build();
//
////      debugPrint(paragraph.toString());
//
//      canvas.drawParagraph(paragraph, Offset(10, 10));
    }
  }
}
