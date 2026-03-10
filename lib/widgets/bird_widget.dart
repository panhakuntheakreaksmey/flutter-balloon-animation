import 'package:flutter/material.dart';

class BirdWidget extends StatefulWidget {
  final double speed;
  final double top;
  final double size;
  final bool reverse;

  const BirdWidget({
    Key? key,
    required this.speed,
    required this.top,
    required this.size,
    this.reverse = false,
  }) : super(key: key);

  @override
  _BirdWidgetState createState() => _BirdWidgetState();
}

class _BirdWidgetState extends State<BirdWidget>
    with TickerProviderStateMixin {

  late AnimationController _flyController;
  late AnimationController _flapController;
  late Animation<double> _flyAnimation;
  late Animation<double> _flapAnimation;

  @override
  void initState() {
    super.initState();

    _flyController = AnimationController(
      duration: Duration(seconds: widget.speed.toInt()),
      vsync: this,
    );

    _flapController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    _flyAnimation = Tween(
      begin: widget.reverse ? 500.0 : -150.0,
      end: widget.reverse ? -150.0 : 500.0,
    ).animate(
      CurvedAnimation(
        parent: _flyController,
        curve: Curves.linear,
      ),
    );


    _flapAnimation = Tween(
      begin: -0.3,
      end: 0.3,
    ).animate(
      CurvedAnimation(
        parent: _flapController,
        curve: Curves.easeInOut,
      ),
    );

    _flyController.repeat();
    _flapController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _flyController.dispose();
    _flapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_flyAnimation, _flapAnimation]),
      builder: (context, child) {
        return Positioned(
          top: widget.top,
          left: _flyAnimation.value,
          child: Transform.scale(
            scaleX: widget.reverse ? -1 : 1,
            child: CustomPaint(
              size: Size(widget.size, widget.size * 0.6),
              painter: BirdPainter(
                flapAngle: _flapAnimation.value,
              ),
            ),
          ),
        );
      },
    );
  }
}

class BirdPainter extends CustomPainter {
  final double flapAngle;

  BirdPainter({required this.flapAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF2E86AB)
      ..style = PaintingStyle.fill;

    final wingPaint = Paint()
      ..color = Color(0xFF1A5276)
      ..style = PaintingStyle.fill;

    final beakPaint = Paint()
      ..color = Color(0xFFE67E22)
      ..style = PaintingStyle.fill;

    double cx = size.width * 0.5;
    double cy = size.height * 0.5;


    final bodyPath = Path();
    bodyPath.addOval(Rect.fromCenter(
      center: Offset(cx, cy),
      width: size.width * 0.45,
      height: size.height * 0.4,
    ));
    canvas.drawPath(bodyPath, paint);


    canvas.drawCircle(
      Offset(cx + size.width * 0.2, cy - size.height * 0.1),
      size.width * 0.12,
      paint,
    );


    final beakPath = Path();
    beakPath.moveTo(cx + size.width * 0.32, cy - size.height * 0.1);
    beakPath.lineTo(cx + size.width * 0.45, cy - size.height * 0.05);
    beakPath.lineTo(cx + size.width * 0.32, cy - size.height * 0.0);
    beakPath.close();
    canvas.drawPath(beakPath, beakPaint);


    final tailPath = Path();
    tailPath.moveTo(cx - size.width * 0.22, cy);
    tailPath.lineTo(cx - size.width * 0.45, cy - size.height * 0.15);
    tailPath.lineTo(cx - size.width * 0.45, cy + size.height * 0.15);
    tailPath.close();
    canvas.drawPath(tailPath, wingPaint);


    canvas.save();
    canvas.translate(cx, cy - size.height * 0.05);
    canvas.rotate(-flapAngle); // rotates with flapAngle
    final upperWingPath = Path();
    upperWingPath.moveTo(0, 0);
    upperWingPath.quadraticBezierTo(
      -size.width * 0.15, -size.height * 0.5,
      -size.width * 0.4, -size.height * 0.3,
    );
    upperWingPath.quadraticBezierTo(
      -size.width * 0.2, -size.height * 0.1,
      0, 0,
    );
    canvas.drawPath(upperWingPath, wingPaint);
    canvas.restore();


    canvas.save();
    canvas.translate(cx, cy + size.height * 0.05);
    canvas.rotate(flapAngle);
    final lowerWingPath = Path();
    lowerWingPath.moveTo(0, 0);
    lowerWingPath.quadraticBezierTo(
      -size.width * 0.15, size.height * 0.4,
      -size.width * 0.35, size.height * 0.25,
    );
    lowerWingPath.quadraticBezierTo(
      -size.width * 0.2, size.height * 0.1,
      0, 0,
    );
    canvas.drawPath(lowerWingPath, wingPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(BirdPainter oldDelegate) {
    return oldDelegate.flapAngle != flapAngle;
  }
}
