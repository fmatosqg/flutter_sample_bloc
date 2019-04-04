import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class GlowingButton extends StatefulWidget {
  Size _size;

  GlowingButton(this._size);

  @override
  State<StatefulWidget> createState() => _GlowingButtonState();
}

class _GlowingButtonState extends State<GlowingButton>
    with TickerProviderStateMixin {
  bool _wasTapped = false;

  List<Dot> listDot;
  AnimationController animationController;

  var _updatedPosition = Offset(50, 50);
  var _updatedSize = Offset(100, 50);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(0),
      color: Colors.black.withOpacity(0.6),
      child: GestureDetector(
        child: AnimatedBuilder(
          animation: new CurvedAnimation(
              parent: animationController, curve: Curves.easeInOut),
          builder: _animatedBuilder,
        ),
        onTap: () {
          setState(() {
            animationController.forward(from: 0);
            _wasTapped = true;
          });
        },
      ),
    );
  }

  @override
  void reassemble() {
    super.reassemble();
    _init();
    animationController.forward(from: 0);
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    var dotCount = 10;

    var random = Random();
    listDot = [];

    double dx = _updatedSize.dx / dotCount.ceilToDouble();
    double dy = _updatedSize.dy / dotCount.ceilToDouble();

    for (double x = _updatedPosition.dx;
        x < _updatedPosition.dx + _updatedSize.dx;
        x += dx) {
      for (double y = _updatedPosition.dy;
          y < _updatedPosition.dy + _updatedSize.dy;
          y += dy) {
        var offset = Offset(x, y);
        var speed =
            new Offset(random.nextDouble() - 0.5, random.nextDouble() - 0.5);
        listDot.add(Dot(offset, speed));
      }
    }

    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 30),
    )..addListener(() {
        for (var node in listDot) {
          node.move(animationController.value);
        }
      });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Widget _animatedBuilder(BuildContext context, Widget child) {
    return CustomPaint(
      size: Size(200, 200),
      painter:
          _SparksPainter(_wasTapped, listDot, _updatedPosition, _updatedSize),
    );
  }
}

class _SparksPainter extends CustomPainter {
  Offset _updatedPosition;
  Offset _updatedSize;

  List<Offset> _offsets = List();
  List<Dot> _listDot;

  final bool _wasTapped;

  _SparksPainter(
      this._wasTapped, this._listDot, this._updatedPosition, this._updatedSize);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    Paint paint = Paint();
    paint.color = Colors.yellow[100];
    double sigma = 10.0;

    paint.maskFilter = MaskFilter.blur(BlurStyle.outer, sigma);

    for (var dot in _listDot) {
      dot.draw(canvas, paint);
    }

    // draw rect with primitive

    Rect rect =
        Rect.fromPoints(_updatedPosition, _updatedPosition + _updatedSize);

    RRect rrect = RRect.fromRectAndRadius(rect, Radius.circular(10));

    canvas.drawRRect(rrect, paint);

    var paintSolid = Paint();
    paintSolid.color = Colors.lightBlue[100];
    paintSolid.style = PaintingStyle.stroke;
    paintSolid.strokeWidth = 2;
    canvas.drawRRect(rrect, paintSolid);

    double sz = 1;
    Paint paintPixels = Paint();

    paintPixels.maskFilter = MaskFilter.blur(BlurStyle.normal, 1);

    var r = Random(1);

    for (Offset offset in _offsets) {
      paintPixels.color = Colors.yellow.withOpacity(r.nextDouble());
      canvas.drawCircle(offset + Offset(sz, sz), sz * 2, paintPixels);
    }
  }
}

class Dot {
  final Offset _initialPosition;
  final Offset _initialSpeed;

  Offset _updatedPosition;
  double _brightness;

  Dot(this._initialPosition, this._initialSpeed);

  void move(double dt) {
    double curveFactor = Curves.decelerate.transform(dt);

    double a = 0.9;
    double b = 1.0 - a;
    curveFactor = 1.0 - pow(1.0 - dt, 2 * 10) * a - (1.0 - dt) * b;

    _brightness = 1.0 - curveFactor;

    Offset translation = _initialSpeed * curveFactor * 400.0;

    _updatedPosition = _initialPosition + translation;
  }

  void draw(Canvas canvas, Paint paint) {
//    double size = 3.9;

    var sizeSolid = 4.0 * _brightness;

    var sizeFuzzy = sizeSolid * 3.0;

    double sigma = 4.0;

    Paint paint = Paint();

    Offset center = Offset(_updatedPosition.dx, _updatedPosition.dy);
    Offset offFuzzy = Offset(sizeFuzzy / 2, sizeFuzzy / 2);
    Rect rectFuzzy = Rect.fromPoints(center - offFuzzy, center + offFuzzy);

    paint.color = Colors.yellow;

    paint.maskFilter = MaskFilter.blur(BlurStyle.normal, sigma);
    canvas.drawOval(rectFuzzy, paint);

    paint.maskFilter = null;
    Offset offSolid = Offset(sizeSolid / 2, sizeSolid / 2);
    Rect rectSolid = Rect.fromPoints(center - offSolid, center + offSolid);
    canvas.drawOval(rectSolid, paint);
  }
}
