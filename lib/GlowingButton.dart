import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class GlowingButton extends StatefulWidget {
  final Size _size;
  final Widget _child;

  GlowingButton(this._size, this._child);

  @override
  State<StatefulWidget> createState() => _GlowingButtonState();
}

class _GlowingButtonState extends State<GlowingButton>
    with TickerProviderStateMixin {
  bool _wasTapped = false;

  List<Dot> listDot;
  AnimationController animationController;

  var _updatedPosition = Offset(0, 0);
  var _updatedSize = Offset(150, 50);

  @override
  Widget build(BuildContext context) {
    return Container(
//      color: Colors.blue, // for debugging
      padding:
          EdgeInsets.all(10), // this should cover the blur around the edges
      child: GestureDetector(
        child: AnimatedBuilder(
          animation: new CurvedAnimation(
              parent: animationController, curve: Curves.easeInOut),
          builder: _animatedBuilder,
          child: widget._child,
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
    var random = Random.secure();
    listDot = [];

    double dx = _updatedSize.dx / 10.ceilToDouble();
    double dy = _updatedSize.dy / 4.ceilToDouble();

    // TODO check if the offset falls withing the rounded rectangle
    for (double x = _updatedPosition.dx;
        x <= _updatedPosition.dx + _updatedSize.dx;
        x += dx) {
      for (double y = _updatedPosition.dy;
          y <= _updatedPosition.dy + _updatedSize.dy;
          y += dy) {
        var offset = Offset(x, y);
        var speed =
            new Offset(random.nextDouble() - 0.5, random.nextDouble() - 0.5);
        listDot.add(Dot(offset, speed));
      }
    }

    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
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
    return Stack(
      children: [
        Center(
          child: CustomPaint(
            size: Size(_updatedSize.dx, _updatedSize.dy),
            painter: _SparksPainter(
                _wasTapped, listDot, _updatedPosition, _updatedSize),
          ),
        ),
        Center(child: child),
      ],
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
    Paint paintDotsSolid = Paint();
    paintDotsSolid.color = Colors.yellow;

    double sigma = 10.0;
    Paint paintDotsFuzzy = Paint();
    paintDotsFuzzy.color = paintDotsSolid.color;
    paintDotsFuzzy.maskFilter = MaskFilter.blur(BlurStyle.normal, sigma);

    Paint paintEdge = Paint();
    paintEdge.color = paintDotsSolid.color;
    paintEdge.maskFilter = MaskFilter.blur(BlurStyle.outer, sigma);

    // draw rect with primitive
    Rect rect =
        Rect.fromPoints(_updatedPosition, _updatedPosition + _updatedSize);
    RRect rrect = RRect.fromRectAndRadius(rect, Radius.circular(10));

    // paint inner part of button
    var paintSolid = Paint();
    paintSolid.color = Colors.lightBlue[200];
    canvas.drawRRect(rrect, paintSolid);

    // paint edges
    var paintStroke = Paint();
    paintStroke.color = Colors.yellow[50];
    paintStroke.style = PaintingStyle.stroke;
    paintStroke.strokeWidth = 2;
    canvas.drawRRect(rrect, paintStroke);

    // paint edge blur
    double sz = 1;
    canvas.drawRRect(rrect, paintEdge);

    // paint exploding dots (optimize and add a state where we can skip this)
    var r = Random(1);
    for (var dot in _listDot) {
      dot.draw(canvas, paintDotsFuzzy, paintDotsSolid);
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
    double offsetDt = 0.05;

    if (dt < offsetDt) {
      // function parameter will go from 0 to 1
      updateByVibration(dt / offsetDt);
    } else {
      updateByExplosion(dt - offsetDt);
    }
  }

  void draw(Canvas canvas, Paint paintFuzzy, Paint paintSolid) {
    var sizeSolid = 4.0 * _brightness;

    var sizeFuzzy = sizeSolid * 3.0;

    Offset center = Offset(_updatedPosition.dx, _updatedPosition.dy);
    Offset offFuzzy = Offset(sizeFuzzy / 2, sizeFuzzy / 2);
    Rect rectFuzzy = Rect.fromPoints(center - offFuzzy, center + offFuzzy);

    Offset offSolid = Offset(sizeSolid / 2, sizeSolid / 2);
    Rect rectSolid = Rect.fromPoints(center - offSolid, center + offSolid);

    canvas.drawOval(rectSolid, paintSolid);
    canvas.drawOval(rectFuzzy, paintFuzzy);
  }

  void updateByVibration(double dt) {
//    _brightness = Curves.bounceIn.transform(dt);
    _brightness = Curves.elasticInOut.transform(dt);
    _brightness = Curves.easeOutBack.transform(dt);
    _updatedPosition = _initialPosition;
  }

  void updateByExplosion(double dt) {
    double curveFactor = Curves.decelerate.transform(dt);

    double a = 0.9;
    double b = 1.0 - a;
    curveFactor = 1.0 - pow(1.0 - dt, 2 * 10) * a - (1.0 - dt) * b;

    _brightness = 1.0 - curveFactor;

    Offset translation = _initialSpeed * curveFactor * 400.0;

    _updatedPosition = _initialPosition + translation;
  }
}
